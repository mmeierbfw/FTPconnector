object formftp: Tformftp
  Left = 0
  Top = 0
  Caption = 'formftp'
  ClientHeight = 678
  ClientWidth = 797
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ftpc: TFtpClient
    Timeout = 5000
    Port = 'ftp'
    CodePage = 0
    DataPortRangeStart = 0
    DataPortRangeEnd = 0
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    DisplayFileFlag = False
    Binary = True
    ShareMode = ftpShareExclusive
    Options = []
    ConnectionType = ftpDirect
    ProxyPort = 'ftp'
    Language = 'EN'
    OnDisplayFile = ftpcDisplayFile
    OnError = ftpcError
    OnProgress64 = ftpcProgress64
    BandwidthLimit = 10000
    BandwidthSampling = 1000
    SocketFamily = sfAny
    Left = 312
    Top = 152
  end
end
