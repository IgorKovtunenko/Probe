object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SysInfo collector'
  ClientHeight = 134
  ClientWidth = 503
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 371
    Top = 0
    Height = 134
    Align = alRight
    ExplicitLeft = 597
    ExplicitTop = -8
    ExplicitHeight = 423
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 371
    Height = 134
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitWidth = 589
    ExplicitHeight = 423
    object Memo: TMemo
      Left = 1
      Top = 1
      Width = 369
      Height = 132
      Align = alClient
      Lines.Strings = (
        '')
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
      ExplicitWidth = 587
      ExplicitHeight = 421
    end
  end
  object Panel2: TPanel
    Left = 374
    Top = 0
    Width = 129
    Height = 134
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 592
    ExplicitHeight = 423
    object btCollect: TButton
      Left = 30
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Collect'
      TabOrder = 0
      OnClick = btCollectClick
    end
    object btSend: TButton
      Left = 30
      Top = 47
      Width = 75
      Height = 25
      Caption = 'Send'
      TabOrder = 1
      OnClick = btSendClick
    end
    object btExit: TButton
      Left = 30
      Top = 78
      Width = 75
      Height = 25
      Caption = 'Exit'
      TabOrder = 2
      OnClick = btExitClick
    end
  end
  object IdHTTP: TIdHTTP
    AllowCookies = True
    ProtocolVersion = pv1_0
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 264
    Top = 168
  end
end
