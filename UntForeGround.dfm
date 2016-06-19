object ForeGroundFrm: TForeGroundFrm
  Left = 485
  Top = 329
  Width = 460
  Height = 360
  Caption = 'ForeGroundFrm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object FrameControl: TTimer
    Enabled = False
    Interval = 10
    OnTimer = FrameControlTimer
    Left = 328
    Top = 16
  end
end
