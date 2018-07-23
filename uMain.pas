unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, mxStorage, DosCommand, StdCtrls, CPortCtl, CPort, Buttons,
  FileCtrl, Mask, rxToolEdit;

type
  TfrmMain = class(TForm)
    doscmndMain: TDosCommand;
    mxstrgMain: TmxStorage;
    btnUpload: TBitBtn;
    cbbComName: TComboBox;
    cbbComSpeed: TComboBox;
    edtFileFlashName: TFilenameEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    edtFileSPIFFSName: TFilenameEdit;
    medtFlashAddrStart: TMaskEdit;
    medtSPIFFSStartAddr: TMaskEdit;
    lbl3: TLabel;
    edtOtherOptions: TEdit;
    chkSPIFFSAutoUpload: TCheckBox;
    btnUploadSPIFFS: TBitBtn;
    lbl4: TLabel;
    mmoLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
    procedure doscmndMainNewLine(Sender: TObject; NewLine: string;
      OutputType: TOutputType);
    procedure btnUploadSPIFFSClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  ESP_TOOL_FILENAME: string;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  try
    mxstrgMain.ExtractTo(ExtractFilePath(ParamStr(0)));
    ESP_TOOL_FILENAME := ExtractFilePath(ParamStr(0)) + 'esptool.exe';
  except
    on e: Exception do
    begin
      if MessageDlg('Error at : ' + e.Message + #13#10 + 'Continue?', mtError,
        [mbYes, mbNo], MB_ICONERROR) = mrYes then
      begin
        Exit;
      end
      else
      begin
        Application.Terminate;
      end;
    end;
  end;
end;

procedure TfrmMain.btnUploadClick(Sender: TObject);
var
  cmdx: string;
begin
  try
    mmoLog.Clear;
    cmdx := Format('"%s" -vv %s -cb %u -cp "%s" -ca %s -cf %s',
      [ESP_TOOL_FILENAME, edtOtherOptions.Text, StrToIntDef(cbbComSpeed.Text,
        115200), cbbComName.Text, medtFlashAddrStart.Text,
      edtFileFlashName.Text]);

    if chkSPIFFSAutoUpload.Checked then
    begin
      cmdx := cmdx + ' -ca ' + medtSPIFFSStartAddr.Text + ' -cf ' +
        edtFileSPIFFSName.Text;
    end;

    if MessageDlg('Going to run : '#13#10 + cmdx + #13#10'Continue?', mtWarning,
      [mbYes, mbNo], MB_ICONWARNING) <> mryes then
    begin
      Exit;
    end;

    mmoLog.Lines.Add('Running command : '#13#10 + cmdx);
    with doscmndMain do
    begin
      Stop;
      CommandLine := cmdx;
      Execute;
    end;
  except
    on e: Exception do
    begin
      mmoLog.Lines.Add(e.Message);
    end;
  end;
end;

procedure TfrmMain.doscmndMainNewLine(Sender: TObject; NewLine: string;
  OutputType: TOutputType);
begin
  try
    mmoLog.Lines.Add(NewLine);
  except
    on e: Exception do
    begin
      mmoLog.Lines.Add(e.Message);
    end;
  end;
end;

procedure TfrmMain.btnUploadSPIFFSClick(Sender: TObject);
var
  cmdx: string;
begin
  try
    mmoLog.Clear;
    cmdx := Format('"%s" -vv %s -cb %u -cp "%s" -ca %s -cf %s',
      [ESP_TOOL_FILENAME, edtOtherOptions.Text, StrToIntDef(cbbComSpeed.Text,
        115200), cbbComName.Text, medtSPIFFSStartAddr.Text,
      edtFileSPIFFSName.Text]);

    if MessageDlg('Going to run : '#13#10 + cmdx + #13#10'Continue?', mtWarning,
      [mbYes, mbNo], MB_ICONWARNING) <> mryes then
    begin
      Exit;
    end;

    mmoLog.Lines.Add('Running command : '#13#10 + cmdx);
    with doscmndMain do
    begin
      Stop;
      CommandLine := cmdx;
      Execute;
    end;
  except
    on e: Exception do
    begin
      mmoLog.Lines.Add(e.Message);
    end;
  end;
end;

end.

