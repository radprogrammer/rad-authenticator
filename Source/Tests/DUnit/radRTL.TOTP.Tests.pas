// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.TOTP.Tests;

interface

uses
  TestFramework;

type

  TTOTPTest = class(TTestCase)
  published
    procedure TestRFCVectors;
    procedure TestTimeStepCounter;
    procedure TestOptionsDefaults;
    procedure TestZeroTimeStepRaises;
    procedure TestEnforceMinimumKeyLengthViaOptions;
    procedure TestValidatePassword;
    procedure TestValidateNegativeWindowRaises;
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
procedure TTOTPTest.TestRFCVectors;
const
  BASE32_SECRETKEY_INPUT = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'; // TBase32.Encode('12345678901234567890');
  TIME_COUNTER_INPUT: array [0 .. 5] of Int64 = ($1, $23523EC, $23523ED, $273EF07, $3F940AA, $27BC86AA);
  EXPECTED_8DIGIT_OTP: array [0 .. 5] of string = ('94287082', '07081804', '14050471', '89005924', '69279037', '65353130');
  EXPECTED_7DIGIT_OTP: array [0 .. 5] of string = ('4287082', '7081804', '4050471', '9005924', '9279037', '5353130');
  EXPECTED_6DIGIT_OTP: array [0 .. 5] of string = ('287082', '081804', '050471', '005924', '279037', '353130');
var
  i:integer;
begin
  for i := low(TIME_COUNTER_INPUT) to high(TIME_COUNTER_INPUT) do
  begin
    CheckEquals(EXPECTED_8DIGIT_OTP[i], TTOTP.GeneratePassword(BASE32_SECRETKEY_INPUT, TIME_COUNTER_INPUT[i], TOTPLength.EightDigits));
    CheckEquals(EXPECTED_7DIGIT_OTP[i], TTOTP.GeneratePassword(BASE32_SECRETKEY_INPUT, TIME_COUNTER_INPUT[i], TOTPLength.SevenDigits));
    CheckEquals(EXPECTED_6DIGIT_OTP[i], TTOTP.GeneratePassword(BASE32_SECRETKEY_INPUT, TIME_COUNTER_INPUT[i], TOTPLength.SixDigits));
  end;
end;


procedure TTOTPTest.TestTimeStepCounter;
begin
  // RFC 6238: with a 30s step and T0=0, time 59s -> T=1 and 1111111109s -> T=$23523EC.
  CheckEquals(Int64(1), TTOTP.TimeStepCounter(59, 30, 0));
  CheckEquals(Int64($23523EC), TTOTP.TimeStepCounter(1111111109, 30, 0));

  // A non-zero T0 shifts the counting epoch.
  CheckEquals(Int64(0), TTOTP.TimeStepCounter(59, 30, 30));

  // A non-30 step changes the window size.
  CheckEquals(Int64(0), TTOTP.TimeStepCounter(59, 60, 0));
  CheckEquals(Int64(1), TTOTP.TimeStepCounter(60, 60, 0));
end;


procedure TTOTPTest.TestOptionsDefaults;
var
  vOptions:TTOTPOptions;
begin
  // A freshly-declared record is initialized to safe defaults (never a zero time step).
  CheckEquals(Ord(TOTPLength.SixDigits), Ord(vOptions.OutputLength));
  CheckEquals(30, vOptions.TimeStepSeconds);
  CheckEquals(Int64(0), vOptions.T0);
  CheckFalse(vOptions.EnforceMinimumKeyLength);
end;


procedure TTOTPTest.TestEnforceMinimumKeyLengthViaOptions;
var
  vOptions:TTOTPOptions;
  vRaised:Boolean;
begin
  // Off by default: a short key does not raise.
  TTOTP.GeneratePassword('KNEE6USU');  //'SHORT' decoded = 5 bytes; must not raise

  // Enabled via the options record: a short key raises EOTPException.
  vOptions.EnforceMinimumKeyLength := True;
  vRaised := False;
  try
    TTOTP.GeneratePassword('KNEE6USU', vOptions);
  except
    on E:EOTPException do
      vRaised := True;
  end;
  CheckTrue(vRaised, 'TTOTPOptions.EnforceMinimumKeyLength should raise on a short key');
end;


procedure TTOTPTest.TestZeroTimeStepRaises;
var
  vOptions:TTOTPOptions;
  vRaised:Boolean;
begin
  vOptions.TimeStepSeconds := 0;

  vRaised := False;
  try
    TTOTP.GeneratePassword('GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', vOptions);
  except
    on E:EOTPException do
      vRaised := True;
  end;
  CheckTrue(vRaised, 'a zero/negative time step should raise EOTPException');
end;


procedure TTOTPTest.TestValidatePassword;
const
  SECRET = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'; // TBase32.Encode('12345678901234567890')
var
  vOptions:TTOTPOptions;
begin
  // Deterministic: unix time 59s -> time-step counter 1 (30s step). This is the same 20-byte secret as the RFC 4226
  // vectors, so TOTP counter N yields the HOTP count-N value: counter0=755224, counter1=287082, counter2=359152, counter3=969429.

  // exact step matches with no window
  CheckTrue(TTOTP.ValidatePasswordAtTime(SECRET, '287082', 59, vOptions, 0), 'exact step should validate');

  // one step earlier/later validate within the default window of 1
  CheckTrue(TTOTP.ValidatePasswordAtTime(SECRET, '755224', 59, vOptions, 1), 'previous step should validate within window 1');
  CheckTrue(TTOTP.ValidatePasswordAtTime(SECRET, '359152', 59, vOptions, 1), 'next step should validate within window 1');

  // the previous step is outside a zero window
  CheckFalse(TTOTP.ValidatePasswordAtTime(SECRET, '755224', 59, vOptions, 0), 'previous step should fail with window 0');

  // two steps off: fails at window 1, passes at window 2
  CheckFalse(TTOTP.ValidatePasswordAtTime(SECRET, '969429', 59, vOptions, 1), 'two steps off should fail at window 1');
  CheckTrue(TTOTP.ValidatePasswordAtTime(SECRET, '969429', 59, vOptions, 2), 'two steps off should pass at window 2');

  // a wrong OTP of the correct length, and a wrong-length OTP, both fail
  CheckFalse(TTOTP.ValidatePasswordAtTime(SECRET, '000000', 59, vOptions, 1), 'a wrong OTP should fail');
  CheckFalse(TTOTP.ValidatePasswordAtTime(SECRET, '28708', 59, vOptions, 1), 'a wrong-length OTP should fail');
end;


procedure TTOTPTest.TestValidateNegativeWindowRaises;
var
  vOptions:TTOTPOptions;
  vRaised:Boolean;
begin
  vRaised := False;
  try
    TTOTP.ValidatePasswordAtTime('GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ', '287082', 59, vOptions, -1);
  except
    on E:EOTPException do
      vRaised := True;
  end;
  CheckTrue(vRaised, 'a negative verification window should raise EOTPException');
end;


initialization

RegisterTest(TTOTPTest.Suite);

end.
