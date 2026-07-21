// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.ByteArrayUtils;

interface

uses
  System.SysUtils;


function ConvertToByteArray(const pValue:Integer):TBytes; overload;
function ConvertToByteArray(const pValue:Int64):TBytes; overload;

// NOTE: value comparison only -- CompareMem short-circuits on first difference, so this is NOT constant-time.
// Do NOT use for secret/OTP comparison; use ConstantTimeEquals for that.
function ByteArraysMatch(const pArray1, pArray2:TBytes):Boolean;
function ReverseByteArray(const pSource:TBytes):TBytes;

// Best-effort scrub of a byte buffer's contents (e.g. intermediate key material).
procedure WipeBytes(var pBytes:TBytes);

// Constant-time equality: compares the full length with no early-out, so timing does not reveal how many leading
// elements matched. Use this (not ByteArraysMatch) for secret/OTP comparisons. A length mismatch returns False
// (length is not secret for OTPs); equal-length inputs are always compared in full.
function ConstantTimeEquals(const pLeft, pRight:string):Boolean; overload;
function ConstantTimeEquals(const pLeft, pRight:TBytes):Boolean; overload;


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


function ConstantTimeEquals(const pLeft, pRight:string):Boolean;
var
  i:Integer;
  vDiff:Integer;
begin
  if Length(pLeft) <> Length(pRight) then
  begin
    Result := False;
    Exit;
  end;

  vDiff := 0;
  for i := 1 to Length(pLeft) do
  begin
    vDiff := vDiff or (Ord(pLeft[i]) xor Ord(pRight[i])); // accumulate all differences; no data-dependent branch
  end;
  Result := vDiff = 0;
end;


function ConstantTimeEquals(const pLeft, pRight:TBytes):Boolean;
var
  i:Integer;
  vDiff:Integer;
begin
  if Length(pLeft) <> Length(pRight) then
  begin
    Result := False;
    Exit;
  end;

  vDiff := 0;
  for i := 0 to Length(pLeft) - 1 do
  begin
    vDiff := vDiff or (pLeft[i] xor pRight[i]);
  end;
  Result := vDiff = 0;
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
