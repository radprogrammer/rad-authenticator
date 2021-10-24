// Copyright 2021 Darian Miller, Licensed under Apache-2.0
// SPDX-License-Identifier: Apache-2.0
// More info: www.radprogrammer.com
unit radRTL.Base32Encoding.Tests;

interface

uses
  TestFramework;

type

  TBase32Test = class(TTestCase)
  published
    procedure TestEncodingRFCVectors;
    procedure TestDecodingRFCVectors;
    procedure TestDecoding_SkippedCharacters;
    procedure TestLongerInput_LoremIpsum;
  end;


implementation

uses
  radRTL.Base32Encoding;


// test vectors as specified in RFC
// https://datatracker.ietf.org/doc/html/rfc4648.html
procedure TBase32Test.TestEncodingRFCVectors;
begin
  CheckEquals('', TBase32.Encode(''));
  CheckEquals('MY======', TBase32.Encode('f'));
  CheckEquals('MZXQ====', TBase32.Encode('fo'));
  CheckEquals('MZXW6===', TBase32.Encode('foo'));
  CheckEquals('MZXW6YQ=', TBase32.Encode('foob'));
  CheckEquals('MZXW6YTB', TBase32.Encode('fooba'));
  CheckEquals('MZXW6YTBOI======', TBase32.Encode('foobar'));
end;


procedure TBase32Test.TestDecodingRFCVectors;
begin
  CheckEquals('', TBase32.Decode(''));
  CheckEquals('f', TBase32.Decode('MY======'));
  CheckEquals('fo', TBase32.Decode('MZXQ===='));
  CheckEquals('foo', TBase32.Decode('MZXW6==='));
  CheckEquals('foob', TBase32.Decode('MZXW6YQ='));
  CheckEquals('fooba', TBase32.Decode('MZXW6YTB'));
  CheckEquals('foobar', TBase32.Decode('MZXW6YTBOI======'));
end;


procedure TBase32Test.TestDecoding_SkippedCharacters;
begin
  //Unhandled characters are simply skipped in the current implementation
  CheckEquals('', TBase32.Decode('=1890abcdefghijklmnopqrstuvwxyz,[]()~!@#$%^&*()_+'));
end;


procedure TBase32Test.TestLongerInput_LoremIpsum;
const
  LOREM_TEXT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
               + 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
               + 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
               + 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  //manually verified from a few online decoders
  LOREM_BASE32 = 'JRXXEZLNEBUXA43VNUQGI33MN5ZCA43JOQQGC3LFOQWCAY3PNZZWKY3UMV2HK4RAMFSGS4DJONRWS3THEBSWY2LUFQQHGZLEEBSG6IDFNF2X'
                 + 'G3LPMQQHIZLNOBXXEIDJNZRWSZDJMR2W45BAOV2CA3DBMJXXEZJAMV2CAZDPNRXXEZJANVQWO3TBEBQWY2LROVQS4ICVOQQGK3TJNUQGCZ'
                 + 'BANVUW42LNEB3GK3TJMFWSYIDROVUXGIDON5ZXI4TVMQQGK6DFOJRWS5DBORUW63RAOVWGYYLNMNXSA3DBMJXXE2LTEBXGS43JEB2XIIDB'
                 + 'NRUXC5LJOAQGK6BAMVQSAY3PNVWW6ZDPEBRW63TTMVYXKYLUFYQEI5LJOMQGC5LUMUQGS4TVOJSSAZDPNRXXEIDJNYQHEZLQOJSWQZLOMR'
                 + 'SXE2LUEBUW4IDWN5WHK4DUMF2GKIDWMVWGS5BAMVZXGZJAMNUWY3DVNUQGI33MN5ZGKIDFOUQGM5LHNFQXIIDOOVWGYYJAOBQXE2LBOR2X'
                 + 'ELRAIV4GGZLQORSXK4RAONUW45BAN5RWGYLFMNQXIIDDOVYGSZDBORQXIIDON5XCA4DSN5UWIZLOOQWCA43VNZ2CA2LOEBRXK3DQMEQHC5'
                 + 'LJEBXWMZTJMNUWCIDEMVZWK4TVNZ2CA3LPNRWGS5BAMFXGS3JANFSCAZLTOQQGYYLCN5ZHK3JO';
begin
  CheckEquals(LOREM_BASE32, TBase32.Encode(LOREM_TEXT));
  CheckEquals(LOREM_TEXT, TBase32.Decode(LOREM_BASE32));

  //note: an extra unused byte may be discarded depending on padding..in this specific case 1 surplus trailing character is safely discarded
  CheckEquals(LOREM_TEXT, TBase32.Decode(LOREM_BASE32+'L'));
  //note: two extra bytes should fail...
  CheckNotEquals(LOREM_TEXT, TBase32.Decode(LOREM_BASE32+'LL'));
end;


initialization

RegisterTest(TBase32Test.Suite);


end.
