// ****************************************************************************
// * mxStorage component for Delphi.
// ****************************************************************************
// * Copyright 2001-2005, Bitvadász Kft. All Rights Reserved.
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

Unit mxStorage;

Interface

// *************************************************************************************
// ** List of used units
// *************************************************************************************

Uses
     Windows,
     Messages,
     SysUtils,
     Classes,
     Graphics,
     Controls,
     Forms,
{$WARNINGS OFF}
     FileCtrl,
{$WARNINGS ON}
     Dialogs,
     ZLib;

{$I max.inc}

Const
     mxStorageVersion = $0115; // ** 1.21 **

Resourcestring

     sDuplicatedItemName = 'Duplicated stored item name';

Type
     TmxStoredItem = Class;
     TmxStoredItems = Class;

     // ************************************************************************
     // ************************************************************************
     // ************************************************************************

     TmxStreamEvent = Procedure( Sender: TObject; Stream: TStream ) Of Object;
     TmxExtractError = Procedure( Sender: TObject; Path: String; FileName: String ) Of Object;
     TmxBeforeExtract = Procedure( Sender: TObject; Var Path: String; Var FileName: String; Var CanExtract: Boolean ) Of Object;
     TmxAfterExtract = Procedure( Sender: TObject; Path: String; FileName: String ) Of Object;

     // ************************************************************************
     // ************************************************************************
     // ************************************************************************

     TmxStorage = Class( TComponent )
     Private

          FVersion: Integer;
          FStoredItems: TmxStoredItems;

          FOnExtractError: TmxExtractError;
          FOnBeforeExtract: TmxBeforeExtract;
          FOnAfterExtract: TmxAfterExtract;

          Procedure SetVersion( Value: String );
          Function GetVersion: String;

          Procedure SetItems( Value: TmxStoredItems );
          Function GetItems: TmxStoredItems;
          Function GetItem( Index: Integer ): TmxStoredItem;

          Function GetSize: Integer;
          Function GetOriginalSize: Integer;
          Procedure SetSize( Value: Integer );

          Function GetRatio: String;
          Procedure SetRatio( Value: String );

     Protected

     Public

          Constructor Create( AOwner: TComponent ); Override;
          Destructor Destroy; Override;

          Property StoredItem[ Index: Integer ]: TmxStoredItem Read GetItem;
          Function ItemByIndex( Index: Integer ): TmxStoredItem;
          Function ItemByName( Name: String ): TmxStoredItem;
          Function ItemByFileName( FileName: TFileName ): TmxStoredItem;

          Property TotalSize: Integer Read GetSize;

          Function ExtractTo( Path: String ): Boolean;

     Published

          Property OriginalSize: Integer Read GetOriginalSize Write SetSize;
          Property Ratio: String Read GetRatio Write SetRatio;
          Property Size: Integer Read GetSize Write SetSize;
          Property StoredItems: TmxStoredItems Read GetItems Write SetItems;
          Property Version: String Read GetVersion Write SetVersion;

          Property OnExtractError: TmxExtractError Read FOnExtractError Write FOnExtractError;
          Property OnBeforeExtract: TmxBeforeExtract Read FOnBeforeExtract Write FOnBeforeExtract;
          Property OnAfterExtract: TmxAfterExtract Read FOnAfterExtract Write FOnAfterExtract;
     End;

     // ************************************************************************
     // ************************************************************************
     // ************************************************************************

     TmxStoredItem = Class( TCollectionItem )
     Private

          FTag: Integer;
          FName: String;
          FFileName: TFileName;
          FFileSize: Integer;
          FData: TMemoryStream;
          FCompression: TCompressionLevel;

          FOnCreate: TNotifyEvent;
          FOnDestroy: TNotifyEvent;
          FOnBeforeLoad: TmxStreamEvent;
          FOnBeforeSave: TmxStreamEvent;
          FOnAfterLoad: TNotifyEvent;
          FOnAfterSave: TNotifyEvent;

          Procedure SetFileName( Value: TFileName );
          Function GetSize: Integer;
          Function GetDataStream: TStream;
          Procedure SetSize( Value: Integer );
          Procedure SetFileSize( Value: Integer );
          Procedure SetCompression( Value: TCompressionLevel );

          Function GetRatio: String;
          Procedure SetRatio( Value: String );

          Procedure ReadStoredItem( Stream: TStream );
          Procedure WriteStoredItem( Stream: TStream );

     Protected

          Function GetDisplayName: String; Override;
          Procedure SetDisplayName( Const Value: String ); Override;
          Procedure DefineProperties( Filer: TFiler ); Override;

     Public

          Constructor Create( Collection: TCollection ); Override;
          Destructor Destroy; Override;

          Procedure AssignTo( Dest: TPersistent ); Override;

          Property AsStream: TStream Read GetDataStream;

          Procedure SaveToStream( Stream: TStream );
          Procedure LoadFromStream( Stream: TStream );
          Procedure SaveToFile( FileName: String );
          Procedure LoadFromFile( FileName: String );

     Published

          Property OnCreate: TNotifyEvent Read FOnCreate Write FOnCreate;
          Property OnDestroy: TNotifyEvent Read FOnDestroy Write FOnDestroy;
          Property OnBeforeLoad: TmxStreamEvent Read FOnBeforeLoad Write FOnBeforeLoad;
          Property OnBeforeSave: TmxStreamEvent Read FOnBeforeSave Write FOnBeforeSave;
          Property OnAfterLoad: TNotifyEvent Read FOnAfterLoad Write FOnAfterLoad;
          Property OnAfterSave: TNotifyEvent Read FOnAfterSave Write FOnAfterSave;

          Property Compression: TCompressionLevel Read FCompression Write SetCompression Default clDefault;
          Property Tag: Integer Read FTag Write FTag;
          Property Name: String Read GetDisplayName Write SetDisplayName;
          Property FileName: TFileName Read FFileName Write SetFileName;
          Property FileSize: Integer Read FFileSize Write SetFileSize;
          Property Size: Integer Read GetSize Write SetSize;
          Property Ratio: String Read GetRatio Write SetRatio;

     End;

     // ************************************************************************
     // ************************************************************************
     // ************************************************************************

     TmxStoredItems = Class( TCollection )
     Private

          FStorage: TmxStorage;

          Function GetStoredItem( Index: Integer ): TmxStoredItem;
          Procedure SetStoredItem( Index: Integer; Value: TmxStoredItem );

     Protected

          Function GetAttrCount: Integer; Override;
          Function GetAttr( Index: Integer ): String; Override;
          Function GetItemAttr( Index, ItemIndex: Integer ): String; Override;
          Function GetHost: TPersistent;
          Procedure SetItemName( Item: TCollectionItem ); Override;
          Procedure Update( Item: TCollectionItem ); Override;
          Function GetOwner: TPersistent; Override;

     Public

          Constructor Create( AStorage: TmxStorage; ItemClass: TCollectionItemClass );

          Function Add: TmxStoredItem;
          Property Storage: TmxStorage Read FStorage;
          Property Items[ Index: Integer ]: TmxStoredItem Read GetStoredItem Write SetStoredItem; Default;

     End;

Implementation

// *************************************************************************************
// *************************************************************************************
// *************************************************************************************
// ** TmxStorage.Create, 7/19/01 1:55:20 PM
// *************************************************************************************
// *************************************************************************************
// *************************************************************************************

Constructor TmxStorage.Create( AOwner: TComponent );
Begin
     Inherited Create( AOwner );

     FStoredItems := TmxStoredItems.Create( Self, TmxStoredItem );
     FVersion := mxStorageVersion;
End;

// *************************************************************************************
// ** TmxStorage.Destroy, 7/19/01 1:55:18 PM
// *************************************************************************************

Destructor TmxStorage.Destroy;
Begin
     FStoredItems.Free;
     Inherited Destroy;
End;

// *************************************************************************************
// ** TmxStorage.SetVersion, 7/19/01 1:55:58 PM
// *************************************************************************************

Procedure TmxStorage.SetVersion( Value: String );
Begin
        // *** Does nothing ***
End;

// *************************************************************************************
// ** TmxStorage.GetVersion, 7/19/01 1:55:56 PM
// *************************************************************************************

Function TmxStorage.GetVersion: String;
Begin
{$WARNINGS OFF}
     Result := Format( '%d.%d', [ Hi( FVersion ), Lo( FVersion ) ] );
{$WARNINGS ON}
End;

// *************************************************************************************
// ** TmxStorage.GetItems, 7/19/01 2:27:49 PM
// *************************************************************************************

Function TmxStorage.GetItems: TmxStoredItems;
Begin
     Result := FStoredItems;
End;

// *************************************************************************************
// ** TmxStorage.SetItems, 7/19/01 2:28:18 PM
// *************************************************************************************

Procedure TmxStorage.SetItems( Value: TmxStoredItems );
Begin
     FStoredItems.Assign( Value );
End;

// *************************************************************************************
// ** TmxStorage.GetItem, 7/19/01 2:29:32 PM
// *************************************************************************************

Function TmxStorage.GetItem( Index: Integer ): TmxStoredItem;
Begin
     Result := Nil;
     If Index > FStoredItems.Count Then Exit;
     Result := FStoredItems[ Index ];
End;

// *************************************************************************************
// ** TmxStorage.ItemByIndex, 7/19/01 4:10:46 PM
// *************************************************************************************

Function TmxStorage.ItemByIndex( Index: Integer ): TmxStoredItem;
Begin
     Result := GetItem( Index );
End;

// *************************************************************************************
// ** TmxStorage.ItemByName, 7/19/01 4:12:32 PM
// *************************************************************************************

Function TmxStorage.ItemByName( Name: String ): TmxStoredItem;
Var
     I: Integer;
Begin
     Result := Nil;

     For I := 0 To FStoredItems.Count - 1 Do
     Begin
          If AnsiCompareText( FStoredItems[ I ].Name, Name ) = 0 Then
          Begin
               Result := FStoredItems[ I ];
               Break;
          End;
     End;
End;

// *************************************************************************************
// ** TmxStorage.ItemByFileName, 7/19/01 4:12:30 PM
// *************************************************************************************

Function TmxStorage.ItemByFileName( FileName: TFileName ): TmxStoredItem;
Var
     I: Integer;
Begin
     Result := Nil;

     For I := 0 To FStoredItems.Count - 1 Do
     Begin
          If AnsiCompareText( FStoredItems[ I ].FileName, FileName ) = 0 Then
          Begin
               Result := FStoredItems[ I ];
               Break;
          End;
     End;
End;

// *************************************************************************************
// ** TmxStorage.GetSize, 7/19/01 3:04:33 PM
// *************************************************************************************

Function TmxStorage.GetSize: Integer;
Var
     I: Integer;
Begin
     Result := 0;
     For I := 0 To FStoredItems.Count - 1 Do Result := Result + StoredItem[ I ].Size;
End;

// *************************************************************************************
// ** TmxStorage.GetOriginalSize, 7/20/01 9:06:48 AM
// *************************************************************************************

Function TmxStorage.GetOriginalSize: Integer;
Var
     I: Integer;
Begin
     Result := 0;
     For I := 0 To FStoredItems.Count - 1 Do Result := Result + StoredItem[ I ].FileSize;
End;

// *************************************************************************************
// ** TmxStorage.SetSize, 7/19/01 3:04:04 PM
// *************************************************************************************

Procedure TmxStorage.SetSize( Value: Integer );
Begin
        // *** Does Nothing ***
End;

// *************************************************************************************
// ** TmxStorage.GetRatio, 7/20/01 9:09:21 AM
// *************************************************************************************

Function TmxStorage.GetRatio: String;
Begin
     If OriginalSize = 0 Then
          Result := '100%' Else
          Result := Format( '%f', [ ( Size / OriginalSize ) * 100 ] ) + '%';
End;

// *************************************************************************************
// ** TmxStorage.SetRatio, 7/20/01 9:08:20 AM
// *************************************************************************************

Procedure TmxStorage.SetRatio( Value: String );
Begin
     // *** Does Nothing ***
End;

// *************************************************************************************
// ** TmxStorage.ExtractTo, 7/20/01 9:10:19 AM
// *************************************************************************************

Function TmxStorage.ExtractTo( Path: String ): Boolean;
Var
     I: Integer;
     OutPath: String;
     OutFileName: String;
     CanExtract: Boolean;
Begin
     Result := TRUE;
     For I := 0 To FStoredItems.Count - 1 Do
     Begin
{$WARNINGS OFF}
          OutPath := IncludeTrailingBackslash( Path );
{$WARNINGS ON}
          OutFileName := StoredItem[ I ].FileName;
          CanExtract := TRUE;

          If Assigned( FOnBeforeExtract ) Then FOnBeforeExtract( Self, OutPath, OutFileName, CanExtract );

          If CanExtract Then
               If ForceDirectories( Path ) Then
               Begin
                    Try
                         StoredItem[ I ].SaveToFile( OutPath + OutFileName );
                    Except
                         If Assigned( FOnExtractError ) Then FOnExtractError( Self, Path, StoredItem[ I ].FileName );
                         Result := FALSE;
                         Continue;
                    End;

                    If Assigned( FOnAfterExtract ) Then FOnAfterExtract( Self, OutPath, OutFileName );
               End
     End;
End;

// *************************************************************************************
// *************************************************************************************
// *************************************************************************************
//** TmxStoredItem.Create, 7/19/01 2:07:31 PM
// *************************************************************************************
// *************************************************************************************
// *************************************************************************************

Constructor TmxStoredItem.Create( Collection: TCollection );
Begin
     Inherited Create( Collection );
     FData := TMemoryStream.Create;
     FCompression := clDefault;
     FFileName := '';
     FTag := 0;

     If Assigned( FOnCreate ) Then FOnCreate( Self );
End;

// *************************************************************************************
// ** TmxStoredItem.Destroy, 7/19/01 2:08:15 PM
// *************************************************************************************

Destructor TmxStoredItem.Destroy;
Begin
     FData.Free;
     Inherited Destroy;

     If Assigned( FOnDestroy ) Then FOnDestroy( Self );
End;

// *************************************************************************************
// ** TmxStoredItem.DefineProperties, 7/19/01 3:44:49 PM
// *************************************************************************************

Procedure TmxStoredItem.DefineProperties( Filer: TFiler );
Begin
     Inherited DefineProperties( Filer );
     Filer.DefineBinaryProperty( 'StoredItem', ReadStoredItem, WriteStoredItem, Assigned( FData ) And ( FData.Size > 0 ) );
End;

// *************************************************************************************
// ** TmxStoredItem.ReadStoredItem, 7/19/01 3:46:59 PM
// *************************************************************************************

Procedure TmxStoredItem.ReadStoredItem( Stream: TStream );
Var
     Len: Integer;
Begin
     FData.Clear;
     Stream.Read( Len, SizeOf( Integer ) );
     FData.Size := Len;
     FData.CopyFrom( Stream, Len );
End;

// *************************************************************************************
// ** TmxStoredItem.WriteStoredItem, 7/19/01 3:46:56 PM
// *************************************************************************************

Procedure TmxStoredItem.WriteStoredItem( Stream: TStream );
Var
     Len: Integer;
Begin
     FData.Position := 0;
     Len := FData.Size;
     Stream.Write( Len, SizeOf( Integer ) );
     Stream.CopyFrom( FData, FData.Size );
End;

// *************************************************************************************
// ** TmxStoredItem.AssignTo, 7/19/01 2:17:45 PM
// *************************************************************************************

Procedure TmxStoredItem.AssignTo( Dest: TPersistent );
Begin
     If Dest Is TmxStoredItem Then
     Begin
          If Assigned( Collection ) Then Collection.BeginUpdate;
          Try
               With TmxStoredItem( Dest ) Do
               Begin
                    FTag := Self.Tag;
                    Self.FData.Clear;
                    Self.FData.LoadFromStream( FData );
               End;
          Finally
               If Assigned( Collection ) Then Collection.EndUpdate;
          End;
     End
     Else Inherited AssignTo( Dest );
End;

// *************************************************************************************
// ** TmxStoredItem.GetDisplayName, 7/19/01 2:19:11 PM
// *************************************************************************************

Function TmxStoredItem.GetDisplayName: String;
Begin
     Result := FName;
End;

// *************************************************************************************
// ** TmxStoredItem.SetDisplayName, 7/19/01 2:19:08 PM
// *************************************************************************************

Procedure TmxStoredItem.SetDisplayName( Const Value: String );
Var
     I: Integer;
     Item: TmxStoredItem;
Begin
     If AnsiCompareText( Value, FName ) <> 0 Then
     Begin
          If Collection <> Nil Then
               For I := 0 To Collection.Count - 1 Do
               Begin
                    Item := TmxStoredItems( Collection ).Items[ I ];
                    If ( Item <> Self ) And ( Item Is TmxStoredItem ) And
                         ( AnsiCompareText( Value, Item.Name ) = 0 ) Then Raise Exception.Create( sDuplicatedItemName );
               End;
          FName := Value;
          Changed( False );
     End;
End;

// *************************************************************************************
// ** TmxStoredItem.SetFileName, 7/19/01 2:58:07 PM
// *************************************************************************************

Procedure TmxStoredItem.SetFileName( Value: TFileName );
Begin
     If csLoading In TmxStoredItems( GetOwner ).Storage.ComponentState Then FFileName := Value;
End;

// *************************************************************************************
// ** TmxStoredItem.SetFileSize, 7/20/01 8:49:55 AM
// *************************************************************************************

Procedure TmxStoredItem.SetFileSize( Value: Integer );
Begin
     If csLoading In TmxStoredItems( GetOwner ).Storage.ComponentState Then FFileSize := Value;
End;

// *************************************************************************************
// ** TmxStoredItem.GetSize, 7/19/01 3:06:29 PM
// *************************************************************************************

Function TmxStoredItem.GetSize: Integer;
Begin
     Result := FData.Size;
End;

// *************************************************************************************
// ** TmxStoredItem.GetRatio, 7/20/01 8:53:28 AM
// *************************************************************************************

Function TmxStoredItem.GetRatio: String;
Begin
     If FFileSize = 0 Then
          Result := '100%' Else
          Result := Format( '%f', [ ( Size / FFileSize ) * 100 ] ) + '%';
End;

// *************************************************************************************
// ** TmxStoredItem.SetRatio, 7/20/01 8:53:33 AM
// *************************************************************************************

Procedure TmxStoredItem.SetRatio( Value: String );
Begin
     // *** Does Nothing ***
End;

// *************************************************************************************
// ** TmxStoredItem.SetSize, 7/19/01 3:06:26 PM
// *************************************************************************************

Procedure TmxStoredItem.SetSize( Value: Integer );
Begin
        // *** Does Nothing ***
End;

// *************************************************************************************
// ** TmxStoredItem.GetDataStream, 7/20/01 7:59:16 AM
// *************************************************************************************

Function TmxStoredItem.GetDataStream: TStream;
Begin
     SetCompression( clNone );
     FData.Position := 0;
     Result := FData;
End;

// *************************************************************************************
// ** TmxStoredItem.SetCompression, 7/19/01 3:30:11 PM
// *************************************************************************************

Procedure TmxStoredItem.SetCompression( Value: TCompressionLevel );
Var
     MemoryStream: TMemoryStream;
Begin
     If csLoading In TmxStoredItems( GetOwner ).Storage.ComponentState Then
     Begin
          FCompression := Value;
     End
     Else
          If FCompression <> Value Then
          Begin
               MemoryStream := TMemoryStream.Create;
               Try
                    SaveToStream( MemoryStream );
                    FCompression := Value;
                    LoadFromStream( MemoryStream );
               Finally
                    MemoryStream.Free;
               End;
          End;

End;

// *************************************************************************************
// ** TmxStoredItem.SaveToStream, 7/19/01 3:22:59 PM
// *************************************************************************************

Procedure TmxStoredItem.SaveToStream( Stream: TStream );
Var
     DecompressionStream: TDecompressionStream;
     Len: Integer;
Begin
     If Stream = Nil Then Exit;
     FData.Position := 0;

     If Assigned( FOnBeforeSave ) Then FOnBeforeSave( Self, Stream );

     If ( FCompression <> clNone ) And ( FData.Size > 0 ) Then
     Begin
          DecompressionStream := TDecompressionStream.Create( FData );
          Try
               DecompressionStream.Read( Len, SizeOf( Integer ) );
               If Len <> 0 Then Stream.CopyFrom( DecompressionStream, Len );
          Finally
               DecompressionStream.Free;
          End;
     End Else Stream.CopyFrom( FData, FData.Size );

     If Assigned( FOnAfterSave ) Then FOnAfterSave( Self );
End;

// *************************************************************************************
// ** TmxStoredItem.LoadFromStream, 7/19/01 3:23:07 PM
// *************************************************************************************

Procedure TmxStoredItem.LoadFromStream( Stream: TStream );
Var
     Len: Integer;
     DecompressionStream: TCompressionStream;
Begin
     FData.Clear;
     If Stream = Nil Then Exit;
     If Stream.Size = 0 Then Exit;
     Stream.Position := 0;

     If Assigned( FOnBeforeLoad ) Then FOnBeforeLoad( Self, Stream );

     If FCompression <> clNone Then
     Begin
          DecompressionStream := TCompressionStream.Create( FCompression, FData );
          Try
               Len := Stream.Size;
               DecompressionStream.Write( Len, SizeOf( Integer ) );
               DecompressionStream.CopyFrom( Stream, Len );
               FFileSize := Len;
          Finally
               DecompressionStream.Free;
          End;
     End Else FData.CopyFrom( Stream, 0 );

     If Assigned( FOnAfterLoad ) Then FOnAfterLoad( Self );
End;

// *************************************************************************************
// ** TmxStoredItem.SaveToFile, 7/19/01 3:23:13 PM
// *************************************************************************************

Procedure TmxStoredItem.SaveToFile( FileName: String );
Var
     FileStream: TFileStream;
Begin
     FileStream := TFileStream.Create( FileName, fmCreate );
     Try
          SaveToStream( FileStream );
     Finally
          FileStream.Free;
     End;
End;

// *************************************************************************************
// ** TmxStoredItem.LoadFromFile, 7/19/01 3:23:17 PM
// *************************************************************************************

Procedure TmxStoredItem.LoadFromFile( FileName: String );
Var
     FileStream: TFileStream;
Begin
     FileStream := TFileStream.Create( FileName, fmOpenRead Or fmShareDenyNone );
     Try
          LoadFromStream( FileStream );
          FFileName := ExtractFileName( FileName );
     Finally
          FileStream.Free;
     End;
End;

// *************************************************************************************
// *************************************************************************************
// *************************************************************************************
// ** TmxStoredItems.Create, 7/19/01 2:10:40 PM
// *************************************************************************************
// *************************************************************************************
// *************************************************************************************

Constructor TmxStoredItems.Create( AStorage: TmxStorage; ItemClass: TCollectionItemClass );
Begin
     Inherited Create( ItemClass );
     FStorage := AStorage;
End;

// *************************************************************************************
// ** TmxStoredItems.GetOwner, 5/9/01 3:53:21 PM
// *************************************************************************************

Function TmxStoredItems.GetOwner: TPersistent;
Begin
     Result := FStorage;
End;

// *************************************************************************************
// ** TmxStoredItems.Add, 5/7/01 4:38:16 PM
// *************************************************************************************

Function TmxStoredItems.Add: TmxStoredItem;
Begin
     Result := TmxStoredItem( Inherited Add );
End;

// *************************************************************************************
// ** TmxStoredItems.GetStoredItem, 7/19/01 2:13:17 PM
// *************************************************************************************

Function TmxStoredItems.GetStoredItem( Index: Integer ): TmxStoredItem;
Begin
     Result := TmxStoredItem( Inherited Items[ Index ] );
End;

// *************************************************************************************
// ** TmxStoredItems.GetAttrCount, 5/7/01 4:38:21 PM
// *************************************************************************************

Function TmxStoredItems.GetAttrCount: Integer;
Begin
     Result := 1;
End;

// *************************************************************************************
// ** TmxStoredItems.GetAttr, 5/7/01 4:38:23 PM
// *************************************************************************************

Function TmxStoredItems.GetAttr( Index: Integer ): String;
Begin
     Case Index Of
          0: Result := 'Name';
     Else
          Result := '';
     End;
End;

// *************************************************************************************
// ** TmxStoredItems.GetItemAttr, 5/7/01 4:38:26 PM
// *************************************************************************************

Function TmxStoredItems.GetItemAttr( Index, ItemIndex: Integer ): String;
Begin
     Case Index Of
          0: Result := Items[ ItemIndex ].Name;
     Else
          Result := '';
     End;
End;

// *************************************************************************************
// ** TmxStoredItems.GetHost, 5/9/01 12:39:46 PM
// *************************************************************************************

Function TmxStoredItems.GetHost: TPersistent;
Begin
     Result := FStorage;
End;

// *************************************************************************************
// ** TmxStoredItems.SetActionItem, 5/7/01 4:32:29 PM
// *************************************************************************************

Procedure TmxStoredItems.SetStoredItem( Index: Integer; Value: TmxStoredItem );
Begin
     Items[ Index ].Assign( Value );
End;

// *************************************************************************************
// ** TmxStoredItems.SetItemName, 5/7/01 4:32:34 PM
// *************************************************************************************

Procedure TmxStoredItems.SetItemName( Item: TCollectionItem );
Var
     I, J: Integer;
     ItemName: String;
     CurItem: TmxStoredItem;
Begin
     J := 1;
     While True Do
     Begin
          ItemName := Format( 'mxStoredItem%d', [ J ] );
          I := 0;
          While I < Count Do
          Begin
               CurItem := Items[ I ] As TmxStoredItem;
               If ( CurItem <> Item ) And ( CompareText( CurItem.Name, ItemName ) = 0 ) Then
               Begin
                    Inc( J );
                    Break;
               End;
               Inc( I );
          End;
          If I >= Count Then
          Begin
               ( Item As TmxStoredItem ).Name := ItemName;
               Break;
          End;
     End;
End;

// *************************************************************************************
// ** TmxStoredItems.Update, 7/19/01 2:14:55 PM
// *************************************************************************************

Procedure TmxStoredItems.Update( Item: TCollectionItem );
Begin
End;

End.

