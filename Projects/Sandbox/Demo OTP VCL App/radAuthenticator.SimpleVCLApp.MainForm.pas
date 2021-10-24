unit radAuthenticator.SimpleVCLApp.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm3 = class(TForm)
    SecretKeyLabel: TLabel;
    SecretKey: TEdit;
    CalculateButton: TButton;
    TOTPResultLabel: TLabel;
    OTPResult: TEdit;
    procedure CalculateButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation
uses
  radRTL.TOTP;


{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin
  SecretKey.Text := 'IVXWIVDJHFUEE3TPPFHDCMCHNZSSWT2R';  //actual demo account key to aid in debugging
end;


procedure TForm3.CalculateButtonClick(Sender: TObject);
begin
  OTPResult.Text := TTOTP.GeneratePassword(SecretKey.Text);
end;


end.
