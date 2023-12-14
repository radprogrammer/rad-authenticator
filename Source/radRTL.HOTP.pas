// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.HOTP;

interface

uses
  System.SysUtils;

type
  EOTPException = class(Exception);

  // "Password generated must be at least 6, but can be 7 or 8" digits in length (simply changes the MOD operation) (9-digit addition suggested in errata: https://www.rfc-editor.org/errata/eid2400)
  TOTPLength = (SixDigits, SevenDigits, EightDigits);

  THOTP = class
  private const
    ModTable: array [0 .. 2] of integer = (1000000, 10000000, 100000000); // 6,7,8 zeros matching OTP Length
    FormatTable: array [0 .. 2] of string = ('%.6d', '%.7d', '%.8d'); // 6,7,8 string length (padded left with zeros)
    RFCMinimumKeyLengthBytes = 16; // "The length of shared secret MUST be at least 128 bits. This document RECOMMENDs a shared secret length of 160 bits."
  public class var
    EnforceMinimumKeyLength: Boolean;
  public
    /// <summary> HOTP: HMAC-Based One-Time Password Algorithm</summary>
    class function GeneratePassword(const pBase32EncodedSecretKey: string; const pCounterValue: Int64; const pOutputLength: TOTPLength = TOTPLength.SixDigits): string; overload;
    class function GeneratePassword(const pPlainTextSecretKey: TBytes; const pCounterValue: Int64; const pOutputLength: TOTPLength = TOTPLength.SixDigits): string; overload;
  end;

resourcestring
  sOTPKeyLengthTooShort = 'Key length must be at least 128bits';

implementation

uses
  System.Hash,
  radRTL.Base32Encoding,
  radRTL.ByteArrayUtils;

class function THOTP.GeneratePassword(const pBase32EncodedSecretKey: string; const pCounterValue: Int64; const pOutputLength: TOTPLength = TOTPLength.SixDigits): string;
var
  vEncodedKey: TBytes;
  vDecodedKey: TBytes;
begin
  vEncodedKey := TEncoding.UTF8.GetBytes(pBase32EncodedSecretKey); // assume secret was stored as UTF8  (prover and verifier must match)
  vDecodedKey := TBase32.Decode(vEncodedKey);

  Result := GeneratePassword(vDecodedKey, pCounterValue, pOutputLength);
end;

// https://datatracker.ietf.org/doc/html/rfc4226
class function THOTP.GeneratePassword(const pPlainTextSecretKey: TBytes; const pCounterValue: Int64; const pOutputLength: TOTPLength = TOTPLength.SixDigits): string;
var
  vData: TBytes;
  vHMAC: TBytes;
  vOffset: Integer;
  vBinCode: Integer;
  vPinNumber: Integer;
begin
  if EnforceMinimumKeyLength and (Length(pPlainTextSecretKey) < RFCMinimumKeyLengthBytes) then
    // RFC minimum length required  (Note: did not see this limitation in other implementations)
    raise EOTPException.CreateRes(@sOTPKeyLengthTooShort);
  vData := ReverseByteArray(ConvertToByteArray(pCounterValue)); // RFC reference implmentation reversed order of CounterValue (movingFactor) bytes
  vHMAC := THashSHA1.GetHMACAsBytes(vData, pPlainTextSecretKey); // SHA1 = 20 byte digest

  // rfc notes: extract a 4-byte dynamic binary integer code from the HMAC result
  vOffset := vHMAC[19] and $0F; // extract a random number 0 to 15 (from the value of the very last byte of the hash digest AND 0000-1111)

  // 4 bytes extracted starting at this random offset (first bit intentionally zero'ed to avoid compatibility problems with signed vs unsigned MOD operations)
  vBinCode := ((vHMAC[vOffset] and $7F) shl 24) // byte at offset AND 0111-1111 moved to first 8 bits of result
    or (vHMAC[vOffset + 1] shl 16) or (vHMAC[vOffset + 2] shl 8) or vHMAC[vOffset + 3];

  // trim 31-bit unsigned value to 6 to 8 digits in length
  vPinNumber := vBinCode mod THOTP.ModTable[Ord(pOutputLength)];

  // Format the 6 to 8 digit OTP result by padding left with zeros as needed
  Result := Format(FormatTable[Ord(pOutputLength)], [vPinNumber]);
end;

end.
