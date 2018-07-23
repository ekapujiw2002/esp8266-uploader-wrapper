Unit form_MainWindow;

Interface

Uses
     Windows,
     Messages,
     SysUtils,
     Classes,
     Graphics,
     Controls,
     Forms,
     Dialogs,
     mxStorage,
     StdCtrls,
     ExtCtrls;

Type
     Tfrm_MainWindow = Class( TForm )
          mxStorage: TmxStorage;
          Image: TImage;
          btn_Load: TButton;
          btn_Exit: TButton;
          btn_Extract: TButton;
          Procedure btn_ExitClick( Sender: TObject );
          Procedure btn_LoadClick( Sender: TObject );
          Procedure btn_ExtractClick( Sender: TObject );
          Procedure mxStorageExtractError( Sender: TObject; Path,
               FileName: String );
     Private
    { Private declarations }
     Public
    { Public declarations }
     End;

Var
     frm_MainWindow: Tfrm_MainWindow;

Implementation

{$R *.DFM}

Procedure Tfrm_MainWindow.btn_ExitClick( Sender: TObject );
Begin
     Close;
End;

Procedure Tfrm_MainWindow.btn_LoadClick( Sender: TObject );
Begin
     Image.Picture.Bitmap.LoadFromStream( mxStorage.StoredItem[ 0 ].AsStream );
End;

Procedure Tfrm_MainWindow.btn_ExtractClick( Sender: TObject );
Var
     Directory: String;
Begin
     Directory := ExtractFileDir( ParamStr( 0 ) );

     If mxStorage.ExtractTo( Directory ) Then
          MessageDlg( Format( 'Files extracted to %s', [ Directory ] ), mtError, [ mbOK ], 0 );
End;

Procedure Tfrm_MainWindow.mxStorageExtractError( Sender: TObject; Path, FileName: String );
Begin
     MessageDlg( 'Could not extract stored files....', mtError, [ mbOK ], 0 );
End;

End.

