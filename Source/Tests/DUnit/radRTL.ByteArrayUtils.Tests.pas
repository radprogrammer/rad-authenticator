// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.ByteArrayUtils.Tests;

interface

uses
  TestFramework;

type

  TByteArrayUtilsTest = class(TTestCase)
  published
    procedure TestReverseByteArray_Empty;
    procedure TestReverseByteArray_OneBtye;
    procedure TestReverseByteArray_TwoBtye;
    procedure TestReverseByteArray_ThreeBtye;
    procedure TestConvertInt_Zero;
    procedure TestConvertInt_One;
    procedure TestConvertInt_Two;
    procedure TestConvertInt_256;
    procedure TestConvertInt64_Zero;
    procedure TestConvertInt64_One;
    procedure TestConvertInt64_Two;
    procedure TestConvertInt64_256;
    procedure TestConvertIntAndReverseByteArray_Zero;
    procedure TestConvertIntAndReverseByteArray_One;
    procedure TestConvertIntAndReverseByteArray_Two;
  end;


implementation

uses
  System.SysUtils,
  radRTL.ByteArrayUtils;


procedure TByteArrayUtilsTest.TestReverseByteArray_Empty;
var
  vInput:TBytes;
begin
  CheckEquals(Length(vInput), Length(ReverseByteArray(vInput)));
end;


procedure TByteArrayUtilsTest.TestReverseByteArray_OneBtye;
var
  vInput:TBytes;
  vOutput:TBytes;
begin
  SetLength(vInput, 1);
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));

  vInput[0] := 0;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 1;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 255;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));
end;


procedure TByteArrayUtilsTest.TestReverseByteArray_TwoBtye;
var
  vInput:TBytes;
  vOutput:TBytes;
begin
  SetLength(vInput, 2);
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));

  vInput[0] := 0;
  vInput[1] := 1;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 1;
  vInput[1] := 0;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 0;
  vInput[1] := 255;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 255;
  vInput[1] := 0;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));
end;


procedure TByteArrayUtilsTest.TestReverseByteArray_ThreeBtye;
var
  vInput:TBytes;
  vOutput:TBytes;
begin
  SetLength(vInput, 3);
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));

  vInput[0] := 0;
  vInput[1] := 1;
  vInput[2] := 255;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 1;
  vInput[1] := 0;
  vInput[2] := 255;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 255;
  vInput[1] := 0;
  vInput[2] := 1;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));

  vInput[0] := 0;
  vInput[1] := 255;
  vInput[2] := 1;
  vOutput := ReverseByteArray(vInput);
  CheckEquals(Length(vInput), Length(vOutput));
  ChecKTrue(ByteArraysMatch(vInput, ReverseByteArray(vOutput)));
end;


procedure TByteArrayUtilsTest.TestConvertInt_Zero;
var
  vInput:Integer;
  vConverted:TBytes;
begin
  vInput := 0;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Integer));
  ChecKTrue(vConverted[0] = 0);
  ChecKTrue(vConverted[1] = 0);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt_One;
var
  vInput:Integer;
  vConverted:TBytes;
begin
  vInput := 1;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Integer));
  ChecKTrue(vConverted[0] = 1);
  ChecKTrue(vConverted[1] = 0);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt_Two;
var
  vInput:Integer;
  vConverted:TBytes;
begin
  vInput := 2;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Integer));
  ChecKTrue(vConverted[0] = 2);
  ChecKTrue(vConverted[1] = 0);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt_256;
var
  vInput:Integer;
  vConverted:TBytes;
begin
  vInput := 256;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Integer));
  ChecKTrue(vConverted[0] = 0);
  ChecKTrue(vConverted[1] = 1);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt64_Zero;
var
  vInput:Int64;
  vConverted:TBytes;
begin
  vInput := 0;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Int64));
  ChecKTrue(vConverted[0] = 0);
  ChecKTrue(vConverted[1] = 0);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
  ChecKTrue(vConverted[4] = 0);
  ChecKTrue(vConverted[5] = 0);
  ChecKTrue(vConverted[6] = 0);
  ChecKTrue(vConverted[7] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt64_One;
var
  vInput:Int64;
  vConverted:TBytes;
begin
  vInput := 1;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Int64));
  ChecKTrue(vConverted[0] = 1);
  ChecKTrue(vConverted[1] = 0);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
  ChecKTrue(vConverted[4] = 0);
  ChecKTrue(vConverted[5] = 0);
  ChecKTrue(vConverted[6] = 0);
  ChecKTrue(vConverted[7] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt64_Two;
var
  vInput:Int64;
  vConverted:TBytes;
begin
  vInput := 2;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Int64));
  ChecKTrue(vConverted[0] = 2);
  ChecKTrue(vConverted[1] = 0);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
  ChecKTrue(vConverted[4] = 0);
  ChecKTrue(vConverted[5] = 0);
  ChecKTrue(vConverted[6] = 0);
  ChecKTrue(vConverted[7] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertInt64_256;
var
  vInput:Int64;
  vConverted:TBytes;
begin
  vInput := 256;
  vConverted := ConvertToByteArray(vInput);
  ChecKTrue(Length(vConverted) = SizeOf(Int64));
  ChecKTrue(vConverted[0] = 0);
  ChecKTrue(vConverted[1] = 1);
  ChecKTrue(vConverted[2] = 0);
  ChecKTrue(vConverted[3] = 0);
  ChecKTrue(vConverted[4] = 0);
  ChecKTrue(vConverted[5] = 0);
  ChecKTrue(vConverted[6] = 0);
  ChecKTrue(vConverted[7] = 0);
end;


procedure TByteArrayUtilsTest.TestConvertIntAndReverseByteArray_Zero;
var
  vInput:Integer;
  vConverted:TBytes;
  vReversed:TBytes;
begin
  vInput := 0;
  vConverted := ConvertToByteArray(vInput);
  vReversed := ReverseByteArray(vConverted);
  CheckEquals(Length(vConverted), Length(vReversed));
  ChecKTrue(ByteArraysMatch(vConverted, vReversed)); // true for 0
end;


procedure TByteArrayUtilsTest.TestConvertIntAndReverseByteArray_One;
var
  vInput:Integer;
  vConverted:TBytes;
  vReversed:TBytes;
begin
  vInput := 1;
  vConverted := ConvertToByteArray(vInput);
  vReversed := ReverseByteArray(vConverted);
  CheckEquals(Length(vConverted), Length(vReversed));
  CheckFalse(ByteArraysMatch(vConverted, vReversed));
  ChecKTrue(ByteArraysMatch(vConverted, ReverseByteArray(vReversed)));
end;


procedure TByteArrayUtilsTest.TestConvertIntAndReverseByteArray_Two;
var
  vInput:Integer;
  vConverted:TBytes;
  vReversed:TBytes;
begin
  vInput := 2;
  vConverted := ConvertToByteArray(vInput);
  vReversed := ReverseByteArray(vConverted);
  CheckEquals(Length(vConverted), Length(vReversed));
  CheckFalse(ByteArraysMatch(vConverted, vReversed));
  ChecKTrue(ByteArraysMatch(vConverted, ReverseByteArray(vReversed)));
end;

initialization

RegisterTest(TByteArrayUtilsTest.Suite);

end.
