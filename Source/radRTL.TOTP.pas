// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.TOTP;

interface

uses
  System.SysUtils,
  radRTL.HOTP;

const
  DefaultTOTPTimeStepSeconds = 30; // "The prover and verifier MUST use the same time-step" (RFC 6238); 30 is the recommended value
  DefaultTOTPT0 = 0;               // Unix epoch as the initial value to count time steps (RFC 6238 T0 = 0)

type

  // Configuration for TOTP password generation. Declare a variable and override only the fields you need: the
  // class operator Initialize applies safe defaults, so an uninitialized TTOTPOptions never yields a zero time step.
  TTOTPOptions = record
    OutputLength:TOTPLength;            // default SixDigits
    TimeStepSeconds:Integer;            // default 30; MUST be > 0
    T0:Int64;                           // default 0 (Unix epoch)
    EnforceMinimumKeyLength:Boolean;    // default False (RFC 4226 128-bit minimum)
    class operator Initialize(out Dest:TTOTPOptions);
  end;


  TTOTP = class(THOTP)
  private
    class function ValidateAtCounter(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pReferenceCounter:Int64; const pWindowSteps:Integer; const pOptions:TTOTPOptions):Boolean;
  public
    /// <summary> Compute the RFC 6238 time-step counter T = (UnixTime - T0) div TimeStep for an explicit Unix time (deterministic; used by verifiers and tests).</summary>
    class function TimeStepCounter(const pUnixTime:Int64; const pTimeStepSeconds:Integer = DefaultTOTPTimeStepSeconds; const pT0:Int64 = DefaultTOTPT0):Int64; static;

    /// <summary> TOTP: Time-Based One-Time Password Algorithm (most commonly used by Google Authenticator)</summary>
    class function GeneratePassword(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):string; overload;
    class function GeneratePassword(const pBase32EncodedSecretKey:string; const pOptions:TTOTPOptions):string; overload;

    /// <summary> Validate a candidate TOTP against the current clock, accepting +/- pWindowSteps of clock skew (default 1, per RFC 6238 section 5.2). Uses constant-time comparison over the full window.</summary>
    class function ValidatePassword(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pWindowSteps:Integer = 1; const pOutputLength:TOTPLength = TOTPLength.SixDigits):Boolean; overload;
    class function ValidatePassword(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pOptions:TTOTPOptions; const pWindowSteps:Integer = 1):Boolean; overload;
    /// <summary> Deterministic validation against an explicit Unix time (for servers with their own clock source and for testing against RFC 6238 vectors).</summary>
    class function ValidatePasswordAtTime(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pUnixTime:Int64; const pOptions:TTOTPOptions; const pWindowSteps:Integer = 1):Boolean;
  end;


resourcestring
  sOTPTimeStepInvalid = 'TimeStepSeconds must be greater than zero';
  sOTPNegativeWindow = 'Verification window steps cannot be negative';


implementation

uses
  System.DateUtils,
  radRTL.ByteArrayUtils;


class operator TTOTPOptions.Initialize(out Dest:TTOTPOptions);
begin
  Dest.OutputLength := TOTPLength.SixDigits;
  Dest.TimeStepSeconds := DefaultTOTPTimeStepSeconds;
  Dest.T0 := DefaultTOTPT0;
  Dest.EnforceMinimumKeyLength := False;
end;


class function TTOTP.TimeStepCounter(const pUnixTime:Int64; const pTimeStepSeconds:Integer = DefaultTOTPTimeStepSeconds; const pT0:Int64 = DefaultTOTPT0):Int64;
begin
  if pTimeStepSeconds <= 0 then
  begin
    raise EOTPException.CreateRes(@sOTPTimeStepInvalid);
  end;
  Result := (pUnixTime - pT0) div pTimeStepSeconds;
end;


class function TTOTP.GeneratePassword(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):string;
var
  vOptions:TTOTPOptions;
begin
  vOptions.OutputLength := pOutputLength; // remaining fields defaulted via TTOTPOptions.Initialize
  Result := GeneratePassword(pBase32EncodedSecretKey, vOptions);
end;


// https://datatracker.ietf.org/doc/html/rfc6238
class function TTOTP.GeneratePassword(const pBase32EncodedSecretKey:string; const pOptions:TTOTPOptions):string;
var
  vCounter:Int64;
begin
  // Now is local time; DateTimeToUnix with AInputIsUTC=False converts it to a correct UTC Unix timestamp.
  vCounter := TimeStepCounter(DateTimeToUnix(Now, {AInputIsUTC=}False), pOptions.TimeStepSeconds, pOptions.T0);
  Result := THOTP.GeneratePassword(pBase32EncodedSecretKey, vCounter, pOptions.OutputLength, pOptions.EnforceMinimumKeyLength);
end;


class function TTOTP.ValidateAtCounter(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pReferenceCounter:Int64; const pWindowSteps:Integer; const pOptions:TTOTPOptions):Boolean;
var
  k:Integer;
  vGenerated:string;
  vMatched:Boolean;
begin
  if pWindowSteps < 0 then
  begin
    raise EOTPException.CreateRes(@sOTPNegativeWindow);
  end;

  // Evaluate the entire window with no early-out: ConstantTimeEquals is the left operand of OR so it is always
  // called for every step, and the result is accumulated -- so neither the iteration count nor timing reveals
  // whether/which step matched. (Reporting WHICH step matched, for clock-drift resync, is tracked in issue #20.)
  vMatched := False;
  for k := -pWindowSteps to pWindowSteps do
  begin
    vGenerated := THOTP.GeneratePassword(pBase32EncodedSecretKey, pReferenceCounter + k, pOptions.OutputLength, pOptions.EnforceMinimumKeyLength);
    vMatched := ConstantTimeEquals(pCandidateOTP, vGenerated) or vMatched;
  end;

  Result := vMatched;
end;


class function TTOTP.ValidatePassword(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pWindowSteps:Integer = 1; const pOutputLength:TOTPLength = TOTPLength.SixDigits):Boolean;
var
  vOptions:TTOTPOptions;
begin
  vOptions.OutputLength := pOutputLength; // remaining fields defaulted via TTOTPOptions.Initialize
  Result := ValidatePassword(pBase32EncodedSecretKey, pCandidateOTP, vOptions, pWindowSteps);
end;


class function TTOTP.ValidatePassword(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pOptions:TTOTPOptions; const pWindowSteps:Integer = 1):Boolean;
begin
  Result := ValidatePasswordAtTime(pBase32EncodedSecretKey, pCandidateOTP, DateTimeToUnix(Now, {AInputIsUTC=}False), pOptions, pWindowSteps);
end;


// https://datatracker.ietf.org/doc/html/rfc6238#section-5.2
class function TTOTP.ValidatePasswordAtTime(const pBase32EncodedSecretKey:string; const pCandidateOTP:string; const pUnixTime:Int64; const pOptions:TTOTPOptions; const pWindowSteps:Integer = 1):Boolean;
var
  vReferenceCounter:Int64;
begin
  vReferenceCounter := TimeStepCounter(pUnixTime, pOptions.TimeStepSeconds, pOptions.T0);
  Result := ValidateAtCounter(pBase32EncodedSecretKey, pCandidateOTP, vReferenceCounter, pWindowSteps, pOptions);
end;


end.
