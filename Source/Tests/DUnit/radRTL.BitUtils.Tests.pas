// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.BitUtils.Tests;

interface

uses
  TestFramework;

type

  TBitUtilsTest = class(TTestCase)
  published
    procedure TestExtractLastBits_ValueZero;
    procedure TestExtractLastBits_ValueOne;
    procedure TestExtractLastBits_ValueTwo;
    procedure TestExtractLastBits_ValueThree;
    procedure TestExtractLastBits_ValueFour;
    procedure TestExtractLastBits_ValueFourteen;
    procedure TestExtractLastBits_ValueFifteen;
    procedure TestExtractLastBits_ValueMaxInt;
    procedure TestExtractLastBits_ValueNegativeOne;
  end;

implementation

uses
  System.SysUtils,
  System.Math,
  radRTL.BitUtils;


procedure TBitUtilsTest.TestExtractLastBits_ValueZero;
const
  TESTVALUE = 0; // '0000-0000-0000-0000-0000-0000-0000-0000'
var
  vBits:Integer;
begin
  // no matter the bits requested, should be 0 returned
  for vBits := 1 to 31 do // signed integer with leading signed bit in position 32
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueOne;
const
  TESTVALUE = 1; // '0000-0000-0000-0000-0000-0000-0000-0001'
var
  vBits:Integer;
begin
  CheckEquals(0, ExtractLastBits(1, 0));
  for vBits := 1 to 31 do
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueTwo;
const
  TESTVALUE = 2; // '0000-0000-0000-0000-0000-0000-0000-0010'
var
  vBits:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  CheckEquals(0, ExtractLastBits(TESTVALUE, 1));
  for vBits := 2 to 31 do
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueThree;
const
  TESTVALUE = 3; // '0000-0000-0000-0000-0000-0000-0000-0011'
var
  vBits:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  CheckEquals(1, ExtractLastBits(TESTVALUE, 1));
  for vBits := 2 to 31 do
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueFour;
const
  TESTVALUE = 4; // '0000-0000-0000-0000-0000-0000-0000-0100'
var
  vBits:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  CheckEquals(0, ExtractLastBits(TESTVALUE, 1));
  CheckEquals(0, ExtractLastBits(TESTVALUE, 2));
  for vBits := 3 to 31 do
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueFourteen;
const
  TESTVALUE = 14; // '0000-0000-0000-0000-0000-0000-0000-1110'
var
  vBits:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  CheckEquals(0, ExtractLastBits(TESTVALUE, 1));
  CheckEquals(2, ExtractLastBits(TESTVALUE, 2));
  CheckEquals(6, ExtractLastBits(TESTVALUE, 3));
  for vBits := 4 to 31 do
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueFifteen;
const
  TESTVALUE = 15; // '0000-0000-0000-0000-0000-0000-0000-1111'
var
  vBits:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  CheckEquals(1, ExtractLastBits(TESTVALUE, 1));
  CheckEquals(3, ExtractLastBits(TESTVALUE, 2));
  CheckEquals(7, ExtractLastBits(TESTVALUE, 3));
  for vBits := 4 to 31 do
  begin
    CheckEquals(TESTVALUE, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueMaxInt;
const
  TESTVALUE = MaxInt; // 2147483647  '0111-1111-1111-1111-1111-1111-1111-1111'
var
  vBits:Integer;
  vExpected:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  for vBits := 1 to 31 do
  begin
    vExpected := Trunc(Power(2, vBits)) - 1;
    CheckEquals(vExpected, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


procedure TBitUtilsTest.TestExtractLastBits_ValueNegativeOne;
const
  TESTVALUE = -1; // '1111-1111-1111-1111-1111-1111-1111-1111'
var
  vBits:Integer;
  vExpected:Integer;
begin
  CheckEquals(0, ExtractLastBits(TESTVALUE, 0));
  for vBits := 1 to 31 do
  begin
    vExpected := Trunc(Power(2, vBits)) - 1;
    CheckEquals(vExpected, ExtractLastBits(TESTVALUE, vBits), 'Failed with bit ' + IntToStr(vBits));
  end;
end;


initialization

RegisterTest(TBitUtilsTest.Suite);

end.
