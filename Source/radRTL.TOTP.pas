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
    OutputLength:TOTPLength;   // default SixDigits
    TimeStepSeconds:Integer;   // default 30; MUST be > 0
    T0:Int64;                  // default 0 (Unix epoch)
    class operator Initialize(out Dest:TTOTPOptions);
  end;


  TTOTP = class(THOTP)
  public
    /// <summary> Compute the RFC 6238 time-step counter T = (UnixTime - T0) div TimeStep for an explicit Unix time (deterministic; used by verifiers and tests).</summary>
    class function TimeStepCounter(const pUnixTime:Int64; const pTimeStepSeconds:Integer = DefaultTOTPTimeStepSeconds; const pT0:Int64 = DefaultTOTPT0):Int64; static;

    /// <summary> TOTP: Time-Based One-Time Password Algorithm (most commonly used by Google Authenticator)</summary>
    class function GeneratePassword(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):string; overload;
    class function GeneratePassword(const pBase32EncodedSecretKey:string; const pOptions:TTOTPOptions):string; overload;
  end;


resourcestring
  sOTPTimeStepInvalid = 'TimeStepSeconds must be greater than zero';


implementation

uses
  System.DateUtils;


class operator TTOTPOptions.Initialize(out Dest:TTOTPOptions);
begin
  Dest.OutputLength := TOTPLength.SixDigits;
  Dest.TimeStepSeconds := DefaultTOTPTimeStepSeconds;
  Dest.T0 := DefaultTOTPT0;
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
  Result := THOTP.GeneratePassword(pBase32EncodedSecretKey, vCounter, pOptions.OutputLength);
end;


end.
