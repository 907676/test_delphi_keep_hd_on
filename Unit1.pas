unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ShellAPI, PlatformDefaultStyleActnCtrls, Menus, ActnPopup,
  StdCtrls, Spin, IniFiles;

const
  WM_TRAYMSG = WM_USER + 1;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    ShowWindow1: TMenuItem;
    Exit1: TMenuItem;
    edt1: TEdit;
    lbledtFile: TLabeledEdit;
    se1: TSpinEdit;
    lbl1: TLabel;
    chkMin: TCheckBox;
    btniSave: TMenuItem;
    Timer2: TTimer;
    N1: TMenuItem;
    procedure btniSaveClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ShowWindow1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  private
    procedure WMTrayIcon(var Msg: TMessage); message WM_TRAYMSG;
    function  getX(): Integer;
    function getIniFileName(): string;
    procedure ReadSettingsFromIniFile;
    procedure SaveSettingsToIniFile;
    function newPopupMenu(): TPopupMenu;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  saveCount: Integer = 0;

implementation

const
  SFile_Name = 'FILE_NAME';
  SConfig = 'CONFIG';
  SINTERVAL_SEC  = 'INTERVAL_SEC';
  SMIN = 'MIN';

{$R *.dfm}

var
  a: Integer;

function EnsureDirectoryExists(const filePath: string): string;
var
  dirPath: string;
begin
  // ��ȡĿ¼·��
  dirPath := ExtractFileDir(filePath);

  // ��鲢����Ŀ¼
  if (dirPath <> '') and (not DirectoryExists(dirPath)) then
  begin
    if not ForceDirectories(dirPath) then
      raise Exception.Create('�޷�����Ŀ¼: ' + dirPath);
  end;

  Result := dirPath;
end;


procedure CopyMenuItems(Source, Dest: TMenuItem);
var
  i: Integer;
  NewItem: TMenuItem;
  SourceItem: TMenuItem;
begin
//  Dest.Clear;
  for i := 0 to Source.Count - 1 do
  begin
    SourceItem := Source.Items[i];
    NewItem := TMenuItem.Create(Dest);
    NewItem.Caption := SourceItem.Caption;
    NewItem.OnClick := SourceItem.OnClick;
    NewItem.ShortCut := SourceItem.ShortCut;
    // ����������Ҫ���ԣ���Tag��Checked�ȣ�
    Dest.Add(NewItem);

    // �ݹ鴦���Ӳ˵�
    if Source.Items[i].Count > 0 then
      CopyMenuItems(Source.Items[i], NewItem);
  end;
end;

function TForm1.newPopupMenu(): TPopupMenu;
var
  DynMenu: TPopupMenu;
begin
//  if Button = mbRight then
  begin
    DynMenu := TPopupMenu.Create(Self);
    DynMenu.AutoHotkeys := maManual;
    // ����ԭ�˵���
    // ����ʾ��
    CopyMenuItems(PopupMenu1.Items, DynMenu.Items);
//    DynMenu.Items.Assign(PopupMenu1.Items);
//    DynMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    Result := DynMenu;
  end;
end;

procedure OpenContainingFolder(const AFileName: string);
var
  FolderPath: string;
begin
  // ����ļ��Ƿ����
//  if not FileExists(AFileName) then
//  begin
//    ShowMessage('�ļ�������: ' + AFileName);
//    Exit;
//  end;

  // ������·������ȡĿ¼����
  // ExtractFilePath �᷵�� 'C:\MyDir\' ������·��������ĩβ�ķ�б�ܣ�
  FolderPath := ExtractFilePath(AFileName);

  // �����ȡ��·���ǿյģ������ļ�������·�����������κ���
  if FolderPath = '' then Exit;

  // ֱ�� 'open' �� 'explore' ����ļ���·��
  ShellExecute(Application.Handle, 'explore', PChar(FolderPath), nil, nil, SW_SHOWNORMAL);
end;

procedure OpenFolderAndSelectFile(const AFileName: string);
var
  // ���ǲ�����Ҫ FolderPath ������
  Cmd: string;
  Params: string;
  find: Boolean;
begin
  find := True;
  // ���鱣���ļ������Լ�飬����һ���õı��ϰ��
  if not FileExists(AFileName) then
  begin
    find := False;
    OpenContainingFolder(AFileName);
//    ShowMessage('�ļ�������: ' + AFileName);
    Exit;
  end;

  // 1. ָ��Ҫִ�еĳ����� Windows �ļ���Դ������
  Cmd := 'explorer.exe';

  // 2. ���촫�ݸ� explorer.exe �Ĳ���
  // �ؼ���: ʹ�� /select �����������һ�����ţ�Ȼ���Ǵ�Ӣ��˫���ŵ��ļ�����·����
  // ��˫������Ϊ�˷�ֹ·���а����ո�ʱ����
  if find then
    Params := '/select,"' + AFileName + '"';

  // 3. ���� ShellExecute ִ������
  // - ��һ�������Ǹ����ھ����ͨ���� Application.Handle
  // - �ڶ��������ǲ������ʣ�����ֱ��ִ�г���ͨ���� 'open'
  // - ������������Ҫִ�еĳ��� (explorer.exe)
  // - ���ĸ������Ǵ��ݸ�����Ĳ��� (/select,...)
  // - nil, SW_SHOWNORMAL �Ǳ�׼����
  ShellExecute(Application.Handle, 'open', PChar(Cmd), PChar(Params), nil, SW_SHOWNORMAL);
end;

procedure TForm1.btniSaveClick(Sender: TObject);
begin
  SaveSettingsToIniFile();
  ShowMessage('����ini�ѱ���!!!');
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  sl: TStringList;
  x: Integer;
begin
  Inc(a);
  Self.Caption := Format('%d - %d', [a, saveCount]);
  x := getX();
  if (a mod x = 0) then
  begin
    sl := TStringList.Create();
    sl.Add(Application.ExeName);
    sl.Add(edt1.Text);
    sl.Add(Format('%d', [a]));
    sl.Add(Format('%d', [a div x]));
    EnsureDirectoryExists(lbledtFile.Text);
    sl.SaveToFile(lbledtFile.Text);
    Inc(saveCount);
    sl.Free;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Self.HandleNeeded();
  TrayIcon1.Icon := Application.Icon;
  TrayIcon1.Hint := 'keep hd on';
  TrayIcon1.PopupMenu := newPopupMenu();
//  TrayIcon1.PopupMenu := PopupMenu1;
  TrayIcon1.Visible := True;
  TrayIcon1.OnDblClick := ShowWindow1Click;
  ReadSettingsFromIniFile;
  Self.PopupMenu := newPopupMenu;
  Self.PopupMenu.Items.Delete(0);
//  lbledtFile.SetFocus;
  Self.ActiveControl := lbledtFile;
  lbledtFile.SelectAll;
  if chkMin.Checked then
  begin
    edt1.Text := '666';
//    Application.Minimize;
    WindowState := wsMinimized;
//    Application.ShowMainForm := False;
//    hide;
  end;
end;

function TForm1.getIniFileName: string;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
end;

function TForm1.getX: Integer;
begin
  if(se1.Value < se1.MinValue) then
    Result := se1.MinValue
  else
    Result := se1.Value;
end;

procedure TForm1.ReadSettingsFromIniFile;
var
  IniFile: TIniFile;
  filename: string;
  sec: Integer;
begin
  if (not FileExists(getIniFileName)) then
    Exit;
  IniFile := TIniFile.Create(getIniFileName);
  try
    // ��ȡ���ã���Ĭ��ֵ��
    filename := IniFile.ReadString(SConfig, SFile_Name, lbledtFile.Text);
    sec := IniFile.ReadInteger(SConfig, SINTERVAL_SEC, getX());
    chkMin.Checked := IniFile.ReadBool(SConfig, SMIN, False);
    lbledtFile.Text := filename;
    if (sec < se1.MinValue) then
      sec := se1.MinValue;
    se1.Value := sec;
  finally
    IniFile.Free;
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Hide;
end;

procedure TForm1.SaveSettingsToIniFile;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(getIniFileName);
  try
    // д��������͵�����
    IniFile.WriteString(SConfig, SFile_Name, lbledtFile.Text);
    IniFile.WriteInteger(SConfig, SINTERVAL_SEC, getX());
    IniFile.WriteBool(SConfig, SMIN, chkMin.Checked);
  finally
    IniFile.Free;
  end;
end;

procedure TForm1.ShowWindow1Click(Sender: TObject);
begin
  Show;
  WindowState := wsNormal;
//  BringToFront;
  // �Ѵ��ڴ�����ǰ��
  SetForegroundWindow(Self.Handle);
//  Self.PopupMenu := nil;
//  Self.PopupMenu := PopupMenu1;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  TrayIcon1.Visible := False;
//  SaveSettingsToIniFile;
  Application.Terminate;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
if chkMin.Checked then
  begin
    edt1.Text := '666';
//    Application.Minimize;
//    WindowState := wsMinimized;
//    Application.ShowMainForm := False;
  end;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
//  OpenContainingFolder(Application.ExeName);
//  OpenContainingFolder(lbledtFile.Text);
  OpenFolderAndSelectFile(Application.ExeName);
  OpenFolderAndSelectFile(lbledtFile.Text);
end;

var aaa:Integer=0;
procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if fsCreating in Self.FormState  then
    Exit;
  if fsShowing in Self.FormState  then
    Exit;
  if chkMin.Checked then
  begin
    edt1.Text := '999';
    Hide;
  end;
  Timer2.Enabled := False;
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  ShowWindow1Click(Sender);
end;

procedure TForm1.WMTrayIcon(var Msg: TMessage);
begin
  case Msg.LParam of
    WM_RBUTTONUP: PopupMenu1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    WM_LBUTTONDBLCLK: ShowWindow1Click(nil);
  end;
end;

initialization

//Application.ShowMainForm := False;

end.
