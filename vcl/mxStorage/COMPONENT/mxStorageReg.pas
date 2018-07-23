// ****************************************************************************
// * mxStorage component for Delphi.
// ****************************************************************************
// * This component can be freely used and distributed in commercial and
// * private environments, provied this notice is not modified in any way.
// ****************************************************************************
// * Feel free to contact me if you have any questions, comments or suggestions
// * at support@maxcomponents.net
// ****************************************************************************
// * Web page: www.maxcomponents.net
// ****************************************************************************
// * Description:
// *
// * The TmxStorage component can store any kind of resources on your form.
// *
// ****************************************************************************

Unit mxStorageReg;

Interface

{$I MAX.INC}

// *************************************************************************************
// ** Component registration
// *************************************************************************************

Procedure Register;

Implementation

// *************************************************************************************
// ** List of used units
// *************************************************************************************

Uses SysUtils,
     Classes,
{$IFDEF Delphi6_Up}
     DesignIntf,
     DesignEditors,
{$ELSE}
     Dsgnintf,
{$ENDIF}
     Dialogs,
     Forms,
     mxStorage,
     mxStorageAbout;

Resourcestring

     rsAddFileToStorage = 'Add new file to storage';
     rsLoadError = 'Could not load resource from file.';
     rsFilesAdded = '%d file(s) added';

Type

     TDesigner = IDesigner;

{$IFDEF Delphi6_Up}
     TFormDesigner = IDesigner;
{$ELSE}
     TFormDesigner = IFormDesigner;
{$ENDIF}

// *************************************************************************************
// ** Component Editor
// *************************************************************************************

     TmxStorageEditor = Class( TComponentEditor )

          Function GetVerbCount: integer; Override;
          Function GetVerb( Index: integer ): String; Override;
          Procedure ExecuteVerb( Index: integer ); Override;
     End;

// *************************************************************************************
// ** Filename Editor
// *************************************************************************************

     TItemFileName = Class( TStringProperty )
     Public
          Function GetAttributes: TPropertyAttributes; Override;
          Procedure Edit; Override;
     End;

// *************************************************************************************
// ** GetVerbCount
// *************************************************************************************

Function TmxStorageEditor.GetVerbCount: integer;
Begin
     Result := 3;
End;

// *************************************************************************************
// ** GetVerb
// *************************************************************************************

Function TmxStorageEditor.GetVerb( Index: integer ): String;
Begin
     Case Index Of
          0: Result := 'TmxStorage (C) 2001-2008 Bitvadász Kft.';
          1: Result := '-';
          2: Result := '&Add files...';
     End;
End;

// *************************************************************************************
// ** ExecuteVerb
// *************************************************************************************

Procedure TmxStorageEditor.ExecuteVerb( Index: integer );
Var
     I: Integer;
     OpenDialog: TOpenDialog;
     StoredItem: TmxStoredItem;
Begin
     Case Index Of
          0: ShowAboutBox( 'TmxStorage' );
          2:
               Begin
                    OpenDialog := TOpenDialog.Create( Nil );
                    OpenDialog.Options := OpenDialog.Options + [ ofAllowMultiSelect ];
                    Try
                         OpenDialog.Title := rsAddFileToStorage;
                         OpenDialog.Filter := 'All files|*.*';

                         If OpenDialog.Execute Then
                         Begin
                              For I := 0 To OpenDialog.Files.Count - 1 Do
                              Begin
                                   Try
                                        StoredItem := TmxStoredItem( TmxStorage( Component ).StoredItems.Add );
                                        StoredItem.LoadFromFile( OpenDialog.Files[ I ] );
                                   Except
                                        MessageDlg( rsLoadError, mtError, [ mbOK ], 0 );
                                   End;
                              End;

                              MessageDlg( Format( rsFilesAdded, [ OpenDialog.Files.Count ] ), mtInformation, [ mbOK ], 0 );
                         End;
                    Finally
                         OpenDialog.Free;
                    End;

               End;
     End;
End;

// *************************************************************************************
// ** TItemFileName.GetAttributes, 7/19/01 3:13:32 PM
// *************************************************************************************

Function TItemFileName.GetAttributes: TPropertyAttributes;
Begin
     Result := Inherited GetAttributes + [ paDialog ];
End;

// *************************************************************************************
// ** TItemFileName.Edit, 7/19/01 3:13:30 PM
// *************************************************************************************

Procedure TItemFileName.Edit;
Var
     OpenDialog: TOpenDialog;
Begin
     OpenDialog := TOpenDialog.Create( Nil );
     Try
          OpenDialog.Title := rsAddFileToStorage;
          OpenDialog.Filter := 'All files|*.*';

          If OpenDialog.Execute Then
          Begin
               Try
                    TmxStoredItem( GetComponent( 0 ) ).LoadFromFile( OpenDialog.FileName );
                    Modified;
               Except
                    MessageDlg( rsLoadError, mtError, [ mbOK ], 0 );
               End;
          End;
     Finally
          OpenDialog.Free;
     End;
End;

// *************************************************************************************
// ** Register, 4/5/01 11:46:42 AM
// *************************************************************************************

Procedure Register;
Begin
     RegisterComponents( 'Max', [ TmxStorage ] );
     RegisterComponentEditor( TmxStorage, TmxStorageEditor );
     RegisterPropertyEditor( TypeInfo( TFileName ), TmxStoredItem, 'FileName', TItemFileName );
End;

End.

