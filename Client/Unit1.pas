unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  System.RegularExpressions, System.Hash, System.Threading,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls, System.Rtti,
  FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, REST.Types, Data.Bind.EngExt, FMX.Bind.DBEngExt,
  FMX.Bind.Grid, System.Bindings.Outputs, FMX.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  REST.Client, REST.Response.Adapter, REST.Json, Data.DBXJSONReflect,
  Data.Bind.ObjectScope, Data.Bind.Controls,
  FMX.Layouts, FMX.Bind.Navigator, FMX.Memo.Types, FMX.Memo,
  FireDAC.Stan.StorageJSON, FireDAC.Stan.Async, FireDAC.DApt;

const
  // The BaseURL used by all requests in this project
  // cURL = 'http://127.0.0.1:8080/demo%20script/services.php';
  cURL = 'http://127.0.0.1:8080/edsa-demoscript/services.php';

type
  TForm1 = class(TForm)
    TCMain: TTabControl;
    TabLogin: TTabItem;
    TabRegister: TTabItem;
    TabDashboard: TTabItem;
    TCDashboard: TTabControl;
    TabCustomers: TTabItem;
    TabProfile: TTabItem;
    TabUsers: TTabItem;
    TableProfile: TFDMemTable;
    TableCustomers: TFDMemTable;
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    BindingsList1: TBindingsList;
    BindSourceDB2: TBindSourceDB;
    TableProfileId: TAutoIncField;
    TableProfileName: TWideStringField;
    TableProfileEmail: TWideStringField;
    TableProfilePass: TWideStringField;
    TableProfileCapabilities: TIntegerField;
    TableCustomersId: TAutoIncField;
    TableCustomersName: TWideStringField;
    TableCustomersContact: TWideStringField;
    TableCustomersAddress: TWideStringField;
    TableCustomersCity: TWideStringField;
    TableCustomersPostal: TWideStringField;
    TableCustomersCountry: TWideStringField;
    ToolBar3: TToolBar;
    BtnBackToLogin: TSpeedButton;
    Label10: TLabel;
    ToolBar4: TToolBar;
    Label11: TLabel;
    VertScrollBox1: TVertScrollBox;
    Label1: TLabel;
    EditUsername: TEdit;
    Label2: TLabel;
    EditPassword: TEdit;
    PasswordEditButton1: TPasswordEditButton;
    BtnLogin: TButton;
    Label3: TLabel;
    BtnRegister: TButton;
    VertScrollBox2: TVertScrollBox;
    Label4: TLabel;
    EditRegisterName: TEdit;
    Label6: TLabel;
    EditRegisterEmail: TEdit;
    Label5: TLabel;
    EditRegisterPassword: TEdit;
    PasswordEditButton2: TPasswordEditButton;
    BtnCreateAccount: TButton;
    TableUsers: TFDMemTable;
    AutoIncField1: TAutoIncField;
    WideStringField1: TWideStringField;
    WideStringField2: TWideStringField;
    WideStringField3: TWideStringField;
    IntegerField1: TIntegerField;
    VertScrollBox3: TVertScrollBox;
    BtnLogout: TButton;
    BtnUpdateProfile: TButton;
    EditProfileConfimPassword: TEdit;
    PasswordEditButton3: TPasswordEditButton;
    Label9: TLabel;
    EditProfileEmail: TEdit;
    Label8: TLabel;
    EditProfileName: TEdit;
    Label7: TLabel;
    BindSourceDB3: TBindSourceDB;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    Label12: TLabel;
    EditProfileNewPassword: TEdit;
    PasswordEditButton4: TPasswordEditButton;
    NavigatorBindSourceDB2: TBindNavigator;
    RESTResponseDataSetAdapter: TRESTResponseDataSetAdapter;
    BindSourceDB1: TBindSourceDB;
    GridCustomers: TGrid;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    GridUsers: TGrid;
    LinkGridToDataSourceBindSourceDB22: TLinkGridToDataSource;
    NavigatorBindSourceDB1: TBindNavigator;
    procedure FormCreate(Sender: TObject);
    procedure BtnRegisterClick(Sender: TObject);
    procedure BtnBackToLoginClick(Sender: TObject);
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnCreateAccountClick(Sender: TObject);
    procedure BtnUpdateProfileClick(Sender: TObject);
    procedure BtnLogoutClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure GetCustomers;
    procedure GetUsers;
    function DataSetToJSON(ADataSet: TDataSet): string;
    function DataSetRecordToJSON(ADataSet: TDataSet): string;

  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.BtnBackToLoginClick(Sender: TObject);
begin
  TCMain.SetActiveTabWithTransitionAsync(TabLogin, TTabTransition.Slide,
    TTabTransitionDirection.Reversed, nil);
end;

procedure TForm1.BtnCreateAccountClick(Sender: TObject);

begin
  if (EditRegisterName.Text <> '') and
     (EditRegisterEmail.Text <> '') and
     (EditRegisterPassword.Text <> '') then

  begin
    // Check email address
    if TRegEx.IsMatch(EditRegisterEmail.Text,
      '^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]*[a-zA-Z0-9]+$') = False
    then
    begin
      ShowMessage('Email address is not valid !');
      Exit;
    end;

    // Send account registration request to the server
    try
      RESTClient.ResetToDefaults;
      RESTClient.BaseURL := cURL;

      RESTRequest.Method := rmPOST;
      RESTRequest.Params.ParameterByName('user').Value := EditRegisterName.Text;
      RESTRequest.Params.ParameterByName('mail').Value :=
        EditRegisterEmail.Text;
      RESTRequest.Params.ParameterByName('pswd').Value :=
        THashMD5.GetHashString(EditRegisterPassword.Text);
      RESTRequest.Params.ParameterByName('proc').Value := 'register';
      RESTRequest.Params.ParameterByName('data').Value := '';

      RESTResponseDataSetAdapter.DataSet := TableProfile;

      RESTRequest.Execute;
    except
      { Show a message instead of the exception raised by
      RESTResponseDataSetAdapter: "Response is not a valid JSON", and then Exit
      the procedure }
      ShowMessage('Connection error !');
      Exit;
    end;

      // Check server response for the account registration
      if TableProfile.RecordCount > 0 then
      begin
        ShowMessage('Account registered succefully !');
        TCMain.SetActiveTabWithTransitionAsync(TabLogin, TTabTransition.Slide,
          TTabTransitionDirection.Reversed, nil);
        EditRegisterName.Text := '';
        EditRegisterEmail.Text := '';
        EditRegisterPassword.Text := '';
      end

    { If registration failed then perhaps the cause is the credentials are
     already used by another existing user }
    else
      ShowMessage
        ('Account was not registered because the specified name or mail already used'
        + sLineBreak + 'Please enter a different user name or mail address');
  end

  else
    ShowMessage('Please fill the registeration form with your credentials');

end;

procedure TForm1.BtnLoginClick(Sender: TObject);
begin
  if (EditUsername.Text <> '') and
     (EditPassword.Text <> '') then

  begin
    try
      RESTClient.ResetToDefaults;
      RESTClient.BaseURL := cURL;
      RESTRequest.Method := rmPOST;

      RESTRequest.Params.ParameterByName('user').Value := EditUsername.Text;
      RESTRequest.Params.ParameterByName('pswd').Value :=
        THashMD5.GetHashString(EditPassword.Text);
      RESTRequest.Params.ParameterByName('proc').Value := 'login';

      RESTResponseDataSetAdapter.DataSet := TableProfile;

      RESTRequest.Execute;
    except
      { Show a message instead of the exception raised by
      RESTResponseDataSetAdapter: "Response is not a valid JSON", and then Exit
      the procedure }
      ShowMessage('Connection error !');
      Exit;
    end;

    if (TableProfile.RecordCount > 0) and
       (TableProfileName.AsWideString = EditUsername.Text) then
    begin
      TTask.Run(
        procedure
        begin
          // Download customers table because it require only low capability
          GetCustomers;

          // Check user capabilities to download user table
          case (TableProfileCapabilities.AsInteger) of
            0:
              begin // Viewer capabilities: no edition
                TableCustomers.ReadOnly := True;
              end;

            1:
              begin // Moderator capabilities: editing only the Customers dataset
                TableCustomers.ReadOnly := False;
              end;

            2:
              begin // Admin capabilities: editing all datasets
                TableCustomers.ReadOnly := False;
                TabUsers.Visible := True;
                GetUsers;
                TableUsers.ReadOnly := False;
              end;

          end;

        end);

      TCMain.SetActiveTabWithTransitionAsync(TabDashboard, TTabTransition.Slide,
        TTabTransitionDirection.Normal, nil);
      TableProfile.Active := True;

      EditUsername.Text := '';
      EditPassword.Text := '';
    end

    else
      ShowMessage('Wrong credentials !');
  end

  else
    ShowMessage('Please fill the login form with your credentials');
end;

procedure TForm1.BtnLogoutClick(Sender: TObject);
begin
  try
    TableProfile.EmptyDataSet;
    TabUsers.Visible := False;
    TableCustomers.EmptyDataSet;
    if TableUsers.Active = True then
      TableUsers.EmptyDataSet;
  finally
    TCMain.SetActiveTabWithTransitionAsync(TabLogin, TTabTransition.Slide,
      TTabTransitionDirection.Reversed, nil);
  end;
end;

procedure TForm1.BtnRegisterClick(Sender: TObject);
begin
  TCMain.SetActiveTabWithTransitionAsync(TabRegister, TTabTransition.Slide,
    TTabTransitionDirection.Normal, nil);
end;

procedure TForm1.BtnUpdateProfileClick(Sender: TObject);
begin
  if (EditProfileName.Text <> '') and
     (EditProfileEmail.Text <> '') and
     (EditProfileNewPassword.Text <> '') then

  begin
    // Check email address
    if TRegEx.IsMatch(EditProfileEmail.Text,
      '^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]*[a-zA-Z0-9]+$') = False
    then
    begin
      ShowMessage('Email address is not valid !');
      Exit;
    end;

    // Check if both password fields are identical
    if (EditProfileNewPassword.Text <> EditProfileConfimPassword.Text) then
    begin
      ShowMessage('Your new password is not confirmed !');
      Exit;
    end;

    // Updating the local profile's dataset
    TableProfile.Active := True;
    TableProfile.DisableControls;
    try
      TableProfile.Edit;
      try
        TableProfileName.AsWideString := EditProfileName.Text;
        TableProfileEmail.AsWideString := EditProfileEmail.Text;
        TableProfilePass.AsWideString :=
          THashMD5.GetHashString(EditProfileNewPassword.Text);

        TableProfile.Post;
      except
        TableProfile.Cancel;
        ShowMessage('Profile updating failed !');
        Exit;
      end;

      // Send the new profile's credentials to the server
      try
        RESTClient.ResetToDefaults;
        RESTClient.BaseURL := cURL;
        RESTRequest.Method := rmPOST;
        RESTRequest.Params.ParameterByName('user').Value :=
          TableProfileName.AsWideString;
        RESTRequest.Params.ParameterByName('pswd').Value :=
          TableProfilePass.AsWideString;
        RESTRequest.Params.ParameterByName('proc').Value := 'update_profile';
        RESTRequest.Params.ParameterByName('data').Value :=
          DataSetRecordToJSON(TableProfile);

        RESTResponseDataSetAdapter.DataSet := TableProfile;

        RESTRequest.Execute;

      except
        ShowMessage('Connection error !');
        Exit;
      end;

    finally
      ShowMessage('Profile updated');
      TableProfile.EnableControls;
    end;

  end;
end;

function TForm1.DataSetRecordToJSON(ADataSet: TDataSet): string;
{ A private function for converting a dataset's active record to JSON string }

const
  cFieldDelimiter = ',';
  cNameValueSeparator = ':';
  cQuoteChar = '"';

var
  RB: string;
  FI: integer;

begin
  RB := '';

  try
    if ADataSet.RecordCount > 0 then
    begin
      RB := cQuoteChar + ADataSet.Fields[0].FieldName.Replace('"', '\"',
        [rfReplaceAll]) + cQuoteChar + cNameValueSeparator + cQuoteChar +
        ADataSet.Fields[0].AsWideString.Replace('"', '\"', [rfReplaceAll]) +
        cQuoteChar;

      if (ADataSet.FieldCount > 1) then
      begin
        for FI := 1 to (ADataSet.FieldCount - 1) do
          RB := RB + cFieldDelimiter + cQuoteChar + ADataSet.Fields[FI]
            .FieldName.Replace('"', '\"', [rfReplaceAll]) + cQuoteChar +
            cNameValueSeparator + cQuoteChar + ADataSet.Fields[FI]
            .AsWideString.Replace('"', '\"', [rfReplaceAll]) + cQuoteChar;
      end;

    end;

  finally
    Result := '{' + RB + '}';
  end;

end;

function TForm1.DataSetToJSON(ADataSet: TDataSet): string;
{ A private function for converting a dataset's records to JSON string }
const
  cFieldDelimiter = ',';
  cNameValueSeparator = ':';
  cQuoteChar = '"';

var
  RB: string;
  DSB: TStringList;
  FI: integer;

begin
  RB := '';
  DSB := TStringList.Create;

  try
    if ADataSet.RecordCount > 0 then
    begin
      ADataSet.First;

      DSB.Delimiter := ',';
      DSB.QuoteChar := #0;

      while not(ADataSet.EOF) do
      begin
        RB := cQuoteChar + ADataSet.Fields[0].FieldName.Replace('"', '\"',
          [rfReplaceAll]) + cQuoteChar + cNameValueSeparator + cQuoteChar +
          ADataSet.Fields[0].AsWideString.Replace('"', '\"', [rfReplaceAll]) +
          cQuoteChar;

        if (ADataSet.FieldCount > 1) then
        begin
          for FI := 1 to (ADataSet.FieldCount - 1) do
            RB := RB + cFieldDelimiter + cQuoteChar + ADataSet.Fields[FI]
              .FieldName.Replace('"', '\"', [rfReplaceAll]) + cQuoteChar +
              cNameValueSeparator + cQuoteChar + ADataSet.Fields[FI]
              .AsWideString.Replace('"', '\"', [rfReplaceAll]) + cQuoteChar;
        end;

        DSB.Add('{' + RB + '}');

        ADataSet.Next;
      end;
    end;

  finally

    Result := '[' + DSB.DelimitedText + ']';

    DSB.Free;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TCMain.ActiveTab := TabLogin;
  TCMain.TabPosition := TTabPosition.None;
  TCDashboard.ActiveTab := TabProfile;
  TCDashboard.TabPosition := TTabPosition.Top;
  TabUsers.Visible := False;
end;

procedure TForm1.GetCustomers;
begin
  // Download the customers dataset from the server
  RESTClient.ResetToDefaults;
  RESTClient.BaseURL := cURL;
  RESTRequest.Method := rmPOST;
  RESTRequest.Params.ParameterByName('user').Value :=
    TableProfileName.AsWideString;
  RESTRequest.Params.ParameterByName('pswd').Value :=
    TableProfilePass.AsWideString;
  RESTRequest.Params.ParameterByName('proc').Value := 'get_customers';

  RESTResponseDataSetAdapter.DataSet := TableCustomers;

  RESTRequest.Execute;
end;

procedure TForm1.GetUsers;
begin
  // Download the users dataset from the server
  RESTClient.ResetToDefaults;
  RESTClient.BaseURL := cURL;
  RESTRequest.Method := rmPOST;
  RESTRequest.Params.ParameterByName('user').Value :=
    TableProfileName.AsWideString;
  RESTRequest.Params.ParameterByName('pswd').Value :=
    TableProfilePass.AsWideString;
  RESTRequest.Params.ParameterByName('proc').Value := 'get_users';

  RESTResponseDataSetAdapter.DataSet := TableUsers;

  RESTRequest.Execute;
end;

end.
