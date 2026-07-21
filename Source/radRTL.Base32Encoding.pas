// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.Base32Encoding;

interface

uses
  System.SysUtils;

type

  EBase32DecodeError = class(Exception);


  TBase32 = class
  public const
    // 32 characters, 5 Base2 digits '11111' supports complete dictionary (Base32 encoding uses 5-bit groups)
    CharactersUsedForEncoding = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    //map byte value to corresponding encoded character index value
    //This allows for easy case-insensitive decoding ("B" is mapped to 1 and "b" is mapped to 1)
    //Any invalid mapping is set to 255 and the character is skipped during the decoding process
    DecodeValues: array[0..255] of byte = (255,255,255,255,255,255,255,255,255,255,  //#0-#9
                                           255,255,255,255,255,255,255,255,255,255,  //#10-#19
                                           255,255,255,255,255,255,255,255,255,255,  //#20-#29
                                           255,255,255,255,255,255,255,255,255,255,  //#30-#39      !"#$%&'
                                           255,255,255,255,255,255,255,255,255,255,  //#40-#49   ()*+,-./01
                                            26, 27, 28, 29, 30, 31,255,255,255,255,  //#50-#59   23456789:;
                                           255,255,255,255,255,  0,  1,  2,  3,  4,  //#60-#69   <=>?@ABCDE
                                             5,  6,  7,  8,  9, 10, 11, 12, 13, 14,  //#70-#79   FGHIJKLMNO
                                            15, 16, 17, 18, 19, 20, 21, 22, 23, 24,  //#80-#89   PQRSTUVWXY
                                            25,255,255,255,255,255,255,  0,  1,  2,  //#90-#99   Z[\]^-.abc
                                             3,  4,  5,  6,  7,  8,  9, 10, 11, 12,  //#100-#109 defghijklm
                                            13, 14, 15, 16, 17, 18, 19, 20, 21, 22,  //#110-#119 nopqrstuvw
                                            23, 24, 25,255,255,255,255,255,255,255,  //#120-#129 xyz{|}~
                                           255,255,255,255,255,255,255,255,255,255,  //#130-#139
                                           255,255,255,255,255,255,255,255,255,255,  //#140-#149
                                           255,255,255,255,255,255,255,255,255,255,  //#150-#159
                                           255,255,255,255,255,255,255,255,255,255,  //#160-#169
                                           255,255,255,255,255,255,255,255,255,255,  //#170-#179
                                           255,255,255,255,255,255,255,255,255,255,  //#180-#189
                                           255,255,255,255,255,255,255,255,255,255,  //#190-#199
                                           255,255,255,255,255,255,255,255,255,255,  //#200-#209
                                           255,255,255,255,255,255,255,255,255,255,  //#210-#219
                                           255,255,255,255,255,255,255,255,255,255,  //#220-#229
                                           255,255,255,255,255,255,255,255,255,255,  //#230-#239
                                           255,255,255,255,255,255,255,255,255,255,  //#240-#249
                                           255,255,255,255,255,255);                 //#250-#255
    PadCharacter:Byte = Byte('=');  //Ord is 61
  public
    class function Encode(const pPlainText:string):string; overload;
    class function Encode(const pPlainText:string; const pEncoding:TEncoding):string; overload;
    class function Encode(const pPlainText:TBytes):TBytes; overload;
    class function Encode(const pPlainText:Pointer; const pDataLength:Integer):TBytes; overload;

    // pStrict (default False = lenient): when True, decoding raises EBase32DecodeError on any character outside the Base32 alphabet (the pad character '=' is still tolerated).
    class function Decode(const pCipherText:string; const pStrict:Boolean = False):string; overload;
    class function Decode(const pCipherText:string; const pEncoding:TEncoding; const pStrict:Boolean = False):string; overload;
    class function Decode(const pCipherText:TBytes; const pStrict:Boolean = False):TBytes; overload;
    class function Decode(const pCipherText:Pointer; const pDataLength:Integer; const pStrict:Boolean = False):TBytes; overload;
  end;


implementation

uses
  radRTL.BitUtils;


// Plain (non-constant-time) byte comparison used only to validate a lossless text round-trip in strict mode.
// Intentionally NOT ByteArraysMatch: this is not a secret-equality check (see the constant-time note in issue #14).
function SameBytes(const pArray1, pArray2:TBytes):Boolean;
begin
  Result := (Length(pArray1) = Length(pArray2)) and ((Length(pArray1) = 0) or CompareMem(@pArray1[0], @pArray2[0], Length(pArray1)));
end;


function DescribeByte(const pByte:Byte):string;
begin
  if (pByte >= 32) and (pByte <= 126) then // printable ASCII
    Result := Format('''%s'' (#%d)', [Chr(pByte), pByte])
  else
    Result := Format('#%d', [pByte]);
end;


class function TBase32.Encode(const pPlainText:string):string;
begin
  // always encode UTF8 by default to match most implementations in the wild
  Result := TBase32.Encode(pPlainText, TEncoding.UTF8);
end;

class function TBase32.Encode(const pPlainText:string; const pEncoding:TEncoding):string;
begin
  Result := pEncoding.GetString(Encode(pEncoding.GetBytes(pPlainText)));
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
      Result[vResultPosition] := Ord(TBase32.CharactersUsedForEncoding[vDictionaryIndex+1]);
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


class function TBase32.Decode(const pCipherText:string; const pStrict:Boolean = False):string;
begin
  // Default to UTF8 to match most implementations in the wild
  Result := TBase32.Decode(pCipherText, TEncoding.UTF8, pStrict);
end;

class function TBase32.Decode(const pCipherText:string; const pEncoding:TEncoding; const pStrict:Boolean = False):string;
var
  vDecoded:TBytes;
begin
  vDecoded := Decode(pEncoding.GetBytes(pCipherText), pStrict);

  if pStrict then
  begin
    // The string->string overload must not silently mangle a binary payload. Depending on the RTL/encoding an
    // invalid sequence may either be replaced (e.g. U+FFFD) or raise a low-level EEncodingError; surface both as a
    // typed EBase32DecodeError so callers get one predictable exception. (Use the TBytes overload for binary secrets.)
    try
      Result := pEncoding.GetString(vDecoded);
      if not SameBytes(pEncoding.GetBytes(Result), vDecoded) then
      begin
        raise EBase32DecodeError.Create('Base32 payload is not valid text in the target encoding; use the TBytes Decode overload for binary secrets');
      end;
    except
      on E:EEncodingError do
        raise EBase32DecodeError.Create('Base32 payload is not valid text in the target encoding; use the TBytes Decode overload for binary secrets');
    end;
  end
  else
  begin
    Result := pEncoding.GetString(vDecoded); // lenient: behavior unchanged (the RTL may itself replace or raise on invalid sequences)
  end;
end;


class function TBase32.Decode(const pCipherText:TBytes; const pStrict:Boolean = False):TBytes;
var
  vInputLength:Integer;
begin
  SetLength(Result, 0);

  vInputLength := Length(pCipherText);
  if vInputLength > 0 then
  begin
    Result := Decode(@pCipherText[0], vInputLength, pStrict);
  end;
end;


class function TBase32.Decode(const pCipherText:Pointer; const pDataLength:Integer; const pStrict:Boolean = False):TBytes;
var
  vBuffer:Integer;
  vBitsInBuffer:Integer;
  vDictionaryIndex:Byte;
  vSourcePosition:Integer;
  vResultPosition:Integer;
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
      vDictionaryIndex := DecodeValues[PByteArray(pCipherText)[vSourcePosition]];
      if vDictionaryIndex = 255 then
      begin
        if pStrict and (PByteArray(pCipherText)[vSourcePosition] <> PadCharacter) then
        begin
          // Strict mode: reject any character outside the Base32 alphabet. The pad character '=' is still
          // tolerated (skipped) here; full padding position/count validation is handled separately (issue #13).
          raise EBase32DecodeError.CreateFmt('Invalid Base32 character %s at position %d', [DescribeByte(PByteArray(pCipherText)[vSourcePosition]), vSourcePosition + 1]);
        end;
        // Lenient mode (default): skip all invalid characters.
        // (Auto-correcting commonly mistyped characters, e.g. '0'->'O', is intentionally not attempted.)
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
