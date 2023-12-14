// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.BitUtils;

interface

// given decimal 49 ('00110001') if you want the last 2 bits '01' then ExtractLastBits(49, 2) = 1
function ExtractLastBits(const pValue: Integer; const pBitsToExtract: Integer): Integer;

implementation

function ExtractLastBits(const pValue: Integer; const pBitsToExtract: Integer): Integer;
var
  vMask: Int64;  //Int64 to overcome "1 shl 31"
begin
  if pBitsToExtract > 0 then
  begin
    vMask := (Int64(1) shl pBitsToExtract) - 1;
    Result := pValue and (vMask and $FFFFFFFF);
  end
  else
    Result := 0;
end;

end.
