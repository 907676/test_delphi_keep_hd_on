object Form1: TForm1
  Left = 0
  Top = 0
  ClientHeight = 241
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Visible = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    635
    241)
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 32
    Top = 115
    Width = 72
    Height = 13
    Caption = #20889#20837#38388#38548'('#31186'):'
  end
  object edt1: TEdit
    Left = 32
    Top = 8
    Width = 569
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = #22266#23450#38388#38548#19968#27573#26102#38388#22312#30913#30424#20462#25913#19968#20010#25991#20214'; '#38450#27490#30828#30424#30418#36827#20837#20241#30496#29366#24577'; '#20851#38381#21518#22312#20219#21153#26639#25176#30424#36816#34892';'#21491#38190#36864#20986';'
  end
  object lbledtFile: TLabeledEdit
    Left = 32
    Top = 64
    Width = 569
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = #20462#25913#30340#25991#20214
    TabOrder = 1
    Text = 'F:\___keepHd_on.txt'
  end
  object se1: TSpinEdit
    Left = 117
    Top = 112
    Width = 121
    Height = 22
    MaxValue = 1000000
    MinValue = 5
    TabOrder = 2
    Value = 59
  end
  object chkMin: TCheckBox
    Left = 32
    Top = 161
    Width = 97
    Height = 17
    Caption = #21551#21160#26368#23567#21270
    TabOrder = 3
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 256
    Top = 104
  end
  object TrayIcon1: TTrayIcon
    Left = 168
    Top = 160
  end
  object PopupMenu1: TPopupMenu
    Left = 256
    Top = 160
    object ShowWindow1: TMenuItem
      Caption = #26174#31034
      OnClick = ShowWindow1Click
    end
    object btniSave: TMenuItem
      Caption = #20445#23384
      ShortCut = 16467
      OnClick = btniSaveClick
    end
    object N1: TMenuItem
      Caption = #20301#32622
      ShortCut = 16452
      OnClick = N1Click
    end
    object Exit1: TMenuItem
      Caption = #36864#20986
      ShortCut = 16465
      OnClick = Exit1Click
    end
  end
  object Timer2: TTimer
    Interval = 300
    OnTimer = Timer2Timer
    Left = 328
    Top = 104
  end
end
