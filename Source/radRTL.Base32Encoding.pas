// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.Base32Encoding;

interface

uses
  System.SysUtils;

type

  TBase32 = class
  public const
    // 32 characters, 5 Base2 digits '11111' supports complete dictionary (Base32 encoding uses 5-bit groups)
    Dictionary: array[0..31] of byte = (Byte('A'),
                                        Byte('B'),
                                        Byte('C'),
                                        Byte('D'),
                                        Byte('E'),
                                        Byte('F'),
                                        Byte('G'),
                                        Byte('H'),
                                        Byte('I'),
                                        Byte('J'),
                                        Byte('K'),
                                        Byte('L'),
                                        Byte('M'),
                                        Byte('N'),
                                        Byte('O'),
                                        Byte('P'),
                                        Byte('Q'),
                                        Byte('R'),
                                        Byte('S'),
                                        Byte('T'),
                                        Byte('U'),
                                        Byte('V'),
                                        Byte('W'),
                                        Byte('X'),
                                        Byte('Y'),
                                        Byte('Z'),
                                        Byte('2'),
                                        Byte('3'),
                                        Byte('4'),
                                        Byte('5'),
                                        Byte('6'),
                                        Byte('7'));

    PadCharacter:Byte = Byte('=');  //Ord is 61
  public
    class function Encode(const pPlainText:string):string; overload;
    class function Encode(const pPlainText:TBytes):TBytes; overload;
    class function Encode(const pPlainText:Pointer; const pDataLength:Integer):TBytes; overload;

    class function Decode(const pCipherText:string):string; overload;
    class function Decode(const pCipherText:TBytes):TBytes; overload;
    class function Decode(const pCipherText:Pointer; const pDataLength:Integer):TBytes; overload;
  end;


implementation

uses
  radRTL.BitUtils;


class function TBase32.Encode(const pPlainText:string):string;
begin
  // always encode UTF8 by default to match most implementations in the wild
  Result := TEncoding.UTF8.GetString(Encode(TEncoding.UTF8.GetBytes(pPlainText)));
end;


class function TBase32.Encode(const pPlainText:TBytes):TBytes;
var
  vInputLength:Integer;
begin
  SetLength(Result, 0);

  vInputLength := Length(pPlainText);
  if vInputLength > 0 then
  begin
    Result := Encode(@pPlainText[0], vInputLength);
  end;
end;


class function TBase32.Encode(const pPlainText:Pointer; const pDataLength:Integer):TBytes;
var
  vBuffer:Integer;
  vBitsInBuffer:Integer;
  vDictionaryIndex:Integer;
  vFinalPadBits:Integer;
  vSourcePosition:Integer;
  vResultPosition:Integer;
  i:Integer;
  vPadCharacters:Integer;
begin
  SetLength(Result, 0);

  if pDataLength > 0 then
  begin
    // estimate max bytes to be used (excess trimmed below)
    SetLength(Result, Trunc((pDataLength / 5) * 8) + 6 + 1); // 8 bytes out for every 5 in, +6 padding (at most), +1 for partial trailing bits if needed

    vBuffer := PByteArray(pPlainText)[0];
    vBitsInBuffer := 8;
    vSourcePosition := 1;
    vResultPosition := 0;

    while ((vBitsInBuffer > 0) or (vSourcePosition < pDataLength)) do
    begin
      if (vBitsInBuffer < 5) then // fill buffer up to 5 bits at least for next (possibly final) character
      begin
        if (vSourcePosition < pDataLength) then
        begin
          // Combine the next byte with the unused bits of the last byte
          vBuffer := (vBuffer shl 8) or PByteArray(pPlainText)[vSourcePosition];
          vBitsInBuffer := vBitsInBuffer + 8;
          vSourcePosition := vSourcePosition + 1;
        end
        else
        begin
          vFinalPadBits := 5 - vBitsInBuffer;
          vBuffer := vBuffer shl vFinalPadBits;
          vBitsInBuffer := vBitsInBuffer + vFinalPadBits;
        end;
      end;

      // Map 5-bits collected in our buffer to a Base32 encoded character
      vDictionaryIndex := $1F and (vBuffer shr (vBitsInBuffer - 5)); // $1F mask = 00011111  (last 5 are 1)
      vBitsInBuffer := vBitsInBuffer - 5;
      vBuffer := ExtractLastBits(vBuffer, vBitsInBuffer); // zero out bits we just mapped
      Result[vResultPosition] := TBase32.Dictionary[vDictionaryIndex];
      vResultPosition := vResultPosition + 1;
    end;

    // pad result based on the number of quantums received  (should be same as: "Length(pPlainText)*BitsPerByte mod BitsPerQuantum of" 8:16:24:32:)
    case pDataLength mod 5 of
      1:
        vPadCharacters := 6;
      2:
        vPadCharacters := 4;
      3:
        vPadCharacters := 3;
      4:
        vPadCharacters := 1;
    else
      vPadCharacters := 0;
    end;
    for i := 1 to vPadCharacters do
    begin
      Result[vResultPosition + i - 1] := TBase32.PadCharacter;
    end;

    // trim result to actual bytes used
    SetLength(Result, vResultPosition + vPadCharacters);
  end;

end;


class function TBase32.Decode(const pCipherText:string):string;
begin
  // always decode UTF8 by default to match most implementations in the wild
  Result := TEncoding.UTF8.GetString(Decode(TEncoding.UTF8.GetBytes(pCipherText)));
end;


class function TBase32.Decode(const pCipherText:TBytes):TBytes;
var
  vInputLength:Integer;
begin
  SetLength(Result, 0);

  vInputLength := Length(pCipherText);
  if vInputLength > 0 then
  begin
    Result := Decode(@pCipherText[0], vInputLength);
  end;
end;


class function TBase32.Decode(const pCipherText:Pointer; const pDataLength:Integer):TBytes;
var
  vBuffer:Integer;
  vBitsInBuffer:Integer;
  vDictionaryIndex:Integer;
  vSourcePosition:Integer;
  vResultPosition:Integer;
  i:Integer;
begin
  SetLength(Result, 0);

  if pDataLength > 0 then
  begin
    // estimate max bytes to be used (excess trimmed below)
    SetLength(Result, Trunc(pDataLength / 8 * 5)); // 5 bytes out for every 8 input
    vSourcePosition := 0;
    vBuffer := 0;
    vBitsInBuffer := 0;
    vResultPosition := 0;

    repeat

      vDictionaryIndex := -1;
      for i := Low(TBase32.Dictionary) to High(TBase32.Dictionary) do
      begin
        // todo: support case insensitive decoding?
        if TBase32.Dictionary[i] = PByteArray(pCipherText)[vSourcePosition] then
        begin
          vDictionaryIndex := i;
          Break;
        end;
      end;
      if vDictionaryIndex = -1 then
      begin
        // todo: Consider failing on invalid characters with Exit(EmptyStr) or Exception
        // For now, just skip all invalid characters.
        // If removing this general skip, potentially add intentional skip for '=', ' ', #9, #10, #13, '-'
        // And perhaps auto-correct commonly mistyped characters (e.g. replace '0' with 'O')
        vSourcePosition := vSourcePosition + 1;
        Continue;
      end;

      vBuffer := vBuffer shl 5; // Expand buffer to add next 5-bit group
      vBuffer := vBuffer or vDictionaryIndex; // combine the last bits collected and the next 5-bit group (Note to self: No mask needed on OR index as its known to be within range due to fixed dictionary size)
      vBitsInBuffer := vBitsInBuffer + 5;

      if vBitsInBuffer >= 8 then // Now able to fully extract an 8-bit decoded character from our bit buffer
      begin
        vBitsInBuffer := vBitsInBuffer - 8;
        Result[vResultPosition] := vBuffer shr vBitsInBuffer; // shr to hide remaining buffered bits to be used in next iteration
        vResultPosition := vResultPosition + 1;
        vBuffer := ExtractLastBits(vBuffer, vBitsInBuffer); // zero out bits already extracted from buffer
      end;

      vSourcePosition := vSourcePosition + 1;
    until vSourcePosition >= pDataLength; // NOTE: unused trailing bits, if any, are discarded (as is done in other common implementations)

    // trim result to actual bytes used (strip off preallocated space for unused, skipped input characters)
    SetLength(Result, vResultPosition);
  end;

end;

(*
  Note: https://stackoverflow.com/questions/37893325/difference-betweeen-rfc-3548-and-rfc-4648  (TLDR:minor edits)

  sample reference code:
  (Archived) https://github.com/google/google-authenticator   (Blackberry/iOS)
  (Archived) https://github.com/google/google-authenticator-android
  https://github.com/google/google-authenticator-libpam/blob/0b02aadc28ac261b6c7f5785d2f7f36b3e199d97/src/base32_prog.c
  https://github.com/freeotp/freeotp-android/blob/master/app/src/main/java/com/google/android/apps/authenticator/Base32String.java#L129
  FreeOTP uses this repo for iOS: https://github.com/norio-nomura/Base32


base32 Alphabet values:
A  0
B  1
C  2
D  3
E  4
F  5
G  6
H  7
I  8
J  9
K  10
L  11
M  12
N  13
O  14
P  15
Q  16
R  17
S  18
T  19
U  20
V  21
W  22
X  23
Y  24
Z  25
2  26
3  27
4  28
5  29
6  30
7  31

*)

end.
