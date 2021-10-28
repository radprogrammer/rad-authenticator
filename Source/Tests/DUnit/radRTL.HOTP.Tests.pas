// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.HOTP.Tests;

interface

uses
  TestFramework,
  System.SysUtils;

type

  THOTPTest = class(TTestCase)
  published
    procedure TestRFCVectors;
  end;


implementation

uses
  radRTL.HOTP;


// https://datatracker.ietf.org/doc/html/rfc4226
procedure THOTPTest.TestRFCVectors;
const
  SECRET_PLAINTEXT_BYTES:TBytes = [49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48]; //'12345678901234567890'
  SECRET_BASE32_STRING = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'; // TBase32.Encode('12345678901234567890');
  EXPECTED_VALUES: array [0 .. 9] of string = ('755224', '287082', '359152', '969429', '338314', '254676', '287922', '162583', '399871', '520489');
var
  i:integer;
begin
  for i := low(EXPECTED_VALUES) to high(EXPECTED_VALUES) do
  begin
    CheckEquals(EXPECTED_VALUES[i], THOTP.GeneratePassword(SECRET_PLAINTEXT_BYTES, i));
    CheckEquals(EXPECTED_VALUES[i], THOTP.GeneratePassword(SECRET_BASE32_STRING, i));
  end;
end;


initialization

RegisterTest(THOTPTest.Suite);

end.
