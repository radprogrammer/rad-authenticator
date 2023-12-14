// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.ByteArrayUtils;

interface

uses
  System.SysUtils;

function ConvertToByteArray(const pValue: Integer): TBytes; overload;
function ConvertToByteArray(const pValue: Int64): TBytes; overload;

function ByteArraysMatch(const pArray1, pArray2: TBytes): Boolean;
function ReverseByteArray(const pSource: TBytes): TBytes;

implementation

function ConvertToByteArray(const pValue: Integer): TBytes;
begin
  SetLength(Result, SizeOf(Integer));
  PInteger(@Result[0])^ := pValue;
end;

function ConvertToByteArray(const pValue: Int64): TBytes;
begin
  SetLength(Result, SizeOf(Int64));
  PInt64(@Result[0])^ := pValue;
end;

function ReverseByteArray(const pSource: TBytes): TBytes;
var
  vArrayLength: Integer;
  i: Integer;
begin
  vArrayLength := Length(pSource);
  SetLength(Result, vArrayLength);

  if vArrayLength > 0 then
    for i := Low(pSource) to High(pSource) do
      Result[High(pSource) - i] := pSource[i];
end;

function ByteArraysMatch(const pArray1, pArray2: TBytes): Boolean;
var
  vArrayLength: Integer;
begin
  vArrayLength := Length(pArray1);
  if vArrayLength = 0 then
    Result := Length(pArray2) = 0
  else
  begin
    Result := vArrayLength = Length(pArray2);

    if Result then
      Result := CompareMem(@pArray1[0], @pArray2[0], vArrayLength);
  end;
end;

end.
