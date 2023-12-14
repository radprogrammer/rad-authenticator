// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.TOTP;

interface

uses
  System.SysUtils,
  radRTL.HOTP;

type
  TTOTP = class(THOTP)
  private const
    TimeStepWindow = 30; // 30 is recommended value. "The prover and verifier MUST use the same time-step"
  protected
    class function GetCurrentUnixTimestamp(ATimeStepWindow: Integer): Int64;
  public
    /// <summary> TOTP: Time-Based One-Time Password Algorithm (most commonly used by Google Authenticaor)</summary>
    class function GeneratePassword(const pBase32EncodedSecretKey: string; const pOutputLength: TOTPLength = TOTPLength.SixDigits;
      ATimeStepWindow: Integer = TimeStepWindow): string; overload;
  end;

implementation

uses
  System.DateUtils;

class function TTOTP.GetCurrentUnixTimestamp(ATimeStepWindow: Integer): Int64;
begin
  Result := DateTimeToUnix(Now, {AInputIsUTC=}False) div ATimeStepWindow;
end;

// https://datatracker.ietf.org/doc/html/rfc6238
class function TTOTP.GeneratePassword(const pBase32EncodedSecretKey: string; const pOutputLength: TOTPLength = TOTPLength.SixDigits;
  ATimeStepWindow: Integer = TimeStepWindow): string;
begin
  Result := THOTP.GeneratePassword(pBase32EncodedSecretKey, GetCurrentUnixTimestamp(ATimeStepWindow), pOutputLength);
end;

end.
