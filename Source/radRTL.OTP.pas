// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.OTP;

interface

uses
  System.SysUtils;

type

  EOTPException = class(Exception);


  // "Password generated must be at least 6, but can be 7 or 8" digits in length (simply changes the MOD operation) (9-digit addition suggested in errata: https://www.rfc-editor.org/errata/eid2400)
  TOTPLength = (SixDigits, SevenDigits, EightDigits);


  TOTP = class
  private const
    ModTable: array [0 .. 2] of integer = (1000000, 10000000, 100000000); // 6,7,8 zeros matching OTP Length
    TimeStepWindow = 30; // 30 is recommended value. "The prover and verifier MUST use the same time-step"
    RFCMinimumKeyLengthBytes = 16; // length of shared secret MUST be 128 bits (16 bytes)
  protected
    class function GetCurrentUnixTimestamp():Int64;
  public

    /// <summary> TOTP: Time-Based One-Time Password Algorithm (most commonly used by Google Authenticaor)</summary>
    class function GenerateTOTP(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):integer;

    /// <summary> HOTP: HMAC-Based One-Time Password Algorithm</summary>
    class function GenerateHOTP(const pBase32EncodedSecretKey:string; const pCounterValue:Int64; const pOutputLength:TOTPLength = TOTPLength.SixDigits):integer;

  end;


resourcestring
  sOTPKeyLengthTooShort = 'Key length must be at least 128bits';


implementation

uses
  System.DateUtils,
  System.Hash,
  radRTL.Base32Encoding,
  radRTL.ByteArrayUtils;


class function TOTP.GetCurrentUnixTimestamp():Int64;
begin
  Result := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now)) div TOTP.TimeStepWindow;
end;


// https://datatracker.ietf.org/doc/html/rfc6238
class function TOTP.GenerateTOTP(const pBase32EncodedSecretKey:string; const pOutputLength:TOTPLength = TOTPLength.SixDigits):integer;
begin
  Result := TOTP.GenerateHOTP(pBase32EncodedSecretKey, GetCurrentUnixTimestamp, pOutputLength);
end;


// https://datatracker.ietf.org/doc/html/rfc4226
class function TOTP.GenerateHOTP(const pBase32EncodedSecretKey:string; const pCounterValue:Int64; const pOutputLength:TOTPLength = TOTPLength.SixDigits):integer;

var
  vEncodedKey:TBytes;
  vDecdedKey:TBytes;
  vData:TBytes;
  vHMAC:TBytes;
  vOffset:integer;
  vBinCode:integer;
begin
  vEncodedKey := TEncoding.UTF8.GetBytes(pBase32EncodedSecretKey); // assume secret was stored as UTF8  (prover and verifier must match)
  if Length(vEncodedKey) < RFCMinimumKeyLengthBytes then
  begin
    // RFC minimum length required  (Note: did not see this limitation in other implementations)
    raise EOTPException.CreateRes(@sOTPKeyLengthTooShort);
  end;
  vDecdedKey := TBase32.Decode(vEncodedKey);
  vData := ReverseByteArray(ConvertToByteArray(pCounterValue)); // Convert to big-endian
  vHMAC := THashSHA1.GetHMACAsBytes(vData, vDecdedKey);

  // rfc notes: extract a 4-byte dynamic binary integer code from a 160-bit (20-byte) HMAC-SHA-1 binary digest.
  vOffset := vHMAC[19] and $0F;
  vBinCode := ((vHMAC[vOffset] and $7F) shl 24)
              or ((vHMAC[vOffset + 1] and $FF) shl 16)
              or ((vHMAC[vOffset + 2] and $FF) shl 8)
              or (vHMAC[vOffset + 3] and $FF);

  // trim result to 6,7, or 8 digits in length
  Result := vBinCode mod TOTP.ModTable[Ord(pOutputLength)];
end;


end.
