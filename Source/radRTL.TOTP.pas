// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.TOTP;

interface

uses
  System.SysUtils,
  radRTL.HOTP;

type


  TOTP = class(THOTP)
  private const
    TimeStepWindow = 30; // 30 is recommended value. "The prover and verifier MUST use the same time-step"
  protected
    class function GetCurrentUnixTimestamp():Int64;
  public
    /// <summary> TOTP: Time-Based One-Time Password Algorithm (most commonly used by Google Authenticaor)</summary>
    class function GeneratePinNumber(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):integer; overload;
  end;



implementation

uses
  System.DateUtils,
  radRTL.Base32Encoding,
  radRTL.ByteArrayUtils;


class function TOTP.GetCurrentUnixTimestamp():Int64;
begin
  Result := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now)) div TOTP.TimeStepWindow;
end;


// https://datatracker.ietf.org/doc/html/rfc6238
class function TOTP.GeneratePinNumber(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):integer;
begin
  Result := TOTP.GeneratePinNumber(pBase32EncodedSecretKey, GetCurrentUnixTimestamp, pOutputLength);
end;



end.
