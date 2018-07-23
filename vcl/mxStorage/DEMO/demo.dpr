program Demo;

uses
  Forms,
  form_MainWindow in 'form_MainWindow.pas' {frm_MainWindow};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_MainWindow, frm_MainWindow);
  Application.Run;
end.
