unit PMyBaseDebug;
{
��Ԫ����PMyBaseDebug
�����ߣ�������
�������ڣ�20050407
�ࣺTBaseDebug
����������
   �ṩ������Debug���� ����־��ʾ��¼�Ĺ���
   ����Ԫ�Լ�ά��һ��ȫ�ֱ���Gob_Debug
20050412
  �����TBaseDebug ���Զ�ע���ȼ�������
  �������� ���� InitDebugSystem(ImainForm: TForm)��Ϊ˽��
  ����˴���͸�����϶���
  �����һ������
  Function AddLogShower(IStrings:TStringList): Variant; Overload;
  �� FShower: TMemo;��Ϊ˽��
  �� AutoSaveLog: boolean; ����Ϊ WantAutoSaveLog: boolean;
20050518
  �������ʾTDATASET�ĺ���
  ��Ӹ��ݱ������ɲ���͸���SQL���ĺ���
20051128
  ���һ���ۼӼ����ķ���
  ȥ����û�����õĽӿ�ISHOWER
//------------------------------------------------------------------------------
// ����һ������ָ�� undebug ���Է��㵽ȥ���ܻ�  ������ 2009-02-02 16:55:07
//------------------------------------------------------------------------------
}

interface
uses Windows, SysUtils, Classes, Messages, Controls, Forms, StdCtrls, ExtCtrls,
  ComCtrls, DB, ADODB;
const
   {�ָ����}
  CSplitStr = '===============================================================';
  ClogFileName = '.log';
type
  TDebugLogFile = class
  private
    FFileParth: string; //·��
    FText: Text;
    FIsCreateToNew: boolean; //�Ƿ���ÿ���������򶼴����µļ�¼�ļ� ������ǵ���ֻ����1���ļ�
  public
    {������־�ļ���ŵ�Ŀ¼λ��}
    constructor Create(Iparth: string);
    destructor Destroy; override;
    {д�����ݼ����Զ���¼}
    procedure AddLog(Icon: string);
    property IsCreateToNew: boolean read FIsCreateToNew write FIsCreateToNew;
  end;
  {
   ��ʾ�ӿ�
  }
  TEventShowed = procedure(ILogCon: string) of object;
  TDebuglog = class
  private
    FShower: TComponent; //����
    FClearTager: Word; //��ʾ�����������һ��
    FIsAddTime: boolean; //�Ƿ���ÿ����ʾǰ��ʱ��
    FAfterShowed: TEventShowed; //��ʾ�󴥷����¼� ������������־
    FIsNeedSplt: boolean; //�Ƿ���Ҫ�ָ��ַ�
    FSplitChar: string; //�ָ���ַ�
    FLog: TDebugLogFile;
  protected
    function DoAdd(Icon: string): Integer; virtual;
    function AddShow(ICon: string): Integer;
  published
    property AfterShowed: TEventShowed read FAfterShowed write FAfterShowed;
  public
    {��������¼�ļ����·���Ļ����Զ����ɼ�¼��}
    constructor Create(IShower: TComponent; IlogFIleDir: string = '');
    destructor Destroy; override;
    property ClearTager: Word read FClearTager write FClearTager;
    property IsAddTime: boolean read FIsAddTime write FIsAddTime;
    property IsNeedSplitChar: boolean read FIsNeedSplt write FIsNeedSplt;
    property SplitChar: string read FSplitChar write FSplitChar;
  end;

type
  //�����������
  SCreateSqlKind = (SSk_insert, SSk_update);
  //��ʾ����
  SShowKind = (Sshowkind_None, Sshowkind_FieldHead, Sshowkind_Number, Sshowkind_All, Sshowkind_CurrNo);
  TBaseDebug = class
  private
    FStartTime,
      FEndTime: Cardinal;

    FLoger: TDebugLog;
    FtrackBar: TTrackBar;
    FGroupBox: TGroupBox;
    FShower: TMemo;
    F_gob_openFrom, F_gob_AutoLog: Integer;
    {�����ȼ�ϵͳ Alt+o �Ǵ�debug���� +p�Ǵ�/�ر��Զ���¼����}
    procedure InitDebugSystem;
    {�ͷ�ϵͳ�ȼ�}
    procedure UnInitDebugSystem;
    {�϶�������}
    procedure TrackOnTrack(Iobj: TObject);
    {Hotkey}
    procedure hotykey(var Msg: TMsg; var Handled: Boolean);
    {����TDATASET���ɲ������}
    function CreateInsertSql(IdataSet: TFields; ItabName: string): string;
    {����TdataSet���ɲ�ѯ���}
    function CreateUpdateSql(IdataSet: TFields; ItabName: string): string;
  public
    FBugShowForm: TForm;
    {�Ƿ��ڳ��������ʱ���Զ����������Ϣ Ĭ����False}
    WantAutoSaveLog: boolean;

    {��ʼ��¼ʱ��}
    procedure StartLogTime;
    {ֹͣ��¼���ҷ���ʱ��λ����}
    function EndLogTIme: Cardinal;
    {����������ֵ}
    function ShowVar(Ivar: Variant): Variant;
    {��ӵ�Log����}
    function AddLogShower(Ivar: Variant): Variant; overload;
    function AddLogShower(IStr: string; const Args: array of const): Variant; overload;
    function AddLogShower(IDesc: string; Ivar: Variant): Variant; overload;
    function AddLogShower(IStrings: TStrings): TStrings; overload;
    function AddLogShower(IRect: TRect): TRect; overload;
    function AddLogShower(IDateset: TDataSet; IshowKind: SShowKind = Sshowkind_None; IshowNumber: Integer = 0): TDataSet; overload;
    function AddLogShower(IBuff: Pointer; ILen: integer): string; overload;

    {���ݱ����Զ�����SQL}
    function GetSqlWithTableName(IQuery: TADOQuery; ItabName: string; Issk: SCreateSqlKind): string;
    {��ʾDebug����}
    procedure ShowDebugform;
    {�����м�¼�Ķ����������־}
    procedure SaveLog(IfileName: string = 'LogFile.log');
    constructor Create;
    destructor Destroy; override;
  end;

var
  Gob_Debug: TBaseDebug;
implementation

{ TDebugLog }

function TDebugLog.AddShow(ICon: string): Integer;
begin
  if FIsAddTime then
    ICon := DateTimeToStr(Now) + ' ' + Icon;
  if FIsNeedSplt then
    ICon := ICon + #13#10 + FSplitChar;
  Result := DoAdd(ICon);
  if assigned(FLog) then
    FLog.AddLog(ICon);
  if Assigned(FAfterShowed) then
    FAfterShowed(ICon);
end;

constructor TDebugLog.Create(IShower: TComponent; IlogFIleDir: string = '');
begin
  FClearTager := 3000;
  IsAddTime := True;
  FIsNeedSplt := True;
  FSplitChar := CSplitStr;
  FShower := IShower;
  if IlogFIleDir <> '' then
    FLog := TDebugLogFile.Create(IlogFIleDir);
end;

destructor TDebugLog.Destroy;
begin
  if assigned(FLog) then
    FLog.Free;
  inherited;
end;

function TDebugLog.DoAdd(Icon: string): Integer;
begin
  if (FShower is TMemo) then begin
    Result := TMemo(FShower).Lines.Add(Icon);
    if Result >= FClearTager then
      TMemo(FShower).Clear
  end
  else if (FShower is TListBox) then begin
    Result := TListBox(FShower).Items.Add(Icon);
    if Result >= FClearTager then
      TListBox(FShower).Clear
  end
  else
    raise Exception.Create('Ĭ����������:' + FShower.ClassName);
end;

{ TDebugLogFile }

procedure TDebugLogFile.AddLog(Icon: string);
begin
  try
    Append(FText);
    Writeln(FText, icon);
  except
    IOResult;
  end;
end;

constructor TDebugLogFile.Create(Iparth: string);
var
  Ltep: string;
begin
  FIsCreateToNew := True;
  FFileParth := Iparth;
  if not DirectoryExists(FFileParth) then
    if not CreateDir(FFileParth) then begin
      raise Exception.Create('�����·������־������ܱ�����');
      exit;
    end;
  Ltep := FormatDateTime('yyyymmddhhnnss', Now);
  FileClose(FileCreate(FFileParth + ltep + ClogFileName));
  AssignFile(FText, FFileParth + ltep + ClogFileName);
end;

destructor TDebugLogFile.Destroy;
begin
  try
    CloseFile(FText);
  except
  end;
  inherited;
end;

{ TBaseDebug }

function TBaseDebug.AddLogShower(Ivar: Variant): Variant;
begin
  Result := Ivar;
{$IFNDEF undebug}
  try
    FLoger.AddShow(Ivar);
  except
    on e: Exception do
      AddLogShower(e.Message);
  end;
{$ENDIF}
end;

function TBaseDebug.AddLogShower(IDesc: string; Ivar: Variant): Variant;
var
  Ltep: string;
begin
  Ltep := Ivar;
  Result := Ivar;
{$IFNDEF undebug}
  try
    FLoger.AddShow('����<' + IDesc + '> <ֵ: ' + Ltep + '>');
  except
    on e: Exception do
      AddLogShower(e.Message);
  end;
{$ENDIF}
end;

constructor TBaseDebug.Create;
begin
{$IFNDEF undebug}
  FBugShowForm := TForm.Create(FBugShowForm);
  FBugShowForm.FormStyle := fsStayOnTop;
  FBugShowForm.Caption := 'С���Debugģ��';
  FBugShowForm.Visible := False;
  FBugShowForm.Position := poScreenCenter;
  FBugShowForm.AlphaBlend := false;
  FBugShowForm.Width := 430;
  FBugShowForm.Height := 300;
  FShower := TMemo.Create(FBugShowForm);
  FShower.Parent := FBugShowForm;
  FShower.Align := alClient;
  FShower.ScrollBars := ssVertical;
  FShower.WordWrap := True;
  FLoger := TDebugLog.Create(FShower);
  FLoger.IsNeedSplitChar := False;
  FLoger.ClearTager := 10000;
  FGroupBox := TGroupBox.Create(FBugShowForm);
  FGroupBox.Parent := FBugShowForm;
  FGroupBox.Align := alBottom;
  FGroupBox.Height := 40;
  FGroupBox.Caption := '͸����';
  FtrackBar := TTrackBar.Create(nil);
  FtrackBar.Min := 50;
  FtrackBar.Max := 255;
  FtrackBar.Parent := FGroupBox;
  FtrackBar.Position := 200;
  FtrackBar.Align := alClient;
  FtrackBar.TickStyle := tsNone;
  FtrackBar.OnChange := TrackOnTrack;
  FtrackBar.OnChange(FtrackBar);
  WantAutoSaveLog := False;
  InitDebugSystem;
  AddLogShower(Format('��������...', []));
  AddLogShower(Format('�������(%s)', [Application.Title]));
  AddLogShower(Format('������(%s)', [Application.ExeName]));
{$ENDIF}
end;

destructor TBaseDebug.Destroy;
begin
{$IFNDEF undebug}
  AddLogShower(Format('�������ʱ��(%s)', [DateTimeToStr(now)]));
  UnInitDebugSystem;
  if WantAutoSaveLog then
    SaveLog();
  FtrackBar.Free;
  FGroupBox.Free;
  FLoger.Free;
  FShower.Free;
  FBugShowForm.Free;
{$ENDIF}
  inherited;
end;

function TBaseDebug.EndLogTIme: Cardinal;
begin
  FEndTime := GetTickCount;
  Result := FEndTime - FStartTime;
end;

procedure TBaseDebug.InitDebugSystem;
begin
  F_gob_openFrom := GlobalAddAtom('Hot_OpenFrom');
  F_gob_AutoLog := GlobalAddAtom('Hot_AutoLog');
  RegisterHotKey(Application.Handle, F_gob_openFrom, MOD_ALT, ord('O'));
  RegisterHotKey(Application.Handle, F_gob_AutoLog, MOD_ALT, ord('P'));
  Application.OnMessage := hotykey;
end;

procedure TBaseDebug.SaveLog(IfileName: string);
begin
{$IFNDEF undebug}
  try
    CreateDir(ExtractFilePath(Application.ExeName) + 'DebugLog\');
    FShower.Lines.SaveToFile(ExtractFilePath(Application.ExeName) + 'DebugLog\' + Format('%s', [FormatDateTime('yyyymmddhhnnss', now) + IfileName]));
  except
    raise Exception.Create('����Debug��־ʧ��');
  end;
{$ENDIF}
end;

procedure TBaseDebug.ShowDebugform;
begin
{$IFNDEF undebug}
  FBugShowForm.Show;
  Application.ProcessMessages;
{$ENDIF}
end;

function TBaseDebug.ShowVar(Ivar: Variant): Variant;
var
  S: string;
begin
  Result := Ivar;
{$IFNDEF undebug}
  try
    s := Ivar;
    MessageBox(0, Pchar(s), 'Debug', 0);
  except
    on e: Exception do
      AddLogShower(e.Message);
  end;
{$ENDIF}
end;

procedure TBaseDebug.StartLogTime;
begin
  FStartTime := GetTickCount;
end;

procedure TBaseDebug.TrackOnTrack(Iobj: TObject);
begin
  FBugShowForm.AlphaBlendValue := TTrackBar(Iobj).Position;
end;

function TBaseDebug.AddLogShower(IStrings: TStrings): TStrings;
var
  I: Integer;
begin
  Result := IStrings;
{$IFNDEF undebug}
  AddLogShower('>>>��ʼ��ʾStrings Items����', IStrings.Count);
  for I := 0 to IStrings.Count - 1 do
    AddLogShower(IStrings.Strings[i]);
  AddLogShower('��ʾStrings����<<< Items����', IStrings.Count);
{$ENDIF}
end;

procedure TBaseDebug.UnInitDebugSystem;
begin
  UnregisterHotKey(Application.Handle, F_gob_openFrom);
  UnregisterHotKey(Application.Handle, F_gob_AutoLog);
  GlobalDeleteAtom(F_gob_openFrom);
  GlobalDeleteAtom(F_gob_AutoLog);
end;

procedure TBaseDebug.hotykey(var Msg: TMsg; var Handled: Boolean);
begin
  if Msg.message = WM_HOTKEY then begin
    if loword(Msg.lParam) = MOD_ALT then
      case HiWord(msg.LParam) of //
        ord('o'), Ord('O'): begin
            FBugShowForm.Visible := not FBugShowForm.Visible;
            if Application.MainForm <> nil then
              Application.MainForm.SetFocus;
          end;
        ord('P'), ord('p'): begin
            WantAutoSaveLog := not WantAutoSaveLog;
            AddLogShower('��ǰ�Զ������״̬��Ϊ�� ');
            AddLogShower(WantAutoSaveLog)
          end;
      end; // case
  end;
end;

function TBaseDebug.GetSqlWithTableName(IQuery: TADOQuery;
  ItabName: string; Issk: SCreateSqlKind): string;
begin
  with IQuery do begin
    Close;
    SQL.Text := Format('Select * from %s Where 1=2', [ItabName]);
    try
      Open;
      case Issk of //
        SSk_insert: Result := CreateInsertSql(IQuery.Fields, ItabName);
        SSk_update: Result := CreateUpdateSql(IQuery.Fields, ItabName);
      end; // case
    except
      on e: Exception do
        AddLogShower('������亯����ȡ���ݿ�ʱ�쳣,�������ʧ��', e.Message);
    end;
  end; // with
end;

function TBaseDebug.CreateInsertSql(IdataSet: TFields; ItabName: string): string;
var
  I: Integer;
  LList: TStringList;
begin
  LList := TStringList.Create;
  with IdataSet do begin
    Result := 'Insert into ' + ItabName + '(';
    for I := 0 to Count - 1 do begin // Iterate
      Result := Result + Fields[i].FieldName;
      case Fields[i].DataType of
        ftCurrency, ftBCD, ftSmallint, ftWord, ftInteger, ftBytes: LList.Add('%d');
        ftFloat: LList.Add('%f');
      else
        LList.Add('''%s''');
      end; // case
      if i <> Count - 1 then
        Result := Result + ',';
    end; // for
    Result := Result + ') Values(';
    for I := 0 to LList.Count - 1 do begin // Iterate
      Result := Result + LList.Strings[i];
      if i <> LList.Count - 1 then
        Result := Result + ',';
    end; // for
    Result := Result + ')';
  end; // with
  LList.Free;
end;

function TBaseDebug.CreateUpdateSql(IdataSet: TFields; ItabName: string): string;
var
  I: Integer;
begin
  with IdataSet do begin
    Result := 'Update ' + ItabName + ' Set ';
    for I := 0 to Count - 1 do begin // Iterate
      Result := Result + Fields[i].FieldName + '=';
      case Fields[i].DataType of //
        ftCurrency, ftBCD, ftSmallint, ftWord, ftInteger, ftBytes: Result := Result + '%d';
        ftFloat: Result := Result + '%d'
      else
        Result := Result + '''%s''';
      end; // case
      if i <> Count - 1 then
        Result := Result + ',';
    end; // for
  end; // with
end;

function TBaseDebug.AddLogShower(IDateset: TDataSet; IshowKind: SShowKind;
  IshowNumber: Integer): TDataSet;
var
  I, N, tot: Integer;
  LTep: string;
begin
  Result := IDateset;
{$IFNDEF undebug}
  AddLogShower('>>>��ʼ��ʾDataSet');
  AddLogShower('���ݼ�%s�����:%s', [IDateset.Name, BoolToStr(IDateset.Active, True)]);
  AddLogShower('�ܼ�¼��', IDateset.RecordCount);
  AddLogShower('��ǰ��¼��', IDateset.RecNo);
  AddLogShower('��¼��С', IDateset.RecordSize);
  if IshowKind <> Sshowkind_None then begin
    AddLogShower('��ʼ��ʾ���ݼ���¼>>>');
    for I := 0 to IDateset.Fields.Count - 1 do
      LTep := LTep + ' | ' + IDateset.Fields[i].FieldName;
    AddLogShower(LTep);
    if IshowKind = Sshowkind_FieldHead then begin
    end
    else if IshowKind = Sshowkind_CurrNo then begin
      LTep := '';
      for I := 0 to IDateset.Fields.Count - 1 do
        LTep := LTep + ' | ' + IDateset.Fields[i].AsString;
      AddLogShower(LTep);
    end
    else begin
      if IshowKind = Sshowkind_All then
        tot := IDateset.RecordCount
      else
        tot := IshowNumber;
      IDateset.First;
      for I := 0 to tot - 1 do begin
        LTep := '';
        for N := 0 to IDateset.FieldCount - 1 do
          LTep := LTep + ' | ' + IDateset.Fields[n].AsString;
        AddLogShower(LTep);
        IDateset.Next;
      end;
    end;
  end;
  AddLogShower('��ʾDataSet���<<<');
{$ENDIF}
end;

function TBaseDebug.AddLogShower(IStr: string; const Args: array of const):
  Variant;
begin
  Result := IStr;
{$IFNDEF undebug}
  try
    IStr := Format(IStr, Args);
    Result := IStr;
    FLoger.AddShow(Result);
  except
    on e: Exception do
      AddLogShower(e.Message);
  end;
{$ENDIF}
end;

function TBaseDebug.AddLogShower(IRect: TRect): TRect;
begin
  Result := IRect;
{$IFNDEF undebug}
  try
    FLoger.AddShow(Format('rect : left<%d> top<%d> right<%d> bottom<%d>', [IRect.Left, IRect.Left, IRect.Right, IRect.Bottom]));
  except
    on e: Exception do
      AddLogShower(e.Message);
  end;
{$ENDIF}
end;

function TBaseDebug.AddLogShower(IBuff: Pointer; ILen: integer): string;
var
  i: integer;
  lp: PByte;
  LS: string;
begin
  lp := IBuff;
  for i := 0 to ILen - 1 do begin // Iterate
    ls := LS + '$' + IntToHex(lp^, 2);
    inc(lp);
  end; // for
  Result := Ls;
{$IFNDEF undebug}
  Gob_Debug.AddLogShower('�ڴ�����<' + IntToStr(ILen) + '>:' + LS);
{$ENDIF}
end;

initialization
  Gob_Debug := TBaseDebug.Create;
finalization
  Gob_Debug.Free;
end.

