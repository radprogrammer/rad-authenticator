object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'TOTP Example'
  ClientHeight = 103
  ClientWidth = 372
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object SecretKeyLabel: TLabel
    Left = 16
    Top = 16
    Width = 85
    Height = 15
    Caption = 'Input Secret Key'
  end
  object TOTPResultLabel: TLabel
    Left = 16
    Top = 80
    Width = 56
    Height = 15
    Caption = 'OTP Result'
  end
  object SecretKey: TEdit
    Left = 112
    Top = 12
    Width = 247
    Height = 23
    TabOrder = 0
  end
  object CalculateButton: TButton
    Left = 112
    Top = 43
    Width = 179
    Height = 25
    Caption = 'Calculate One Time Password'
    Default = True
    TabOrder = 1
    OnClick = CalculateButtonClick
  end
  object OTPResult: TEdit
    Left = 112
    Top = 74
    Width = 73
    Height = 23
    ReadOnly = True
    TabOrder = 2
  end
end
