// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.OTP.Tests;

interface

uses
  TestFramework;

type
  TOTPTest = class(TTestCase)
  published
    procedure TestRFCVectorsHOTP;
    procedure TestRFCVectorsTOTP;
  end;


implementation

uses
  radRTL.OTP,
  radRTL.Base32Encoding;


// https://datatracker.ietf.org/doc/html/rfc4226
procedure TOTPTest.TestRFCVectorsHOTP;
const
  SECRET = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'; // TBase32.Encode('12345678901234567890');
  EXPECTED_VALUES: array [0 .. 9] of integer = (755224, 287082, 359152, 969429, 338314, 254676, 287922, 162583, 399871, 520489);
var
  i:integer;
begin
  for i := low(EXPECTED_VALUES) to high(EXPECTED_VALUES) do
  begin
    CheckEquals(EXPECTED_VALUES[i], TOTP.GenerateHOTP(SECRET, i));
  end;
end;


// https://datatracker.ietf.org/doc/html/rfc6238  Appendix B
// todo: support SHA256, SHA512 vectors
procedure TOTPTest.TestRFCVectorsTOTP;
const
  SECRET = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'; // TBase32.Encode('12345678901234567890');
  INPUT_VALUES: array [0 .. 5] of Int64 = ($1, $23523EC, $23523ED, $273EF07, $3F940AA, $27BC86AA);
  EXPECTED_8DIGIT_VALUES: array [0 .. 5] of integer = (94287082, 07081804, 14050471, 89005924, 69279037, 65353130);
  EXPECTED_7DIGIT_VALUES: array [0 .. 5] of integer = (4287082, 7081804, 4050471, 9005924, 9279037, 5353130);
  EXPECTED_6DIGIT_VALUES: array [0 .. 5] of integer = (287082, 081804, 050471, 005924, 279037, 353130);
var
  i:integer;
begin
  for i := low(INPUT_VALUES) to high(INPUT_VALUES) do
  begin
    CheckEquals(EXPECTED_8DIGIT_VALUES[i], TOTP.GenerateHOTP(SECRET, INPUT_VALUES[i], TOTPLength.EightDigits));
    CheckEquals(EXPECTED_7DIGIT_VALUES[i], TOTP.GenerateHOTP(SECRET, INPUT_VALUES[i], TOTPLength.SevenDigits));
    CheckEquals(EXPECTED_6DIGIT_VALUES[i], TOTP.GenerateHOTP(SECRET, INPUT_VALUES[i], TOTPLength.SixDigits));
  end;
end;


initialization

RegisterTest(TOTPTest.Suite);

end.
