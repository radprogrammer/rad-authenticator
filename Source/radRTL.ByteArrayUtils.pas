// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.ByteArrayUtils;

interface

uses
  System.SysUtils;


function ConvertToByteArray(const pValue:Integer):TBytes; overload;
function ConvertToByteArray(const pValue:Int64):TBytes; overload;

function ByteArraysMatch(const pArray1, pArray2:TBytes):Boolean;
function ReverseByteArray(const pSource:TBytes):TBytes;

// Best-effort scrub of a byte buffer's contents (e.g. intermediate key material).
procedure WipeBytes(var pBytes:TBytes);


implementation


function ConvertToByteArray(const pValue:Integer):TBytes;
begin
  SetLength(Result, SizeOf(Integer));
  PInteger(@Result[0])^ := pValue;
end;


function ConvertToByteArray(const pValue:Int64):TBytes;
begin
  SetLength(Result, SizeOf(Int64));
  PInt64(@Result[0])^ := pValue;
end;


function ReverseByteArray(const pSource:TBytes):TBytes;
var
  vArrayLength:Integer;
  i:Integer;
begin
  vArrayLength := Length(pSource);
  SetLength(Result, vArrayLength);

  if vArrayLength > 0 then
  begin
    for i := Low(pSource) to High(pSource) do
    begin
      Result[High(pSource) - i] := pSource[i];
    end;
  end;
end;


procedure WipeBytes(var pBytes:TBytes);
begin
  // Best-effort zeroing of sensitive buffer contents. This is not a guarantee:
  // it only scrubs THIS buffer instance, so any copies left behind by an earlier
  // reallocation (SetLength growth) are not reached, and it cannot touch
  // caller-owned buffers or immutable/reference-counted string data. Callers
  // needing stronger assurances should own the key bytes and wipe them directly.
  if Length(pBytes) > 0 then
  begin
    FillChar(pBytes[0], Length(pBytes), 0);
  end;
end;


function ByteArraysMatch(const pArray1, pArray2:TBytes):Boolean;
var
  vArrayLength:Integer;
begin
  vArrayLength := Length(pArray1);
  if vArrayLength = 0 then
  begin
    Result := Length(pArray2) = 0;
  end
  else
  begin
    Result := vArrayLength = Length(pArray2);

    if Result then
    begin
      Result := CompareMem(@pArray1[0], @pArray2[0], vArrayLength);
    end;
  end;

end;


end.
