// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.TOTP.Tests;

interface

uses
  TestFramework;

type

  TOTPTest = class(TTestCase)
  published
    procedure TestRFCVectors;
  end;


implementation

uses
  radRTL.TOTP,
  radRTL.HOTP;


// todo: support SHA256, SHA512 vectors  ("TOTP implementations MAY use HMAC-SHA-256 or HMAC-SHA-512 functions")

(*
 https://datatracker.ietf.org/doc/html/rfc6238
 Appendix B

 The test token shared secret uses the ASCII string value
   "12345678901234567890".  With Time Step X = 30, and the Unix epoch as
   the initial value to count time steps, where T0 = 0, the TOTP
   algorithm will display the following values for specified modes and
   timestamps.

  +-------------+--------------+------------------+----------+--------+
  |  Time (sec) |   UTC Time   | Value of T (hex) |   TOTP   |  Mode  |
  +-------------+--------------+------------------+----------+--------+
  |      59     |  1970-01-01  | 0000000000000001 | 94287082 |  SHA1  |
  |             |   00:00:59   |                  |          |        |
  |      59     |  1970-01-01  | 0000000000000001 | 46119246 | SHA256 |
  |             |   00:00:59   |                  |          |        |
  |      59     |  1970-01-01  | 0000000000000001 | 90693936 | SHA512 |
  |             |   00:00:59   |                  |          |        |
  |  1111111109 |  2005-03-18  | 00000000023523EC | 07081804 |  SHA1  |
  |             |   01:58:29   |                  |          |        |
  |  1111111109 |  2005-03-18  | 00000000023523EC | 68084774 | SHA256 |
  |             |   01:58:29   |                  |          |        |
  |  1111111109 |  2005-03-18  | 00000000023523EC | 25091201 | SHA512 |
  |             |   01:58:29   |                  |          |        |
  |  1111111111 |  2005-03-18  | 00000000023523ED | 14050471 |  SHA1  |
  |             |   01:58:31   |                  |          |        |
  |  1111111111 |  2005-03-18  | 00000000023523ED | 67062674 | SHA256 |
  |             |   01:58:31   |                  |          |        |
  |  1111111111 |  2005-03-18  | 00000000023523ED | 99943326 | SHA512 |
  |             |   01:58:31   |                  |          |        |
  |  1234567890 |  2009-02-13  | 000000000273EF07 | 89005924 |  SHA1  |
  |             |   23:31:30   |                  |          |        |
  |  1234567890 |  2009-02-13  | 000000000273EF07 | 91819424 | SHA256 |
  |             |   23:31:30   |                  |          |        |
  |  1234567890 |  2009-02-13  | 000000000273EF07 | 93441116 | SHA512 |
  |             |   23:31:30   |                  |          |        |
  |  2000000000 |  2033-05-18  | 0000000003F940AA | 69279037 |  SHA1  |
  |             |   03:33:20   |                  |          |        |
  |  2000000000 |  2033-05-18  | 0000000003F940AA | 90698825 | SHA256 |
  |             |   03:33:20   |                  |          |        |
  |  2000000000 |  2033-05-18  | 0000000003F940AA | 38618901 | SHA512 |
  |             |   03:33:20   |                  |          |        |
  | 20000000000 |  2603-10-11  | 0000000027BC86AA | 65353130 |  SHA1  |
  |             |   11:33:20   |                  |          |        |
  | 20000000000 |  2603-10-11  | 0000000027BC86AA | 77737706 | SHA256 |
  |             |   11:33:20   |                  |          |        |
  | 20000000000 |  2603-10-11  | 0000000027BC86AA | 47863826 | SHA512 |
  |             |   11:33:20   |                  |          |        |
  +-------------+--------------+------------------+----------+--------+
*)
procedure TOTPTest.TestRFCVectors;
const
  SECRET = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'; // TBase32.Encode('12345678901234567890');
  INPUT_VALUES: array [0 .. 5] of Int64 = ($1, $23523EC, $23523ED, $273EF07, $3F940AA, $27BC86AA);
  EXPECTED_8DIGIT_VALUES: array [0 .. 5] of string = ('94287082', '07081804', '14050471', '89005924', '69279037', '65353130');
  EXPECTED_7DIGIT_VALUES: array [0 .. 5] of string = ('4287082', '7081804', '4050471', '9005924', '9279037', '5353130');
  EXPECTED_6DIGIT_VALUES: array [0 .. 5] of string = ('287082', '081804', '050471', '005924', '279037', '353130');
var
  i:integer;
begin
  for i := low(INPUT_VALUES) to high(INPUT_VALUES) do
  begin
    CheckEquals(EXPECTED_8DIGIT_VALUES[i], TTOTP.GeneratePassword(SECRET, INPUT_VALUES[i], TOTPLength.EightDigits));
    CheckEquals(EXPECTED_7DIGIT_VALUES[i], TTOTP.GeneratePassword(SECRET, INPUT_VALUES[i], TOTPLength.SevenDigits));
    CheckEquals(EXPECTED_6DIGIT_VALUES[i], TTOTP.GeneratePassword(SECRET, INPUT_VALUES[i], TOTPLength.SixDigits));
  end;
end;


initialization

RegisterTest(TOTPTest.Suite);

end.
