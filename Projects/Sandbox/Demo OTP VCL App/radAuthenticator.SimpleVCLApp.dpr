program radAuthenticator.SimpleVCLApp;

uses
  Vcl.Forms,
  radAuthenticator.SimpleVCLApp.MainForm in 'radAuthenticator.SimpleVCLApp.MainForm.pas' {Form3},
  radRTL.Base32Encoding in '..\..\..\Source\radRTL.Base32Encoding.pas',
  radRTL.BitUtils in '..\..\..\Source\radRTL.BitUtils.pas',
  radRTL.ByteArrayUtils in '..\..\..\Source\radRTL.ByteArrayUtils.pas',
  radRTL.HOTP in '..\..\..\Source\radRTL.HOTP.pas',
  radRTL.TOTP in '..\..\..\Source\radRTL.TOTP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
