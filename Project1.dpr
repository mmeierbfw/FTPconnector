program Project1;

uses
  Vcl.Forms,
  uftpconnector in 'uftpconnector.pas' {formftp};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tformftp, formftp);
  Application.Run;
end.
