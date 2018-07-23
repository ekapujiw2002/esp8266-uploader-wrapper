program esp_uploader_wrapper;

uses
  Forms,
  uMain in 'uMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ESP UPLOADER WRAPPER';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
