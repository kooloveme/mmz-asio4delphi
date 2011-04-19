{*******************************************************}
{      ��Ԫ����  UntTIO.pas                             }
{      �������ڣ�2006-1-14 23:20:08                     }
{      ������    ������ QQ 22900104                     }
{      ���ܣ�    I/O��Ԫ                                }
{                                                       }
{*******************************************************}
//  ����һ������
//    Լ����0 - Information
//          1 - Notice
//          2 - Warning
//          3 - Error
//          4 - Report
unit UntTIO;

interface
uses Classes, SysUtils, ComCtrls;
type
  TGameLogFile = class
  private
    FFileParth: string; //·��
    FText: Cardinal;
    FIsCreateToNew: boolean;
    //�Ƿ���ÿ���������򶼴����µļ�¼�ļ� ������ǵ���ֻ����1���ļ�
  public
    {������־�ļ���ŵ�Ŀ¼λ��}
    constructor Create(Iparth: string);
    destructor Destroy; override;
    {д�����ݼ����Զ���¼}
    procedure AddLog(Icon: string; const LogLevel: Integer = 0);
    procedure AddShow(ICon: string; const Args: array of const; const LogLevel:
      Integer = 0); overload;
    procedure AddShow(ICon: string; const LogLevel: Integer = 0); overload;
    property IsCreateToNew: boolean read FIsCreateToNew write FIsCreateToNew;
  end;

  TEventShowed = procedure(ILogCon: string) of object;
  TIOer = class(TObject)
  private
    FIsAddTime: boolean; //�Ƿ���ÿ����ʾǰ��ʱ��
    FAfterShowed: TEventShowed; //��ʾ�󴥷����¼� ������������־
    FIsNeedSplt: boolean; //�Ƿ���Ҫ�ָ��ַ�
    FSplitChar: string; //�ָ���ַ�
    FLog: TGameLogFile;
  protected
    FShower: TComponent; //����
    FClearTager: Word; //��ʾ�����������һ��
    function DoAdd(Icon: string; const LogLevel: Integer = 0): Integer; virtual;

  public
    Enabled: Boolean;
    function AddShow(ICon: string; const Args: array of const; const LogLevel:
      Integer = 0): Integer; overload;
    function AddShow(ICon: string; const LogLevel: Integer = 0): Integer;
      overload;
    {��������¼�ļ����·���Ļ����Զ����ɼ�¼��}
    constructor Create(IShower: TComponent; IlogFIleDir: string = '');
    destructor Destroy; override;
    property ClearTager: Word read FClearTager write FClearTager;
    property IsAddTime: boolean read FIsAddTime write FIsAddTime;
    property IsNeedSplitChar: boolean read FIsNeedSplt write FIsNeedSplt;
    property SplitChar: string read FSplitChar write FSplitChar;
    property AfterShowed: TEventShowed read FAfterShowed write FAfterShowed;
  end;

implementation
uses StdCtrls, Forms;
const
  {�ָ����}
  CSplitStr = '===============================================================';
  ClogFileName = '.txt';
  { TGameLogFile }

procedure TGameLogFile.AddLog(Icon: string; const LogLevel: integer = 0);
begin
  Icon := Icon+#13#10;
  FileWrite(FText, PChar(Icon)^, Length(ICon));
  //{$I-}
//    Append(FText);
//     Writeln(FText, icon);
//    IOResult;
  //{$I+}
end;

procedure TGameLogFile.AddShow(ICon: string; const Args: array of const; const
  LogLevel: Integer = 0);
begin
  AddLog(Format(ICon, args));
end;

procedure TGameLogFile.AddShow(ICon: string; const LogLevel: Integer = 0);
begin
  AddLog(ICon);
end;

constructor TGameLogFile.Create(Iparth: string);
var
  Ltep: string;
begin
  FIsCreateToNew := False;
  FFileParth := Iparth;
  if not DirectoryExists(FFileParth) then
    if not ForceDirectories(FFileParth) then begin
      raise
        Exception.Create('�����·������־������ܱ�����');
    end;
  if FIsCreateToNew then begin
    Ltep := FormatDateTime('yyyymmddhhnnss', Now);
    FText := (FileCreate(FFileParth + ltep + ClogFileName));
  end
  else
    Ltep := FormatDateTime('yyyymmdd', Now);
  if not FileExists(FFileParth + ltep + ClogFileName) then
    FText := (FileCreate(FFileParth + ltep + ClogFileName))
  else
    FText := (FileOpen(FFileParth + ltep + ClogFileName, fmOpenWrite));
  FileSeek(FText, soFromEnd, soFromEnd);
end;

destructor TGameLogFile.Destroy;
begin
  try
    FileClose(FText);
  except
  end;
  inherited;
end;

{ TGameIO }

function TIOer.AddShow(ICon: string; const Args: array of const; const LogLevel:
  Integer = 0): Integer;
begin
  Result := 0;
  try
    ICon := Format(ICon, Args);
    if FIsAddTime then
      ICon := DateTimeToStr(Now) + ' ' + Icon;
    if FIsNeedSplt then
      ICon := ICon + #13#10 + FSplitChar;
    Result := DoAdd(ICon, LogLevel);
    if assigned(FLog) then
      FLog.AddLog(ICon);
    if Assigned(FAfterShowed) then
      FAfterShowed(ICon);
  except
  end;
end;

function TIOer.AddShow(ICon: string; const LogLevel: Integer = 0): Integer;
begin
  if FIsAddTime then
    ICon := DateTimeToStr(Now) + ' ' + Icon;
  if FIsNeedSplt then
    ICon := ICon + #13#10 + FSplitChar;
  Result := DoAdd(ICon, LogLevel);
  if assigned(FLog) then
    FLog.AddLog(ICon);
  if Assigned(FAfterShowed) then
    FAfterShowed(ICon);
end;

constructor TIOer.Create(IShower: TComponent; IlogFIleDir: string);
begin
  FClearTager := 1000;
  IsAddTime := True;
  FIsNeedSplt := False;
  FSplitChar := CSplitStr;
  FShower := IShower;
  Enabled := True;
  if IlogFIleDir <> '' then
    FLog := TGameLogFile.Create(IlogFIleDir);
end;

destructor TIOer.Destroy;
begin
  if assigned(FLog) then
    FLog.Free;
  inherited;
end;

function TIOer.DoAdd(Icon: string; const LogLevel: Integer = 0): Integer;
var
  ListItem: TListItem;
begin
  Result := -1;
  if Application.Terminated then
    exit;
  if (not Enabled) then
    exit;
  if (FShower is TMemo) then begin
    Result := TMemo(FShower).Lines.Add(Icon);
    if Result >= FClearTager then
      TMemo(FShower).Clear
  end
  else if (FShower is TRichEdit) then begin
    Result := TRichEdit(FShower).Lines.Add(Icon);
    if Result >= FClearTager then
      TRichEdit(FShower).Clear
  end
  else if (FShower is TListBox) then begin
    Result := TListBox(FShower).Items.Add(Icon);
    if Result >= FClearTager then
      TListBox(FShower).Clear
  end
  else if (FShower is TListView) then begin
    ListItem := TListView(FShower).Items.Add;
    ListItem.Caption := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    ListItem.ImageIndex := LogLevel;
    ListItem.SubItems.Add(Icon);
    if TListView(FShower).Items.Count >= FClearTager then
      TListView(FShower).Items.Clear;
  end
  else
    raise Exception.Create('Ĭ����������:' + FShower.ClassName);
end;

end.

