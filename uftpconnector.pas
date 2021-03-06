unit uftpconnector;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, OverbyteIcsWndControl,
  OverbyteIcsFtpCli, Vcl.forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  Tformftp = class(TForm)
    ftpc: TFtpClient;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ftpcProgress64(Sender: TObject; Count: Int64; var Abort: Boolean);
    procedure ftpcError(Sender: TObject; var Msg: string);
    procedure ftpcDisplayFile(Sender: TObject; var Msg: string);

  private
    size64: Int64;
    function getsubdirs(path: string): Tstringlist;
    function insert(filename: string): Boolean;
    function connect(): Boolean;
    function cwd(path: string): Boolean;
    function get(filename: string): Boolean;
    // function getsize(filename: string): Int64;
  public
    function getVersioninfo(pathtofile, localfile: string): Boolean;
    function movetoserver(size: Int64; path, oldfile, newfile: string): Boolean;
    function downloadsetup(setupdirection, localsetup: string): Boolean;
    function fileexists(path, newfilename: string): Boolean;
    function getfile(hostfilename, localfile: string): Boolean;
    function getupdate(hostfilename, localfile: string): Boolean;

  end;

var
  formftp: Tformftp;

implementation

uses umain;
{$R *.dfm}

function Tformftp.connect: Boolean;
begin
  if not ftpc.Connected then ftpc.connect;
  ftpc.HostDirName := '';
  cwd(ftpc.HostDirName);
  Result := ftpc.Connected;
end;

function Tformftp.cwd(path: string): Boolean;

var
  dirs: Tstringlist;
  dir : string;
begin
  dirs := getsubdirs(path);
  for dir in dirs do begin
    ftpc.HostDirName := dir;
    if not ftpc.cwd then begin
      ftpc.hostfilename := dir;
      if not ftpc.mkd then begin
        outputdebugstring('kann nicht erstellt werdne');
        exit;
      end else begin
        if not ftpc.cwd then exit;
      end;
    end;
  end;
  Result := true;
end;

function Tformftp.downloadsetup(setupdirection, localsetup: string): Boolean;
begin
  Result := false;
  try
    cwd('');
    if not connect then exit;
    if not cwd(ExtractFilePath(setupdirection)) then exit;
    ftpc.LocalFileName := localsetup;
    if not get(setupdirection) then exit;

  finally
    Result := true;
    ftpc.Quit;
  end;
end;

function Tformftp.fileexists(path, newfilename: string): Boolean;
begin
  try
    Result := false;
    if not connect then exit;
    if not cwd(path) then exit;
    ftpc.LocalFileName := '';
    ftpc.hostfilename  := newfilename;
  finally

    Result := ftpc.size;
    ftpc.Quit;
  end;
end;

procedure Tformftp.FormCreate(Sender: TObject);
begin

  ftpc.HostName := '148.251.138.2';
  ftpc.UserName := 'tiffy';
  ftpc.PassWord := 'maunze01';
  ftpc.Port     := '21';
  ftpc.Binary   := true;
end;

procedure Tformftp.ftpcDisplayFile(Sender: TObject; var Msg: string);
begin
  outputdebugstring(pchar(Msg));
end;

procedure Tformftp.ftpcError(Sender: TObject; var Msg: string);
begin
  outputdebugstring(pchar(Msg));
end;

procedure Tformftp.ftpcProgress64(Sender: TObject; Count: Int64;
  var Abort: Boolean);

var
  schritt: integer;
begin
  if size64 = 0 then size64 := 1;
  if Count = 0 then exit;
  schritt                      := round(100 / size64 * Count);
  try formmain.Gauge1.Progress := schritt;
  except

  end;

end;

function Tformftp.get(filename: string): Boolean;
begin
  ftpc.hostfilename := filename;
  // size64            := 4770816;
  size64 := 7230890;
  try
    try
      Screen.Cursor := crHourGlass;
      ftpc.get;
      Result := true;
    except

        Result := false;
    end;
  finally

      Screen.Cursor := crDefault;
  end;
end;

function Tformftp.getfile(hostfilename, localfile: string): Boolean;
var
  filename: string;
begin
  Result            := false;
  ftpc.hostfilename := '';
  ftpc.HostDirName  := '';
  ftpc.cwd;
  try

    Screen.Cursor := crHourGlass;
    if not connect then exit;
    ftpc.LocalFileName := localfile;
    if not cwd(ExtractFilePath(hostfilename)) then exit;
    filename := ExtractFileName(hostfilename);
    if not get(filename) then begin

      exit;
    end;
    Result := true;
  finally
    ftpc.Quit;
    Screen.Cursor := crDefault;
  end;
end;

// function Tformftp.getsize(filename: string): Int64;
// begin
// end;

function Tformftp.getsubdirs(path: string): Tstringlist;
var
  list: Tstringlist;
begin
  list := Tstringlist.Create;
  ExtractStrings(['\', '/'], [], pchar(path), list);
  Result := list;
end;

function Tformftp.getupdate(hostfilename, localfile: string): Boolean;
begin
  try
    ftpc.LocalFileName := localfile;
    if not connect then exit;
    if not cwd(ExtractFilePath(hostfilename)) then exit;
  finally
    Result := get(ExtractFileName(hostfilename));
    ftpc.Quit;
  end;

end;

function Tformftp.getVersioninfo(pathtofile, localfile: string): Boolean;
var
  sl: Tstringlist;
begin
  try
    ftpc.LocalFileName := localfile;
    if not connect then exit;
    if not cwd(ExtractFilePath(pathtofile)) then exit;
    if not get(ExtractFileName(pathtofile)) then exit;
  finally

    Result := true;
    ftpc.Quit;
  end;

end;

function Tformftp.insert(filename: string): Boolean;
begin
  ftpc.hostfilename := filename;
  Result            := ftpc.Put;
end;

function Tformftp.movetoserver(size: Int64;
  path, oldfile, newfile: string): Boolean;
begin
  Result := false;
  try
    ftpc.HostDirName   := '';
    size64             := size;
    ftpc.LocalFileName := oldfile;
    if not connect then begin

      ShowMessage(' keine Verbindung zum FTP Server m�glich');
      exit;
    end;
    if not cwd(path) then begin

      ShowMessage('wechseln in entsprechendes Verzeichnis ist nicht erlaubt');
      exit;
    end;
    if not insert(ExtractFileName(newfile)) then begin
      ShowMessage('eintrag nicht m�glich');
      exit;
    end;

    Result := true;
  finally ftpc.Quit;
  end;
end;

end.
