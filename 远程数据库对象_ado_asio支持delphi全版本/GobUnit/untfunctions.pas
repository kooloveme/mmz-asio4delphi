{*******************************************************}
{      ��Ԫ����  untFunctions.pas                       }
{      �������ڣ�2006-01-06 9:07:22                     }
{      ������    ������ QQ 22900104                     }
{      ���ܣ�    �ṩ�����ķ���                         }
{                                                       }
{*******************************************************}

unit untFunctions;

interface
//------------------------------------------------------------------------------
// ���ݴ������ļ�����������Щ����
//------------------------------------------------------------------------------
{$DEFINE Db} //���ݿ��������
{$DEFINE File} //�ļ���������
{.$DEFINE Graph}//ͼ�β�������
{$DEFINE dialog} //�Ի���
{$DEFINE List} //�б�
{$DEFINE Zlib} //ѹ��
{$DEFINE Debug} //������DEBUG
{$DEFINE Message} //��Ϣ
{$DEFINE Process} //����
{$DEFINE TreeView} //��
{$DEFINE Registry}


uses SysUtils

{$IFDEF dialog}
  , dialogs
  , Controls
{$ENDIF}

{$IFDEF Db}
  , Contnrs
  , Variants
  , adodb, db, ComObj
{$ENDIF}

{$IFDEF File}
  , Windows
  , Forms
{$ENDIF}

{$IFDEF Graph}
  , Graphics
{$ENDIF}

{$IFDEF List}
  , Classes
{$ENDIF}

{$IFDEF ZLib}
  , ZLibex
{$ENDIF}
{$IFDEF Message}
  , Messages
{$ENDIF}
{$IFDEF Process}
  , TlHelp32
{$ENDIF}
{$IFDEF TreeView}
  , ComCtrls
{$ENDIF}
{$IFDEF Registry}
  , Registry
{$ENDIF}


  ;

//------------------------------------------------------------------------------
// ���ݿ�
//------------------------------------------------------------------------------

{$IFDEF Db}
const
  CDb_State_NoneUsed = '';
  CDb_State_EverUsed = -1;
  CDb_State_CanUsed = 0;
//------------------------------------------------------------------------------
// ���ݿ������
//------------------------------------------------------------------------------
type
  {���ADO�Ƿ���õ��߳�}
  TDBMrg = class;

  TCheckThread = class(TThread)
  private
    CheckTime: Cardinal;
  public
    DbMrg: TDbmrg;
    procedure Execute; override;
    constructor Create(IsStop: boolean; IDbMrg: TDbmrg);
  end;
  TDBMrg = class
  private
    FConn: TADOConnection;
    FPool: TStringList;
    FName: Integer;
    FAutoFreeConn: boolean;
    FTotCount: Integer;
    FThread_Check: TCheckThread;
    function GetIsConnectioned: Boolean;
  public
    FautoFree: boolean;
    {һ��������BUff ����ʱδ����}
    TepBuff: TADOQuery;
    property IsConnectioned: Boolean read GetIsConnectioned;
    property TotCount: Integer read FTotCount write FTotCount;
    constructor Create(IConStr: string; iTimeOut: integer = 15; ICreateBuffCount:
      Integer = 5); overload;
    constructor Create(IConn: TADOConnection; ICreateBuffCount: Integer = 5);
      overload;
    destructor Destroy; override;
    {��ȡһ��ADO���� ����ָ������ ���û������ ϵͳ�Լ�����һ���ʵĶ���}
    function GetAnQuery(IuserTime: integer = 1; Iname: string = ''): TADOQuery; overload;
    function GetAnQuery(Iname: string): TADOQuery; overload;
    {��ȡ�Զ�������ID����}
    function GetId(ItabName, IFieldName: string): Integer;
    function GetMaxID(ItabName, IFieldName: string): Integer;
    {��ȡ���ϼ�¼�ĸ���}
    function GetCount(ItabName, IFieldName: string; Ivalue: variant): Cardinal;
      overload;
    function GetCount(ItabName: string): Cardinal; overload;
    {�����ֶ�����ֵɾ��������}
    procedure DeleteSomeThing(ItabName, IFieldName: string; Ivalue: Variant);
    {��ȡĳ���ֶε�ֵ}
    function GetSomeThing(ItabName, IGetField, IWhereField: string; Ivalue: Variant): variant;
    {�ж��Ƿ��Ѿ��������ֵ}
    function IsExitThis(ItabName, IFieldName: string; Ivalue: Variant): boolean;
    {�����ݼ��ڶ�λ��¼}
    function FindDataInDataSet(IData: TDataSet; IFieldName, IFieldValue: string; Iopt: TLocateOptions): boolean;
    {ִ��һ�����}
    function ExecAnSql(Isql: string): Integer; overload;
    function ExecAnSql(Isql: string; const Args: array of const): Integer; overload;
    function ExecAnSql(IQueryRight: integer; Isql: string; const Args: array of const): Integer; overload;
    function ExecAnSql(Iado: TADoquery; Isql: string; const Args: array of const): Integer; overload;
    {ִ��һ����ѯ���}
    function OpenDataset(ISql: string): TADOQuery; overload;
    function OpenDataset(Iado: TADoquery; Isql: string): TADOQuery; overload;
    {��ָ���ģ��ģ�ִ��}
    function OpenDataset(IadoName, ISql: string): TADOQuery; overload;
    function OpenDataset(Iado: TADOQuery; ISql: string; const Args: array of const):
      TADOQuery; overload;

    function OpenDataset(ISql: string; const Args: array of const): TADOQuery; overload;
    function OpenDataset(IQueryRight: integer; ISql: string; const Args: array of
      const): TADOQuery; overload;
    {�ͷ�ADOʹ��Ȩ�Ա�������Աʹ��}
    procedure BackToPool(Iado: TADOQuery); overload;
    procedure BackToPool(IName: string); overload;
    {����һ�����ⲿ������ADO ���������������ں�����}
    procedure AddAnOutAdo(Iado: TADOQuery);
    {Ϊ������Ԥ��һ��ADO}
    function Ready(ItabName: string; Iado: TADOQuery): TADOQuery; overload;
    function Ready(ItabName: string; IQueryRight: integer = 1): TADOQuery; overload;
    {��һ����}
    function OpenTable(ItabName: string; Iado: TADOQuery): TADOQuery; overload;
    function OpenTable(ItabName: string; IQueryRight: integer = 1): TADOQuery; overload;

    {����Ƿ��ڿ��޸�״̬}
    function CheckModState(IAdo: TADOQuery): boolean;
    {��ȫ����}
    function SafePost(Iado: TADOQuery): boolean;
    {��ѯ�ܹ��ж��ٸ�ADOquery}
    function PoolCount: Integer;
    {�����ŵ�ADO����}
    function PoolFreeCount: Integer;
    {��ȡ����}
    function GetConn: TADOConnection;
    {��ȡACCESS�����ַ���}
    class function GetAccessConnStr(IDataSource: string; Ipsd: string = ''): string;
    {��ȡMSSQL�����ַ���}
    class function GetMsSQLConnStr(IDataSource, IAcc, Ipsd, IDataBase: string): string;
    {��ȡOracle�����ַ���}
    class function GetOracleConnStr(IDataSource, IAcc, Ipsd: string): string;
    {��ȡExcel�����ַ���}
    class function GetExcelConnStr(IFileName: string): string;
    {��ȡText�����ַ���}
    class function GetTextConnStr(IDBPath: string): string;
    {��ȡDbf�����ַ���}
    class function GetDBFConnStr(IDBPath: string): string;
    {��ȡMySQl�����ַ���}
    class function GetMySqlConnStr(IDataSource, IDbName, IAcc, Ipsd: string): string;
    {����һ����Access���ݿ��ļ�}
    class function CreateAccessFile(IFileName: string): string;
  end;
//------------------------------------------------------------------------------
// һ��ȫ�ֵı���
//------------------------------------------------------------------------------
var
  Gob_DBMrg: TDBMrg = nil;
  {�ָ��ַ����б����� �Զ��ͷ�}
  GlGetEveryWord: TStrings;

  {�жϱ������ǿվͷ���0����''}
function IsNullReturnint(Ivar: Variant): Integer;
function IsNullReturnFloat(Ivar: Variant): Double;
function IsNullReturnStr(Ivar: Variant): string;
{$ENDIF}

//------------------------------------------------------------------------------
// �Ի���
//------------------------------------------------------------------------------
{$IFDEF dialog}
{�������õĶԻ���}
function QueryInfo(Info: string): Boolean; overload;
function QueryInfo(Info: string; const Args: array of const): Boolean; overload;
procedure ErrorInfo(Info: string); overload;
procedure ErrorInfo(Info: string; const Args: array of const); overload;
procedure WarningInfo(Info: string); overload;
procedure WarningInfo(Info: string; const Args: array of const); overload;
procedure TipInfo(Info: string); overload;
procedure TipInfo(Info: string; const Args: array of const); overload;
procedure ExceptTip(Info: string); overload;
procedure ExceptTip(Info: string; const Args: array of const); overload;
procedure ExceptionInfo(Info: string); overload;
{$ENDIF}
//------------------------------------------------------------------------------
// �б�
//------------------------------------------------------------------------------
{$IFDEF List}
{����б�}
procedure ClearList(IList: TStrings; ISFree: boolean = False);
{�ͷ��б�}
procedure ClearAndFreeList(Ilist: TStrings);
{��ӵ��б�}
procedure AddList(Ilist: Tstrings; ICapTion: string; Iobj: TObject);
{��ȡѡ�ж���}
function GetObj(Ilist: TStrings; Iidx: Integer): TObject;
{�ָ��ַ���}
procedure GetEveryWord(S: string; E: TStrings; C: string); overload;
{�ָ��ַ����Զ�ά�����ص�TStrings}
function GetEveryWord(IStr: string; IChar: string): TStrings; overload;

{$ENDIF}
//------------------------------------------------------------------------------
// ͼ��
//------------------------------------------------------------------------------
{$IFDEF Graph}
{RGBTODElphiColor}
function RGB2BGR(C: Cardinal): TColor;
{DelphiColorTORGB}
function BGR2RGB(C: TColor): Cardinal;
{$ENDIF}
//------------------------------------------------------------------------------
// �ļ�
//------------------------------------------------------------------------------

{$IFDEF File}
{�ļ��Ƿ���ʹ����}
function IsFileInUse(FName: string): Boolean;
{ȡWindowsϵͳĿ¼}
function GetWindowsDir: string;
{ȡ��ʱ�ļ�Ŀ¼}
function GetWinTempDir: string;
{����ָ��Ŀ¼���ļ�}
procedure FindFileList(Path, Filter: string; FileList: TStrings; ContainSubDir: Boolean);
{����Ŀ¼���� }
function FixPathName(Ipath: string): string;
{��ȡ�ļ�����}
function GetOnlyFileName(IfileName: string): string;
{��ȡĿ¼�µ��б�}
procedure GetFileDirToStr(var InResp: string; Ipath: string);
{��ȡĿ¼�µ��ļ����б�}
procedure GetFileList(Ilist: TStrings; iFilter, iPath: string; ContainSubDir:
  Boolean = True; INeedPath: boolean = True);
{��ȡĿ¼�µ��ļ����ַ���}
procedure GetFileListToStr(var Resp: string; ISpit: string; iFilter, iPath:
  string; ContainSubDir: Boolean = True; INeedPath: boolean = True);
{���Ϊ�յ�list}
procedure TrimList(Ilist: TStrings; IxmlFileName: string);
{��ȡĿ¼�µ��ļ��к��ļ�}
procedure GetCurrDirToStr(var InResp: string; Ipath: string);
{��ȡĿ¼�µ��ļ��к��ļ���С}
procedure GetCurrDirAndSizeToStr(var InResp: string; Ipath: string);
{ɾ��Ŀ¼}
procedure DelDir(aDir: string; dDel: Boolean = true);
{$ENDIF}


{$IFDEF ZLib}
procedure EnCompressStream(CompressedStream: TMemoryStream);
procedure DeCompressStream(CompressedStream: TMemoryStream);
function EnCompStr(IStr: string): string;
function DeCompStr(IEncPstr: string): string;
{$ENDIF}

{$IFDEF Debug}

{����������̨DEBUG��}
type
  TDeBug = class
  private
    m_hConsole: THandle;
  public
    constructor Create;
    destructor Destroy; override;
    procedure write(str: string);
    procedure read(var str: string);
    procedure ReadAnyKey();
  end;
var
  _Gob_Debug: TDeBug;
  ShowDeBug: boolean = True;
function DeBug(ICon: Variant): Variant; overload;
procedure DeBug(ICon: string; const Args: array of const); overload;
{$ENDIF}


//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------
{IFTHen}
function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer; overload;
function IfThen(AValue: Boolean; const ATrue: Int64; const AFalse: Int64 = 0): Int64; overload;
function IfThen(AValue: Boolean; const ATrue: Double; const AFalse: Double = 0.0): Double; overload;
function IfThen(AValue: Boolean; const ATrue: string; const AFalse: string = ''): string; overload;
function IfThen(AValue: Boolean; const ATrue: boolean; const AFalse: boolean): boolean; overload;

{*����ַ���}
function RandomStr(aLength: Longint): string;
{*����·����ʾ}
function FormatPath(APath: string; Width: Integer): string;
{��ǰ��Ŀ��·��}
function GetCurrPath(IsAutoGetDll: boolean = true): string;
{��ȡ��ǰ��̬���·��}
function GetCurrDllpath: string;
{�ж��Ƿ�������}
function IsallNumber(IStr: string): boolean;
{��ȡ��ʽ���ĵ�ǰʱ��}
function GetFormatTime: string;
{��ȡ��ʽ���ĵ�ǰ���ں�ʱ��}
function GetDocTime: string;
{��ȡ��ʽ���ĵ�ǰ����}
function GetFormatDate: string;
{��ȡ��ʽ���ĵ�ǰ����}
function GetDocDate: string;
{��ȡ���ں�ʱ��}
function GetFormatDateTime: string;
{����ϵͳʱ��}
function SetSystime(ATime: TDateTime): boolean;
{//ϵͳʱ�����ú�����ֻ�Ե�ǰ��Ч ���� ������֮��ķָ����� Ĭ�� -}
function SetSystimeFormat(SS: char = '-'): boolean;




{�Ƿ��ǺϷ�IP}
function IsLegalIP(IP: string): boolean;

{����ֻ����һ��ʵ��}
function AppRunOnce: Boolean;
function AppRunAgian: Integer;
{���Ϳ��������}
{$IFDEF Message}
procedure SendProsData(Ihnd: Integer; var IData; ILen: Integer);
{$ENDIF}

{$IFDEF Process}
function KillTask(ExeFileName: string): integer;
{$ENDIF}

{$IFDEF TreeView}
function TreeNodeMove(mTreeNode: TTreeNode; mAnchorKind: TAnchorKind;
  mIsTry: Boolean = False): Boolean;
{$ENDIF}

{$IFDEF Registry}
{��ȡ����}
function GetDeskeptPath: string;
{��ȡ�ҵ��ĵ�}
function GetMyDoumentpath: string;
{$ENDIF}

{�ַ����򵥼���}
function Str_Encry(ISrc: string; key: string = 'mMz'): string;
{�ַ����򵥽���}
function Str_Decry(ISrc: string; key: string = 'mMz'): string;

{��ȡӲ��ʣ��ռ����}
function GetDiskInfo(IdiskName: string): string;
{ȡ�ļ�����}
function GetFileSize(FileName: string): int64;
function GetFileSize64(const FileName: string): Int64;
{��ȡ�ļ��д�С}
function GetDirectorySize(Path: string): Int64;
{˯���д�����Ϣ}
procedure SleepMy(Itime: Cardinal); overload;
procedure SleepMy(var IVar: boolean; Itime: Cardinal; IIsCaseMsg:
  boolean = True); overload;


{ȫ��/�ָ�һ������}
function FullWindow(IForm: TWinControl): Boolean;

{��סһ������ĸ���}
function LockWindow(Iwnd: HWND): boolean;
{�ָ���ס�Ĵ���}
procedure RestoreWindows;

{����ת��Ϊʱ��}
function SecondsToTime(Seconds: integer): string;

{Ŀ¼����}
function CopyDir(sDirName: string;
  sToDirName: string): Boolean;

{ɾ��Ŀ¼  }
function DeleteDir(sDirName: string): Boolean;

{��ȡ���ֵ�ƴ����ĸ}
function GetPYIndexChar(Ihzchar: string; IlowCase: boolean = False): char;


{ִ�в��ȴ����}
function ExecAndWait(const Filename, Params: string; WindowState: word):
  boolean;
{-------------------------------------------------------------------------------
  ������:    GetBinData
  ����:      ������
  ����:      2006.12.22
  ����:      ISourData:String;IParamNum,ILen:Integer;var IBuff
  ����ֵ:    ��
  ˵��:      ��ȡ����  ISourData��Դ����   IParamNum�ڼ��������Ʋ��� ILen ��������  ����ʵ��
-------------------------------------------------------------------------------}

{���ַ�����ȡ�����������ݲ���д�������}
procedure GetBinData(ISourData: string; IParamNum: integer; IBuff:
  TmemoryStream; ISpit: Char = '|'); overload;
{���ַ�����ȡ�����������ݲ���д�������}
procedure GetBinData(ISourData: pointer; ISourLen: integer; IParamNum, Ilen:
  integer; IBuff: pointer; ISpit: Char = '|'); overload;




implementation

uses ComConst, strutils;



{$IFDEF ZLib}
{-------------------------------------------------------------------------------
  ������:    EnCompressStream
  ����:      ������
  ����:      2006.03.01
  ����:      CompressedStream: TMemoryStream
  ����ֵ:    ��
  ˵��:     ��ѹ������
-------------------------------------------------------------------------------}

procedure EnCompressStream(CompressedStream: TMemoryStream);
var
  SM: TZCompressionStream;
  DM: TMemoryStream;
  Count: int64; //ע�⣬�˴��޸���,ԭ����int
begin
  if CompressedStream.Size <= 0 then
    exit;
  CompressedStream.Position := 0;
  Count := CompressedStream.Size; //�������ԭʼ�ߴ�
  DM := TMemoryStream.Create;
  SM := TZCompressionStream.Create(DM, zcMax);
  try
    CompressedStream.SaveToStream(SM); //SourceStream�б�����ԭʼ����
    SM.Free; //��ԭʼ������ѹ����DestStream�б�����ѹ�������
    CompressedStream.Clear;
    CompressedStream.WriteBuffer(Count, SizeOf(Count)); //д��ԭʼ�ļ��ĳߴ�
    CompressedStream.CopyFrom(DM, 0); //д�뾭��ѹ������
    CompressedStream.Position := 0;
  finally
    DM.Free;
  end;
end;


{-------------------------------------------------------------------------------
  ������:    DeCompressStream
  ����:      ������
  ����:      2006.03.01
  ����:      CompressedStream: TMemoryStream
  ����ֵ:    ��
  ˵��:      ��ѹ������
-------------------------------------------------------------------------------}

procedure DeCompressStream(CompressedStream: TMemoryStream);
var
  MS: TZDecompressionStream;
  Buffer: PChar;
  Count: int64;
begin
  if CompressedStream.Size <= 0 then
    exit;
  CompressedStream.Position := 0; //��λ��ָ��
  CompressedStream.ReadBuffer(Count, SizeOf(Count));
  //�ӱ�ѹ�����ļ����ж���ԭʼ�ĳߴ�
  GetMem(Buffer, Count); //���ݳߴ��СΪ��Ҫ�����ԭʼ�������ڴ��
  MS := TZDecompressionStream.Create(CompressedStream);
  try
    MS.ReadBuffer(Buffer^, Count);
    //����ѹ��������ѹ����Ȼ����� Buffer�ڴ����
    CompressedStream.Clear;
    CompressedStream.WriteBuffer(Buffer^, Count); //��ԭʼ�������� MS����
    CompressedStream.Position := 0; //��λ��ָ��
  finally
    FreeMem(Buffer);
    MS.Free;
  end;
end;

function EnCompStr(IStr: string): string;
//var
//  Lenc, LTe: Pointer;
//  LencLen: Integer;
begin
  Result := IStr;
//  CompressBuf(PChar(IStr), length(IStr), Lenc, LencLen);
//  SetLength(Result, LencLen);
//  CopyMemory(@result, Lenc, LencLen);
//  ShowMessage( IntToStr(length(Result)) );
//  FreeMem(Lenc);
//  DecompressBuf(Result,LencLen,0,LTe,LencLen);
//  ShowMessage(StrPas(LTe));
end;

function DeCompStr(IEncPstr: string): string;
//var
//  Lenc: Pointer;
//  LencLen: Integer;
begin
  Result := IEncPstr;
//  DecompressBuf(@IEncPstr, length(IEncPstr), 0, Lenc, LencLen);
//  Result := StrPas(PChar(Lenc));
//  FreeMem(Lenc);
end;


{$ENDIF}


{$IFDEF TreeView}

function TreeNodeMove(mTreeNode: TTreeNode; mAnchorKind: TAnchorKind;
  mIsTry: Boolean = False): Boolean;
var
  vTreeNode: TTreeNode;
begin
  Result := Assigned(mTreeNode);
  if not Result then
    Exit;
  case mAnchorKind of
    akTop: begin
        vTreeNode := mTreeNode.GetPrev;
        while Assigned(vTreeNode) do begin
          if vTreeNode = mTreeNode.GetPrevSibling then begin
            if not mIsTry then
              mTreeNode.MoveTo(vTreeNode, naInsert);
            Exit;
          end
          else if (vTreeNode.Level = mTreeNode.Level) then begin
            if not mIsTry then
              mTreeNode.MoveTo(vTreeNode, naAdd);
            Exit;
          end
          else if (vTreeNode <> mTreeNode.Parent) and
            (vTreeNode.Level + 1 = mTreeNode.Level) then begin
            if not mIsTry then
              mTreeNode.MoveTo(vTreeNode, naAddChild);
            Exit;
          end;
          vTreeNode := vTreeNode.GetPrev;
        end;
      end;
    akBottom: begin
        vTreeNode := mTreeNode.GetNext;
        while Assigned(vTreeNode) do begin
          if vTreeNode = mTreeNode.GetNextSibling then begin
            if not mIsTry then
              vTreeNode.MoveTo(mTreeNode, naInsert);
            Exit;
          end
          else if (vTreeNode.Level = mTreeNode.Level) then begin
            if not mIsTry then
              mTreeNode.MoveTo(vTreeNode, naAddFirst);
            Exit;
          end
          else if vTreeNode.Level + 1 = mTreeNode.Level then begin
            if not mIsTry then
              mTreeNode.MoveTo(vTreeNode, naAddChildFirst);
            Exit;
          end;
          vTreeNode := vTreeNode.GetNext;
        end;
      end;
    akLeft: begin
        vTreeNode := mTreeNode.Parent;
        if Assigned(vTreeNode) then begin
          if not mIsTry then
            mTreeNode.MoveTo(vTreeNode, naInsert);
          Exit;
        end;
      end;
    akRight: begin
        vTreeNode := mTreeNode.GetNextSibling;
        if Assigned(vTreeNode) then begin
          if not mIsTry then
            mTreeNode.MoveTo(vTreeNode, naAddChildFirst);
          Exit;
        end;
      end;
  end;
  Result := False;
end;

{
begin
  if not (ssCtrl in Shift) then
    Exit;
  case Key of
    VK_UP: TreeNodeMove(TTreeView(Sender).Selected, akTop);
    VK_DOWN: TreeNodeMove(TTreeView(Sender).Selected, akBottom);
    VK_LEFT: TreeNodeMove(TTreeView(Sender).Selected, akLeft);
    VK_RIGHT: TreeNodeMove(TTreeView(Sender).Selected, akRight);
  end;
end;
}


{$ENDIF}


{-------------------------------------------------------------------------------
  ������:    GetCurrPath
  ����:      ������
  ����:      2006.01.09
  ����:      ��
  ����ֵ:    String
  ˵��:      ��ȡ��ǰ��Ŀ��·��
-------------------------------------------------------------------------------}

function GetCurrPath(IsAutoGetDll: boolean = true): string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  if ModuleIsLib and IsAutoGetDll then begin
    GetModuleFileName(HInstance, ModName, SizeOf(ModName));
    Result := ExtractFilePath(ModName);
  end
  else
    Result := ExtractFilePath(ParamStr(0));
end;


function GetCurrDllpath: string;
var
  p: pchar;
begin
  getmem(p, 255);
  try
    getmodulefilename(hinstance, p, 255);
    result := trim(strpas(p));
  finally
    freemem(p, 255);
  end;
end;
{--------------------------------
  ������:    IsallNumber
  ����:      mmz
  ����:      2006.01.06
  ����:      IStr: string
  ����ֵ:    boolean
  ˵��:
-------------------------------------------------------------------------------}

function IsallNumber(IStr: string): boolean;
var
  i: Integer;
begin
  if Length(IStr) = 0 then begin
    Result := False;
    Exit;
  end;
  Result := True;
  for I := 1 to Length(IStr) do begin // Iterate
    if not (IStr[i] in ['0'..'9']) then begin
      Result := False;
      Exit;
    end;
  end; // for
end;

{-------------------------------------------------------------------------------
  ������:    GetDateTime
  ����:      ������
  ����:      2006.01.15
  ����:      ��
  ����ֵ:    String
  ˵��:      ��ȡ��ʽ����ʱ��
-------------------------------------------------------------------------------}

function GetFormatTime: string;
begin
  Result := FormatDateTime('hh:nn:ss', now);
end;

function GetDocTime: string;
begin
  Result := FormatDateTime('hhnnss', Time);
end;

function GetFormatDate: string;
begin
  Result := FormatDateTime('yyyy-mm-dd', Date);
end;

function GetDocDate: string;
begin
  Result := FormatDateTime('yyyymmdd', Date);
end;

function GetFormatDateTime: string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;


function SetSystimeFormat(SS: char = '-'): boolean;
var s: boolean;
begin
  //change the application's date time format.
  DateSeparator := SS;
  shortdateformat := 'YYYY' + SS + 'MM' + SS + 'DD';
  ShortTimeFormat := 'hh:mm:ss';
  TimeAMString := '';
  TimePMString := '';
  s := application.UpdateFormatSettings;
  // by luyear 20020709
  result := s;
end;

function SetSystime(ATime: TDateTime): boolean;
var
  ADateTime: TSystemTime;
  yy, mon, dd, hh, min, ss, ms: Word;
begin
  decodedate(ATime, yy, mon, dd);
  decodetime(ATime, hh, min, ss, ms);
  with ADateTime do begin
    wYear := yy;
    wMonth := mon;
    wDay := dd;
    wHour := hh;
    wMinute := min;
    wSecond := ss;
    wMilliseconds := ms;
  end;
  Result := SetLocalTime(ADateTime);
 // PostMessage(HWND_BROADCAST, WM_TIMECHANGE, 0, 0);
end;


{$IFDEF Registry}


function GetShellFolders(strDir: string): string;
const
  regPath = '\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
  Reg: TRegistry;
  strFolders: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(regPath, false) then begin
      strFolders := Reg.ReadString(strDir);
    end;
  finally
    Reg.Free;
  end;
  result := strFolders;
end;

{��ȡ����}

function GetDeskeptPath: string;
begin
  Result := GetShellFolders('Desktop'); //��ȡ�������ļ��е�·��
end;

{��ȡ�ҵ��ĵ�}

function GetMyDoumentpath: string;
begin
  Result := GetShellFolders('Personal'); //�ҵ��ĵ�
end;
{$ENDIF}



function IsLegalIP(IP: string): boolean;
var
  i, j, l: integer;
  ips: array[1..4] of string;
begin
  i := 1;
  for l := 1 to 4 do
    ips[l] := '';
  for j := 1 to length(ip) do
    if ip[j] <> '.' then begin
      if (ip[j] < '0') or (ip[j] > '9') then begin
        Result := false;
        exit;
      end;
      ips[i] := ips[i] + ip[j]
    end
    else
      inc(i);

  if (i <> 4)
    or ((strtoint(ips[1]) > 255) or (strtoint(ips[1]) < 0)) //originally is <1
    or ((strtoint(ips[2]) > 255) or (strtoint(ips[2]) < 0))
    or ((strtoint(ips[3]) > 255) or (strtoint(ips[3]) < 0))
    or ((strtoint(ips[4]) > 255) or (strtoint(ips[4]) < 0)) then
    Result := false
  else
    Result := true;
end;


{-------------------------------------------------------------------------------
  ������:    AppRunOnce
  ����:      ������
  ����:      2006.02.28
  ����:      ��
  ����ֵ:    Boolean
  ˵��:      ����ֻ����һ��ʵ��
-------------------------------------------------------------------------------}

function AppRunOnce: Boolean;
var
  HW: Thandle;
  sClassName, sTitle: string;
begin
  sClassName := application.ClassName;
  sTitle := application.Title;
  Randomize;
  application.Title := Format('F982D120-BA%dE-4199-%dFBD-F4EED%dE8A7',
    [random(20), Random(50), random(100)]); //���ĵ�ǰapp����
  HW := findwindow(pchar(sClassName), pchar(sTitle));
  if HW <> 0 then begin
  //  ShowWindow(HW, SW_SHOW);
    SetForegroundWindow(HW);
    application.Terminate;
  end;
  application.Title := sTitle; //�ָ�app����
  result := Hw = 0;
end;

{���ش���0�ʹ����Ѿ�����}

function AppRunAgian: Integer;
var
  HW: Thandle;
  sClassName, sTitle: string;
begin
  sClassName := application.ClassName;
  sTitle := application.Title;
  Randomize;
  application.Title := Format('F982D120-BA%dE-4199-%dFBD-F4EED%dE8A7',
    [random(20), Random(50), random(100)]); //���ĵ�ǰapp����
  HW := findwindow(pchar(sClassName), pchar(sTitle));
  if HW <> 0 then begin
    ShowWindow(HW, SW_SHOW);
    SetForegroundWindow(HW);
  end;
  application.Title := sTitle; //�ָ�app����
  result := Hw;
end;

{$IFDEF Process}

function KillTask(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot
    (TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := Sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle,
    FProcessEntry32);
  while integer(ContinueLoop) <> 0 do begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName))
      or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(
        PROCESS_TERMINATE, BOOL(0),
        FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle,
      FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;
{$ENDIF}

{$IFDEF Message}

{-------------------------------------------------------------------------------
  ������:    SendProsData
  ����:      ������
  ����:      2006.07.27
  ����:      ISendHnd, Ihnd: Integer; var IData; ILen: Integer
  ����ֵ:    ��
  ˵��:      ISendHnd ���͵��ߵĴ�����
-------------------------------------------------------------------------------}

procedure SendProsData(Ihnd: Integer; var IData; ILen: Integer);
var
  Lds: TCopyDataStruct;
begin
  Lds.cbData := ILen;
  Lds.lpData := Pointer(IData);
  SendMessage(Ihnd, WM_COPYDATA, 0, integer(@Lds));
end;
{$ENDIF}

function GetDiskInfo(IdiskName: string): string;
var
 // lpFreeBytesAvailableToCaller, lpUsedBytes: int64;
  lpFreeBytesAvailableToCaller: int64;
  lpTotalNumberOfBytes: int64;
  lpTotalNumberOfFreeBytes: TLargeInteger;
  sDrive: string;
begin
  sDrive := IdiskName + ':\';
  if GetDriveType(pchar(sDrive)) = DRIVE_FIXED then begin
    GetDiskFreeSpaceEx(PChar(sDrive), lpFreeBytesAvailableToCaller,
      lpTotalNumberOfBytes, @lpTotalNumberOfFreeBytes);
   // lpUsedBytes := lpTotalNumberOfBytes - lpFreeBytesAvailableToCaller;
    Result := IntToStr(lpFreeBytesAvailableToCaller div 1024 div 1024) + 'M'
      + ' / ' + IntToStr(lpTotalNumberOfBytes div 1024 div 1024) + 'M';
  end;
end;

{-------------------------------------------------------------------------------
  ������:    GetFileSize
  ����:      ������
  ����:      2006.01.06
  ����:      FileName: string
  ����ֵ:    Integer
  ˵��:      ȡ�ļ�����
-------------------------------------------------------------------------------}

function GetFileSize(FileName: string): int64;
var
  SearchRec: TSearchRec;
begin
  try
    if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then begin
      Result := SearchRec.Size;
      if Result < 0 then
        Result := GetFileSize64(FileName);
    end
    else
      Result := -1;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;


function GetFileSize64(const FileName: string): Int64;
var
  LStream: TFileStream;
begin
  if FileExists(FileName) = False then begin
    Result := -1;
    exit;
  end;
{$WARNINGS OFF}
  LStream := TFileStream.Create(FileName, fmShareDenyNone);
{$WARNINGS ON}
  try
    Result := LStream.Size;
  finally
    LStream.Free;
  end;
end;

function GetDirectorySize(Path: string): Int64;
var
  SR: TSearchRec;
begin
  Result := 0;
  if FindFirst(Path + '*.*', faAnyFile, SR) = 0 then begin
    if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr = faDirectory) then
      Result := Result + GetDirectorySize(Path + Sr.Name + '\')
    else
      Result := Result + Sr.Size;
    while FindNext(sr) = 0 do
      if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr = faDirectory) then
        Result := Result + GetdirectorySize(Path + Sr.Name + '\')
      else
        Result := Result + GetFileSize(Path + Sr.Name);
    Sysutils.FindClose(sr);
  end;
end;



procedure SleepMy(Itime: Cardinal);
var
  LS: Cardinal;
begin
  LS := GetTickCount;
  while GetTickCount - LS < Itime do begin
    if Application.Terminated then
      exit;
    Application.ProcessMessages;
    Sleep(10);
  end; // while
end;

procedure SleepMy(var IVar: boolean; Itime: Cardinal; IIsCaseMsg: boolean = True);
var
  LS: Cardinal;
begin
  LS := GetTickCount;
  while (GetTickCount - LS < Itime) and (not IVar) do begin
    Application.ProcessMessages;
    if Application.Terminated then
      exit;
    Sleep(10);
  end; // while
end;

function LockWindow(Iwnd: HWND): boolean;
begin
  Result := LockWindowUpdate(Iwnd);
end;

procedure RestoreWindows;
begin
  LockWindowUpdate(0);
end;

var
  _Form, _Parent: Cardinal; _OldLeft, _OldTop, _OldW, _OldH, _SavWL1: integer;
  _Alg: TAlign;

function FullWindow(IForm: TWinControl): Boolean;
begin
  Result := False;
//  LockWindowUpdate(IForm.Handle);
//  try
  {���=�ʹ���ȫ��}
  if cardinal(IForm) <> _Form then begin
    _Form := integer(IForm);
    _OldLeft := IForm.Left;
    _OldTop := IForm.Top;
    _OldW := IForm.Width;
    _OldH := IForm.Height;
    _Parent := IForm.Parent.Handle;
    _Alg := IForm.Align;
    IForm.Align := alNone;
    _SavWL1 := GetWindowLong(IForm.Handle, GWL_STYLE);
    SetParent(IForm.Handle, 0);
   // SetWindowLong(IForm.Handle, GWL_STYLE, Integer(WS_POPUP or WS_VISIBLE));
    SetWindowPos(IForm.Handle, HWND_TOPMOST, -6, -6, Screen.Width + 12, Screen.Height + 12, SWP_DRAWFRAME or SWP_FRAMECHANGED);
    Result := True;
  end {����ʹ���ָ�}
  else begin
    _Form := 0;
    IForm.Left := _OldLeft;
    IForm.Top := _OldTop;
    IForm.Width := _OldW;
    IForm.Height := _OldH;
    SetWindowLong(IForm.Handle, GWL_STYLE, _SavWL1);
    SetWindowPos(IForm.Handle, HWND_NOTOPMOST, _OldLeft, _OldTop, _OldW, _OldH, SWP_DRAWFRAME or SWP_FRAMECHANGED);
    SetParent(IForm.Handle, _Parent);
    IForm.Align := _Alg;
    IForm.Parent.Show;
  end;
//  finally
//     LockWindowUpdate(0);
//  end;
end;

function DoCopyDir(sDirName: string;
  sToDirName: string): Boolean;
var
  hFindFile: Cardinal;
  t, tfile: string;
  sCurDir: string[255];
  FindFileData: WIN32_FIND_DATA;
begin
  //�ȱ��浱ǰĿ¼
  sCurDir := GetCurrentDir;
  ChDir(sDirName);
  hFindFile := FindFirstFile('*.*', FindFileData);
  if hFindFile <> INVALID_HANDLE_VALUE then begin
    if not DirectoryExists(sToDirName) then
      ForceDirectories(sToDirName);
    repeat
      tfile := FindFileData.cFileName;
      if (tfile = '.') or (tfile = '..') then
        Continue;
      if FindFileData.dwFileAttributes =
        FILE_ATTRIBUTE_DIRECTORY then begin
        t := sToDirName + '\' + tfile;
        if not DirectoryExists(t) then
          ForceDirectories(t);
        if sDirName[Length(sDirName)] <> '\' then
          DoCopyDir(sDirName + '\' + tfile, t)
        else
          DoCopyDir(sDirName + tfile, sToDirName + tfile);
      end
      else begin
        t := sToDirName + '\' + tFile;
        CopyFile(PChar(tfile), PChar(t), True);
      end;
    until FindNextFile(hFindFile, FindFileData) = false;
    windows.FindClose(hFindFile);
  end
  else begin
    ChDir(sCurDir);
    result := false;
    exit;
  end;
  //�ص�ԭ����Ŀ¼��
  ChDir(sCurDir);
  result := true;
end;

function CopyDir(sDirName: string;
  sToDirName: string): Boolean;
begin
  Result := False;
  if Length(sDirName) <= 0 then
    exit;
  //����...
  Result := DoCopyDir(sDirName, sToDirName);
end;

function DoRemoveDir(sDirName: string): Boolean;
var
  hFindFile: Cardinal;
  tfile: string;
  sCurDir: string;
  bEmptyDir: Boolean;
  FindFileData: WIN32_FIND_DATA;
begin
//���ɾ�����ǿ�Ŀ¼,����bEmptyDirΪTrue
//��ʼʱ,bEmptyDirΪTrue
  bEmptyDir := True;
//�ȱ��浱ǰĿ¼
  sCurDir := GetCurrentDir;
  SetLength(sCurDir, Length(sCurDir));
  ChDir(sDirName);
  hFindFile := FindFirstFile('*.*', FindFileData);
  if hFindFile <> INVALID_HANDLE_VALUE then begin
    repeat
      tfile := FindFileData.cFileName;
      if (tfile = '.') or (tfile = '..') then begin
        bEmptyDir := bEmptyDir and True;
        Continue;
      end;
//���ǿ�Ŀ¼,��bEmptyDirΪFalse
      bEmptyDir := False;
      if FindFileData.dwFileAttributes =
        FILE_ATTRIBUTE_DIRECTORY then begin
        if sDirName[Length(sDirName)] <> '\' then
          DoRemoveDir(sDirName + '\' + tfile)
        else
          DoRemoveDir(sDirName + tfile);
        if not RemoveDirectory(PChar(tfile)) then
          result := false
        else
          result := true;
      end
      else begin
        if not DeleteFile(PChar(tfile)) then
          result := false
        else
          result := true;
      end;
    until FindNextFile(hFindFile, FindFileData) = false;
    FindClose(hFindFile);
  end
  else begin
    ChDir(sCurDir);
    result := false;
    exit;
  end;
//����ǿ�Ŀ¼,��ɾ���ÿ�Ŀ¼
  if bEmptyDir then begin
//������һ��Ŀ¼
    ChDir('..');
//ɾ����Ŀ¼
    RemoveDirectory(PChar(sDirName));
  end;

//�ص�ԭ����Ŀ¼��
  ChDir(sCurDir);
  result := true;
end;
//ɾ��Ŀ¼�ĺ�����DeleteDir

function DeleteDir(sDirName: string): Boolean;
begin
  Result := False;
  if Length(sDirName) <= 0 then
    exit;
  Result := DoRemoveDir(sDirName) and RemoveDir(sDirName);
end;


function ExecAndWait(const Filename, Params: string; WindowState: word):
  boolean;
var
  SUInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
begin
  CmdLine := filename + ' ' + params;
  FillChar(SUInfo, SizeOf(SUInfo), #0);
  with SUInfo do begin
    cb := SizeOf(SUInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WindowState;
  end;
  Result := CreateProcess(nil, PChar(CmdLine), nil, nil, FALSE,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
    PChar(ExtractFilePath(Filename)), SUInfo, ProcInfo);
  if Result then begin
    //�ȴ�Ӧ�ó������
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    //ɾ�����
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;
end;

function GetPYIndexChar(Ihzchar: string; IlowCase: boolean = False): char;
var
  LS: string;
begin
  case WORD(Ihzchar[1]) shl 8 + WORD(Ihzchar[2]) of
    $B0A1..$B0C4: result := 'A';
    $B0C5..$B2C0: result := 'B';
    $B2C1..$B4ED: result := 'C';
    $B4EE..$B6E9: result := 'D';
    $B6EA..$B7A1: result := 'E';
    $B7A2..$B8C0: result := 'F';
    $B8C1..$B9FD: result := 'G';
    $B9FE..$BBF6: result := 'H';
    $BBF7..$BFA5: result := 'J';
    $BFA6..$C0AB: result := 'K';
    $C0AC..$C2E7: result := 'L';
    $C2E8..$C4C2: result := 'M';
    $C4C3..$C5B5: result := 'N';
    $C5B6..$C5BD: result := 'O';
    $C5BE..$C6D9: result := 'P';
    $C6DA..$C8BA: result := 'Q';
    $C8BB..$C8F5: result := 'R';
    $C8F6..$CBF9: result := 'S';
    $CBFA..$CDD9: result := 'T';
    $CDDA..$CEF3: result := 'W';
    $CEF4..$D1B8: result := 'X';
    $D1B9..$D4D0: result := 'Y';
    $D4D1..$D7F9: result := 'Z';
  else
    result := 'x';
  end;
  if IlowCase then begin
    LS := Result;
    LS := LowerCase(LS);
    Result := ls[1];
  end;
end;


procedure GetBinData(ISourData: pointer; ISourLen: integer; IParamNum, Ilen:
  integer; IBuff: pointer; ISpit: Char = '|');
var
  sLtep, slBuff: string;
  lp: PChar;
  Charlen: Integer;
begin
  slBuff := leftStr(StrPas(PAnsiChar(ISourData)), ISourLen);
  sLtep := '*' + IntToStr(IParamNum);
  Charlen := Pos(sLtep, slBuff) + Length(sLtep) - 1;
  lp := ISourData;
  inc(lp, Charlen);
  CopyMemory(ibuff, lp, Ilen);
end;

procedure GetBinData(ISourData: string; IParamNum: integer; IBuff:
  TmemoryStream; ISpit: Char = '|');
var
  i: Integer;
  sLtep, sLlen: string;
  iLlen, x: Integer;
begin
  sLtep := '*' + IntToStr(IParamNum);
  iLlen := Pos(sLtep, ISourData);
  x := 0;
  for i := iLlen downto 1 do begin // Iterate
    if ISourData[i] <> ISpit then
      inc(x)
    else
      break;
  end; // for
  sLlen := copy(ISourData, iLlen - x + 1, x - 1);
  IBuff.SetSize(StrToInt(sLlen));
  CopyMemory(IBuff.Memory, PChar(ISourData) + Pos(sLtep, ISourData) + Length(sLtep), StrToInt(sLlen));
end;



function SecondsToTime(Seconds: integer): string;
var m, s: integer;
begin
  if Seconds < 0 then
    Seconds := 0;
  m := (Seconds div 60) mod 60;
  s := Seconds mod 60;
  Result := IntToStr(Seconds div 3600)
    + ':' + char(48 + m div 10) + char(48 + m mod 10)
    + ':' + char(48 + s div 10) + char(48 + s mod 10);
end;

function Str_Encry(ISrc: string; key: string = 'mMz'): string;
var
  KeyLen: Integer;
  KeyPos: Integer;
  offset: Integer;
  dest: string;
  SrcPos: Integer;
  SrcAsc: Integer;
  Range: Integer;
begin
  KeyLen := Length(Key);
  KeyPos := 0;
  Range := 256;
  Randomize;
  offset := Random(Range);
  dest := format('%1.2x', [offset]);
  for SrcPos := 1 to Length(ISrc) do begin
    SrcAsc := (Ord(ISrc[SrcPos]) + offset) mod 255;
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    SrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    dest := dest + format('%1.2x', [SrcAsc]);
    offset := SrcAsc;
  end;
  Result := Dest;
end;

function Str_Decry(ISrc: string; key: string = 'mMz'): string;
var
  KeyLen: Integer;
  KeyPos: Integer;
  offset: Integer;
  dest: string;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
begin
  KeyLen := Length(Key);
  KeyPos := 0;
  offset := StrToInt('$' + copy(ISrc, 1, 2));
  SrcPos := 3;
  SrcAsc := 0;
  repeat
    try
      SrcAsc := StrToInt('$' + copy(ISrc, SrcPos, 2));
    except
    end;
    if KeyPos < KeyLen then
      KeyPos := KeyPos + 1
    else
      KeyPos := 1;
    TmpSrcAsc := SrcAsc xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= offset then
      TmpSrcAsc := 255 + TmpSrcAsc - offset
    else
      TmpSrcAsc := TmpSrcAsc - offset;
    dest := dest + chr(TmpSrcAsc);
    offset := srcAsc;
    SrcPos := SrcPos + 2;
  until SrcPos >= Length(ISrc);
  Result := Dest;
end;
{-------------------------------------------------------------------------------
  ������:    FormatPath
  ����:      ������
  ����:      2006.01.06
  ����:      APath: string; Width: Integer
  ����ֵ:    string
  ˵��:      ·��̫����ʾ��ʱ����...����
-------------------------------------------------------------------------------}

function FormatPath(APath: string; Width: Integer): string;
var
  SLen: Integer;
  i, j: Integer;
  LString: string;
begin
  SLen := Length(APath);
  if (SLen <= Width) or (Width <= 6) then begin
    Result := APath;
    Exit
  end
  else begin
    i := SLen;
    LString := APath;
    for j := 1 to 2 do begin
      while (LString[i] <> '\') and (SLen - i < Width - 8) do
        i := i - 1;
      i := i - 1;
    end;
    for j := SLen - i - 1 downto 0 do
      LString[Width - j] := LString[SLen - j];
    for j := SLen - i to SLen - i + 2 do
      LString[Width - j] := '.';
    Delete(LString, Width + 1, 255);
    Result := LString;
  end;
end;

{-------------------------------------------------------------------------------
  ������:    RandomStr
  ����:      mmz
  ����:      2006.01.06
  ����:      aLength : Longint
  ����ֵ:    String
  ˵��:      ����ַ���
-------------------------------------------------------------------------------}

function RandomStr(aLength: Longint): string;
var
  X: Longint;
begin
  if aLength <= 0 then
    exit;
  SetLength(Result, aLength);
  for X := 1 to aLength do
    Result[X] := Chr(Random(26) + 65);
end;


{-------------------------------------------------------------------------------
  ������:    IfThen
  ����:      ������
  ����:      2006.01.06
  ����:      AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0
  ����ֵ:    Integer
  ˵��:
-------------------------------------------------------------------------------}

function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer; overload;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

{-------------------------------------------------------------------------------
  ������:    IfThen
  ����:      ������
  ����:      2006.01.06
  ����:      AValue: Boolean; const ATrue: Int64; const AFalse: Int64 = 0
  ����ֵ:    Int64
  ˵��:
-------------------------------------------------------------------------------}

function IfThen(AValue: Boolean; const ATrue: Int64; const AFalse: Int64 = 0): Int64; overload;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

{-------------------------------------------------------------------------------
  ������:    IfThen
  ����:      ������
  ����:      2006.01.06
  ����:      AValue: Boolean; const ATrue: Double; const AFalse: Double = 0.0
  ����ֵ:    Double
  ˵��:
-------------------------------------------------------------------------------}

function IfThen(AValue: Boolean; const ATrue: Double; const AFalse: Double = 0.0): Double; overload;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function IfThen(AValue: Boolean; const ATrue: string; const AFalse: string = ''): string; overload;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function IfThen(AValue: Boolean; const ATrue: boolean; const AFalse: boolean): boolean; overload;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;
{$IFDEF File}
{-------------------------------------------------------------------------------
  ������:    IsFileInUse
  ����:      ������
  ����:      2006.01.06
  ����:      FName: string
  ����ֵ:    Boolean
  ˵��:      �ļ��Ƿ���ʹ����
-------------------------------------------------------------------------------}

function IsFileInUse(FName: string): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FName) then
    Exit;
  HFileRes := CreateFile(PChar(FName), GENERIC_READ or GENERIC_WRITE, 0,
    nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;



{-------------------------------------------------------------------------------
  ������:    GetWindowsDir
  ����:      ������
  ����:      2006.01.06
  ����:      ��
  ����ֵ:    string
  ˵��:     ȡWindowsϵͳĿ¼
-------------------------------------------------------------------------------}

function GetWindowsDir: string;
var
  Buf: array[0..MAX_PATH] of Char;
begin
  GetWindowsDirectory(Buf, MAX_PATH);
  Result := Buf;
end;

{-------------------------------------------------------------------------------
  ������:    GetWinTempDir
  ����:      ������
  ����:      2006.01.06
  ����:      ��
  ����ֵ:    string
  ˵��:      ȡ��ʱ�ļ�Ŀ¼
-------------------------------------------------------------------------------}

function GetWinTempDir: string;
var
  Buf: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, Buf);
  Result := Buf;
end;
{$ENDIF}

{$IFDEF Graph}

{-------------------------------------------------------------------------------
  ������:    RGB2BGR
  ����:      ������
  ����:      2006.01.06
  ����:      C: Cardinal
  ����ֵ:    TColor
  ˵��:
-------------------------------------------------------------------------------}

function RGB2BGR(C: Cardinal): TColor;
var
  R, G, B: byte;
  RGBColor: Longint;
begin
  RGBColor := ColorToRGB(C);
  R := GetRValue(RGBColor);
  G := GetGValue(RGBColor);
  B := GetBValue(RGBColor);
  Result := RGB(B, G, R);
end;

{-------------------------------------------------------------------------------
  ������:    BGR2RGB
  ����:      ������
  ����:      2006.01.06
  ����:      C: TColor
  ����ֵ:    Cardinal
  ˵��:
-------------------------------------------------------------------------------}

function BGR2RGB(C: TColor): Cardinal;
var
  R, G, B: byte;
begin
  B := GetRValue(C);
  G := GetGValue(C);
  R := GetBValue(C);
  Result := RGB(R, G, B);
end;
{$ENDIF}




{$IFDEF dialog}

{-------------------------------------------------------------------------------
  ������:    TipInfo
  ����:      ������
  ����:      2006.01.06
  ����:      Info: string
  ����ֵ:    ��
  ˵��:
-------------------------------------------------------------------------------}

procedure TipInfo(Info: string);
begin
  MessageDlg(Info, mtInformation, [mbok], 0)
end;

procedure TipInfo(Info: string; const Args: array of const);
begin
  MessageDlg(Format(Info, Args), mtInformation, [mbok], 0)
end;
{-------------------------------------------------------------------------------
  ������:    WarningInfo
  ����:      ������
  ����:      2006.01.06
  ����:      Info: string
  ����ֵ:    ��
  ˵��:
-------------------------------------------------------------------------------}

procedure WarningInfo(Info: string);
begin
  MessageDlg(Info, mtWarning, [mbok], 0);
end;

procedure WarningInfo(Info: string; const Args: array of const);
begin
  MessageDlg(Format(Info, Args), mtWarning, [mbok], 0);
end;
{-------------------------------------------------------------------------------
  ������:    ErrorInfo
  ����:      ������
  ����:      2006.01.06
  ����:      Info: string
  ����ֵ:    ��
  ˵��:
-------------------------------------------------------------------------------}

procedure ErrorInfo(Info: string);
begin
  MessageDlg(Info, mtError, [mbok], 0)
end;

procedure ErrorInfo(Info: string; const Args: array of const);
begin
  ErrorInfo(Format(Info, Args));
end;

{-------------------------------------------------------------------------------
  ������:    QueryInfo
  ����:      ������
  ����:      2006.01.06
  ����:      Info: string
  ����ֵ:    Boolean
  ˵��:
-------------------------------------------------------------------------------}

function QueryInfo(Info: string): Boolean;
begin
  Result := MessageDlg(Info, mtConfirmation, [mbYES, mbNO], 0) = mrYES;
end;

function QueryInfo(Info: string; const Args: array of const): Boolean; overload;
begin
  Result := MessageDlg(Format(info, Args), mtConfirmation, [mbYES, mbNO], 0) = mrYES;
end;

{-------------------------------------------------------------------------------
  ������:    ExceptTip
  ����:      ������
  ����:      2006.01.06
  ����:      Info: string
  ����ֵ:    ��
  ˵��:
-------------------------------------------------------------------------------}

procedure ExceptTip(Info: string);
begin
  MessageDlg(Info, mtInformation, [mbok], 0);
  Abort;
end;

procedure ExceptTip(Info: string; const Args: array of const);
begin
  MessageDlg(Format(Info, Args), mtInformation, [mbok], 0);
  Abort;
end;

procedure ExceptionInfo(Info: string);
begin
  raise Exception.Create(Info);
end;

{-------------------------------------------------------------------------------
  ������:    IsNullBackStr
  ����:      ������
  ����:      2006.01.06
  ����:      Ivar: Variant
  ����ֵ:    string
  ˵��:
-------------------------------------------------------------------------------}
{$ENDIF}

{$IFDEF List}
{-------------------------------------------------------------------------------
  ������:    GetObj
  ����:      ������
  ����:      2006.01.06
  ����:      Ilist: TStrings; Iidx: Integer
  ����ֵ:    TObject
  ˵��:
-------------------------------------------------------------------------------}

function GetObj(Ilist: TStrings; Iidx: Integer): TObject;
begin
  Result := Ilist.Objects[Iidx];
end;

{-------------------------------------------------------------------------------
  ������:    AddList
  ����:      ������
  ����:      2006.01.06
  ����:      Ilist: Tstrings; ICapTion: string; Iobj: Tobject
  ����ֵ:    ��
  ˵��:
-------------------------------------------------------------------------------}

procedure AddList(Ilist: Tstrings; ICapTion: string; Iobj: Tobject);
begin
  Ilist.AddObject(ICapTion, Iobj);
end;

{-------------------------------------------------------------------------------
  ������:    ClearList
  ����:      ������
  ����:      2006.01.06
  ����:      IList: TStrings
  ����ֵ:    ��
  ˵��:
-------------------------------------------------------------------------------}

procedure ClearList(IList: TStrings; ISFree: boolean = False);
var
  i: Integer;
begin
  for I := 0 to IList.Count - 1 do begin
    try
      IList.Objects[i].free;
    except
    end;
  end;
  IList.Clear;
  if ISFree then
    IList.Free;
end;

procedure ClearAndFreeList(Ilist: TStrings);
begin
  ClearList(Ilist);
  FreeAndNil(Ilist);
end;

{-------------------------------------------------------------------------------
  ������:    GetOnlyFileName
  ����:      ������
  ����:      2006.01.06
  ����:      IfileName:String
  ����ֵ:    string
  ˵��:      ��ȡ�ļ����� ����·���ͺ�׺
-------------------------------------------------------------------------------}

function GetOnlyFileName(IfileName: string): string;
var
  Tmp, Ext: string;
begin
  Tmp := ExtractFileName(IfileName);
  Ext := ExtractFileExt(IfileName);
  Result := copy(Tmp, 1, Length(Tmp) - Length(Ext));
end;

{-------------------------------------------------------------------------------
  ������:    GetEveryWord
  ����:      ������
  ����:      2006.01.06
  ����:      S: string; E: TStringList; C: string
  ����ֵ:    ��
  ˵��:      �ָ��ַ��� ���ص�StringList���ⲿ�Լ������ڴ�
-------------------------------------------------------------------------------}

procedure GetEveryWord(S: string; E: TStrings; C: string);
var
  t, a: string;
begin
  if E = nil then
    E := TStringList.Create
  else
    E.Clear;
  t := s;
  while Pos(c, t) > 0 do begin
    a := copy(t, 1, pos(c, t) - 1);
    t := copy(t, pos(c, t) + 1, length(t) - pos(c, t));
    e.Add(a);
  end;
  if Trim(t) <> '' then
    e.Add(t);
end;

function GetEveryWord(IStr: string; IChar: string): TStrings;
var
  t, a: string;
begin
  if assigned(GlGetEveryWord) = False then
    GlGetEveryWord := TStringList.Create;
  GlGetEveryWord.Clear;
  t := IStr;
  while Pos(IChar, t) > 0 do begin
    a := copy(t, 1, pos(IChar, t) - 1);
    t := copy(t, pos(IChar, t) + 1, length(t) - pos(IChar, t));
    GlGetEveryWord.Add(a);
  end;
  if Trim(t) <> '' then
    GlGetEveryWord.Add(t);
  Result := GlGetEveryWord;
end;

{-------------------------------------------------------------------------------
  ������:    FindFileList
  ����:      ������
  ����:      2006.01.16
  ����:      path:·��, filter:�ļ���չ������, FileList:�ļ��б�, ContainSubDir:�Ƿ������Ŀ¼
  ����ֵ:    ��
  ˵��:     ����һ��·���µ������ļ���
-------------------------------------------------------------------------------}

procedure FindFileList(Path, Filter: string; FileList: TStrings; ContainSubDir: Boolean);
var
  FSearchRec, DSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  FindResult := FindFirst(path + Filter, sysutils.faAnyFile, FSearchRec);
  while FindResult = 0 do begin
    FileList.Add(FSearchRec.Name);
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
  if ContainSubDir then begin
    FindResult := FindFirst(path + Filter, faDirectory, DSearchRec);
    while FindResult = 0 do begin
      if ((DSearchRec.Attr and faDirectory) = faDirectory)
        and (DSearchRec.Name <> '.') and (DSearchRec.Name <> '..') then
        FindFileList(Path, Filter, FileList, ContainSubDir);
      FindResult := FindNext(DSearchRec);
    end;
    sysutils.FindClose(DSearchRec);
  end;
end;

{����Ŀ¼���� }

function FixPathName(Ipath: string): string;
var
  Ls: string;
begin
  Result := Ipath;
  Ls := Copy(Result, length(Result), 1);
  if ls <> '\' then
    Result := Result + '\';
end;

{��ȡ�ļ���Ϊ�ַ���}

procedure GetFileDirToStr(var InResp: string; Ipath: string);
var
  FSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  Ipath := FixPathName(Ipath);
  FindResult := FindFirst(Ipath + '*.*', sysutils.faAnyFile, FSearchRec);
  while FindResult = 0 do begin
    if (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    InResp := InResp + FSearchRec.Name;
    if (FSearchRec.Attr = 16) or (FSearchRec.Attr = 48) then begin
      InResp := InResp + '**';
      GetFileDirToStr(InResp, Ipath + FSearchRec.Name + '\');
    end
    else
      InResp := InResp + '*';
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
end;

procedure TrimList(Ilist: TStrings; IxmlFileName: string);
var
  i: Integer;
  ls: string;
begin
  for i := Ilist.Count - 1 downto 0 do begin // Iterate
    ls := Ilist.Strings[i];
    if (Trim(ls) = '') or (Trim(ls) = ' ') or (ExtractFileName(Trim(ls)) = IxmlFileName) or (ExtractFileName(Trim(ls)) = 'database.xml') then
      Ilist.Delete(i);
  end; // for
end;

procedure GetFileListToStr(var Resp: string; ISpit: string; iFilter, iPath:
  string; ContainSubDir: Boolean = True; INeedPath: boolean = True);
var
  FSearchRec, DSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  FindResult := FindFirst(iPath + iFilter, sysutils.faAnyFile, FSearchRec);

  while FindResult = 0 do begin
    if ((FSearchRec.Attr and faDirectory) = faDirectory) or (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    if INeedPath then
      Resp := Resp + (iPath + FSearchRec.Name)
    else
      Resp := Resp + FSearchRec.Name;
    Resp := Resp + ISpit;
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
  if ContainSubDir then begin
    FindResult := FindFirst(iPath + iFilter, faDirectory, DSearchRec);
    while FindResult = 0 do begin
      if ((DSearchRec.Attr and faDirectory) = faDirectory)
        and (DSearchRec.Name <> '.') and (DSearchRec.Name <> '..') then begin
        GetFileListToStr(Resp, ISpit, iFilter, iPath + DSearchRec.Name + '\', ContainSubDir);
      end;
      FindResult := FindNext(DSearchRec);
    end;
  end;
  sysutils.FindClose(DSearchRec);
end;


procedure GetFileList(Ilist: TStrings; iFilter, iPath: string; ContainSubDir:
  Boolean = True; INeedPath: boolean = True);
var
  FSearchRec, DSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  FindResult := FindFirst(iPath + iFilter, sysutils.faAnyFile, FSearchRec);
  while FindResult = 0 do begin
    if ((FSearchRec.Attr and faDirectory) = faDirectory) or (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    if INeedPath then
      Ilist.Add(iPath + FSearchRec.Name)
    else
      Ilist.Add(FSearchRec.Name);
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
  if ContainSubDir then begin
    FindResult := FindFirst(iPath + iFilter, faDirectory, DSearchRec);
    while FindResult = 0 do begin
      if ((DSearchRec.Attr and faDirectory) = faDirectory)
        and (DSearchRec.Name <> '.') and (DSearchRec.Name <> '..') then
        GetFileList(Ilist, iFilter, iPath + DSearchRec.Name + '\', ContainSubDir);
      FindResult := FindNext(DSearchRec);
    end;
    sysutils.FindClose(DSearchRec);
  end;
end;

procedure GetCurrDirAndSizeToStr(var InResp: string; Ipath: string);
var
  FSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  Ipath := FixPathName(Ipath);
  {�����ļ���}
  FindResult := FindFirst(Ipath + '*.*', sysutils.faAnyFile, FSearchRec);

  while FindResult = 0 do begin
    if (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    if (FSearchRec.Attr = 16) or (FSearchRec.Attr = 48) then begin
      InResp := InResp + FSearchRec.Name;
      InResp := InResp + ',' + IntToStr(GetDirectorySize(Ipath + FSearchRec.Name));
      InResp := InResp + '*';
    end;
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
  if InResp <> '' then
    InResp := InResp + '|';
  FindResult := FindFirst(Ipath + '*.*', sysutils.faAnyFile, FSearchRec);
  while FindResult = 0 do begin
    if (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    if (FSearchRec.Attr <> 16) and (FSearchRec.Attr <> 48) then begin
      InResp := InResp + FSearchRec.Name;
      InResp := InResp + ',' + IntToStr(FSearchRec.Size);
      InResp := InResp + '*';
    end;
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
end;

procedure GetCurrDirToStr(var InResp: string; Ipath: string);
var
  FSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  Ipath := FixPathName(Ipath);
  {�����ļ���}
  FindResult := FindFirst(Ipath + '*.*', sysutils.faAnyFile, FSearchRec);
  while FindResult = 0 do begin
    if (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    if (FSearchRec.Attr = 16) or (FSearchRec.Attr = 48) then begin
      InResp := InResp + FSearchRec.Name;
      InResp := InResp + '*';
    end;
    FindResult := FindNext(FSearchRec);
  end;
  if InResp <> '' then
    InResp := InResp + '|';

  sysutils.FindClose(FSearchRec);
  FindResult := FindFirst(Ipath + '*.*', sysutils.faAnyFile, FSearchRec);
  while FindResult = 0 do begin
    if (FSearchRec.Name = '.') or (FSearchRec.Name = '..') then begin
      FindResult := FindNext(FSearchRec);
      Continue;
    end;
    if (FSearchRec.Attr <> 16) and (FSearchRec.Attr <> 48) then begin
      InResp := InResp + FSearchRec.Name;
      InResp := InResp + '*';
    end;
    FindResult := FindNext(FSearchRec);
  end;
  sysutils.FindClose(FSearchRec);
end;



procedure DelDir(aDir: string; dDel: Boolean = true);
var
  i: Integer;
  aFsr: TSearchRec;
  dLst: TStrings;
  str: string;
begin
  if not DirectoryExists(aDir) then
    Exit;
  dLst := TStringList.Create;
  i := FindFirst(aDir + '*.*', faAnyFile, aFsr);
  while i = 0 do begin
    if (aFsr.Attr = faDirectory) then begin
      if (aFsr.Name <> '.') and (aFsr.Name <> '..') then
        dLst.Add(aDir + aFsr.Name + '\')
    end
    else try
      DeleteFile(PChar(aDir + aFsr.Name));
    except
    end;
    i := FindNext(aFsr);
  end;
  sysutils.FindClose(aFsr);
  for i := 0 to Pred(dLst.Count) do begin
    str := ExpandFileName(dLst[i]);
    if (Pos(aDir, str) = 1) and (Length(str) = Length(aDir)) then
      DelDir(dLst[i], True);
  end;
  dLst.Free;
  if dDel then
    RemoveDir(aDir);
end;

{$ENDIF}


{$IFDEF db}

function IsNullReturnStr(Ivar: Variant): string;
begin
  if VarIsNull(Ivar) then
    Result := ''
  else
    Result := Ivar;
end;

{-------------------------------------------------------------------------------
  ������:    IsNullBackFloat
  ����:      ������
  ����:      2006.01.06
  ����:      Ivar: Variant
  ����ֵ:    Double
  ˵��:
-------------------------------------------------------------------------------}

function IsNullReturnFloat(Ivar: Variant): Double;
begin
  if VarIsNull(Ivar) then
    Result := 0
  else
    Result := Ivar;
end;

{-------------------------------------------------------------------------------
  ������:    IsNullBackint
  ����:      ������
  ����:      2006.01.06
  ����:      Ivar: Variant
  ����ֵ:    Integer
  ˵��:
-------------------------------------------------------------------------------}

function IsNullReturnint(Ivar: Variant): Integer;
begin
  if VarIsNull(Ivar) then
    Result := 0
  else
    Result := Ivar;
end;



{ TBaseDbMrg }

constructor TDBMrg.Create(IConStr: string; iTimeOut: integer = 15;
  ICreateBuffCount: Integer = 5);
var
  I: Integer;
begin
  FautoFree := true;
  FName := 0;
  FTotCount := 500;
  FAutoFreeConn := True;
  FConn := TADOConnection.Create(nil);
  FConn.ConnectionTimeout := iTimeOut;
  FConn.LoginPrompt := False;
  FPool := TStringList.Create;
  FConn.ConnectionString := IConStr;
  try
    FConn.Connected := True;
  except
  end;

  
  for I := 0 to ICreateBuffCount do
    GetAnQuery();
  FThread_Check := TCheckThread.Create(False, Self);
end;

constructor TDBMrg.Create(IConn: TADOConnection; ICreateBuffCount: Integer = 5);
var
  I: Integer;
begin
  FautoFree := true;
  FName := 0;
  FTotCount := 500;
  FConn := IConn;
  if IConn <> nil then
    FConn.LoginPrompt := False;
  FAutoFreeConn := False;
  FPool := TStringList.Create;
  for I := 0 to ICreateBuffCount - 1 do
    GetAnQuery();
  FThread_Check := TCheckThread.Create(False, Self);
end;

destructor TDBMrg.Destroy;
var
  I: Integer;
begin
  FThread_Check.Terminate;
  if FAutoFreeConn then
    FConn.Free;
  for I := 0 to FPool.Count - 1 do
    FPool.Objects[i].Free;
  FPool.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.AddAnOutAdo
  ����:      ������
  ����:      2006.01.11
  ����:      Iado: TADOQuery
  ����ֵ:    ��
  ˵��:      ����һ�����ⲿ������ADO ���������������ں�����
-------------------------------------------------------------------------------}

procedure TDBMrg.AddAnOutAdo(Iado: TADOQuery);
begin
  Iado.Close;
  Iado.Connection := FConn;
  if PoolCount + 1 > FTotCount then
    raise Exception.Create('�Ѿ��ﵽ����޶Ȳ�����������µ�QUERY');
  Iado.Tag := FPool.AddObject(CDb_State_NoneUsed, Iado);
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.BackToPool
  ����:      ������
  ����:      2006.01.11
  ����:      Iado: TADOQuery
  ����ֵ:    ��
  ˵��:     �ͷ�ADOʹ��Ȩ�Ա�������Աʹ��
-------------------------------------------------------------------------------}

procedure TDBMrg.BackToPool(IName: string);
var
  I: Integer;
begin
  for I := 0 to FPool.Count - 1 do begin // Iterate
    if TADOQuery(FPool.Objects[i]).Name = IName then begin
      FPool.Strings[i] := CDb_State_NoneUsed;
    end;
  end; // for
end;

procedure TDBMrg.BackToPool(Iado: TADOQuery);
begin
  if Iado = nil then
    Exit;
  try
    FPool.Strings[Iado.Tag] := CDb_State_NoneUsed;
  except
    raise Exception.Create('�ع�Adoquery��ʱ���쳣 Tag���Ա��ı�');
  end;
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.DeleteSomeThing
  ����:      ������
  ����:      2006.01.11
  ����:      ItabName, IFieldName: string; Ivalue: Variant
  ����ֵ:    ��
  ˵��:     �����ֶ�����ֵɾ��������
-------------------------------------------------------------------------------}

procedure TDBMrg.DeleteSomeThing(ItabName, IFieldName: string;
  Ivalue: Variant);
begin
  with GetAnQuery(CDb_State_CanUsed) do begin
    try
      Close;
      SQL.Text := Format('Delete from %s where %s=:VarIant', [ItabName, IFieldName]);
      Parameters.ParamValues['VarIant'] := Ivalue;
      ExecSQL;
    finally
      Close;
    end;
  end; // with
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.ExecAnSql
  ����:      ������
  ����:      2006.01.11
  ����:      Isql: string
  ����ֵ:    Integer
  ˵��:      ִ��һ�����
-------------------------------------------------------------------------------}

function TDBMrg.ExecAnSql(Isql: string): Integer;
begin
  with GetAnQuery do begin
    try
      Close;
      SQL.Clear;
      SQL.Add(Isql);
      Result := ExecSQL;
    finally // wrap up
      Close;
    end; // try/finally
  end; // with
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.GetAnQuery
  ����:      ������
  ����:      2006.01.11
  ����:      Iname: string
  ����ֵ:    TADOQuery
  ˵��:��ȡһ��ADO���� ����ָ������ ���û������ ϵͳ�Լ�����һ���ʵĶ���
-------------------------------------------------------------------------------}

function TDBMrg.GetAnQuery(Iname: string): TADOQuery;
var
  I: Integer;
begin
  Result := nil;
  if PoolCount > FTotCount then begin
    raise Exception.Create('AdoQuery�Ѿ��ﵽ�����������������ز�����������¶���' + #13
      + '�����Ƿ��������ǻع�ADOQUERY������');
    Exit;
  end;
  if Iname <> '' then begin
    for I := 0 to FPool.Count - 1 do
      if TADOQuery(FPool.Objects[i]).Name = 'MyPool' + Iname then begin
        Result := TADOQuery(FPool.Objects[i]);
        Exit;
      end;
    Result := TADOQuery.Create(nil);
    Result.Connection := FConn;
    Result.Name := 'MyPool' + Iname;
    Result.Tag := FPool.AddObject(IntToStr(CDb_State_EverUsed), Result);
  end;
end;


function TDBMrg.GetAnQuery(IuserTime: integer = 1; Iname: string = ''):
  TADOQuery;
var
  I: Integer;
  LState: string;
begin
  if IuserTime = CDb_State_CanUsed then
    LState := ''
  else
    LState := IntToStr(IuserTime);
  if PoolCount > FTotCount then begin
    raise Exception.Create('AdoQuery�Ѿ��ﵽ�����������������ز�����������¶���' + #13
      + '�����Ƿ��������ǻع�ADOQUERY������');
    Exit;
  end;
  if Iname <> '' then begin
    for I := 0 to FPool.Count - 1 do
      if TADOQuery(FPool.Objects[i]).Name = 'MyPool' + Iname then begin
        Result := TADOQuery(FPool.Objects[i]);
        FPool.Strings[i] := LState;
        Exit;
      end;
    Result := TADOQuery.Create(nil);
    Result.Connection := FConn;
    Result.Name := 'MyPool' + Iname;
    Result.Tag := FPool.AddObject(IntToStr(CDb_State_EverUsed), Result);
  end
  else begin
    for I := 0 to FPool.Count - 1 do begin // Iterate
      if (FPool.Strings[i] = CDb_State_NoneUsed) then begin
        Result := TADOQuery(FPool.Objects[i]);
        FPool.Strings[i] := LState;
        Exit;
      end;
    end; // for
    Result := TADOQuery.Create(nil);
    Result.Connection := FConn;
    Inc(FName);
    Result.Name := 'MyPool' + IntToStr(FName);
    Result.Tag := FPool.AddObject(LState, Result);
  end;
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.GetConn
  ����:      ������
  ����:      2006.01.11
  ����:      ��
  ����ֵ:    TADOConnection
  ˵��:      ��ȡ����
-------------------------------------------------------------------------------}

function TDBMrg.GetConn: TADOConnection;
begin
  Result := FConn;
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.GetCount
  ����:      ������
  ����:      2006.01.11
  ����:      ItabName, IFieldName: string; Ivalue: variant
  ����ֵ:    Integer
  ˵��:      ��ȡ���ϼ�¼�ĸ���
-------------------------------------------------------------------------------}

function TDBMrg.GetCount(ItabName, IFieldName: string; Ivalue: variant):
  Cardinal;
begin
  with GetAnQuery do begin
    Close;
    SQL.Text := Format('Select Count(%s) as MyCount from %s where %s=:variant',
      [IFieldName, ItabName, IFieldName]);
    Parameters.ParamValues['VarIant'] := Ivalue;
    try
      Open;
      Result := Fieldbyname('MyCount').AsInteger;
    except
      Result := 0;
    end;
  end; // with
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.GetId
  ����:      ������
  ����:      2006.01.11
  ����:      ItabName, IFieldName: string
  ����ֵ:    Integer
  ˵��:      ��ȡ�Զ�������ID����
-------------------------------------------------------------------------------}

function TDBMrg.GetId(ItabName, IFieldName: string): Integer;
begin
  Result := 0;
  with GetAnQuery do begin
    Close;
    SQL.Text := Format('Select Max(%s) as myMax  from  %s', [IFieldName, ItabName]);
    Open;
    if FieldByName('MyMax').AsInteger > 0 then
      Result := FieldByName('MyMax').AsInteger;
  end; // with
  inc(Result);
end;

function TDBMrg.GetMaxID(ItabName, IFieldName: string): Integer;
begin
  Result := 0;
  with GetAnQuery do begin
    Close;
    SQL.Text := Format('Select Max(%s) as myMax  from  %s', [IFieldName, ItabName]);
    Open;
    if FieldByName('MyMax').AsInteger > 0 then
      Result := FieldByName('MyMax').AsInteger;
  end; // with
end;


{-------------------------------------------------------------------------------
  ������:    TDBMrg.GetSomeThing
  ����:      ������
  ����:      2006.01.11
  ����:      ItabName, IGetField, IWHereField: string; Ivalue: Variant
  ����ֵ:    variant
  ˵��:      ��ȡĳ���ֶε�ֵ
-------------------------------------------------------------------------------}

function TDBMrg.GetSomeThing(ItabName, IGetField, IWHereField: string;
  Ivalue: Variant): variant;
begin
  with GetAnQuery(CDb_State_CanUsed) do begin
    try
      Close;
      SQL.Text := Format('Select %s as MyGetField from %s where %s=:VarIant', [IGetField, ItabName, IWHereField]);
      Parameters.ParamValues['VarIant'] := Ivalue;
      Open;
      if RecordCount > 0 then
        Result := FieldValues['MyGetField']
      else
        Result := Unassigned;
    finally
      Close;
    end;
  end; // with
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.IsExitThis
  ����:      ������
  ����:      2006.01.11
  ����:      ItabName, IFieldName: string; Ivalue: Variant
  ����ֵ:    boolean
  ˵��:     �ж��Ƿ��Ѿ��������ֵ
-------------------------------------------------------------------------------}

function TDBMrg.IsExitThis(ItabName, IFieldName: string;
  Ivalue: Variant): boolean;
begin
  Result := False;
  with GetAnQuery(CDb_State_CanUsed) do begin
    try
      Close;
      SQL.Text := Format('Select Count(%s) as MyCount from %s where %s=:variant',
        [IFieldName, ItabName, IFieldName]);
      Parameters.ParamValues['VarIant'] := Ivalue;
      Open;
      if Fieldbyname('MyCount').AsInteger > 0 then
        Result := True;
    finally
      Close;
    end;
  end; // with
end;



{-------------------------------------------------------------------------------
  ������:    TDBMrg.OpenDataset
  ����:      ������
  ����:      2006.01.11
  ����:      ISql: string
  ����ֵ:    TADOQuery
  ˵��:      ִ��һ����ѯ��� �ǵ�ʹ����黹��Close��
-------------------------------------------------------------------------------}

function TDBMrg.OpenDataset(ISql: string): TADOQuery;
begin
  Result := GetAnQuery;
  with Result do begin
    Close;
    SQL.Clear;
    SQL.Add(ISql);
    Open;
  end; // with
end;


{-------------------------------------------------------------------------------
  ������:    TDBMrg.OpenDataset
  ����:      ������
  ����:      2006.01.11
  ����:      IadoName, ISql: string
  ����ֵ:    TADOQuery
  ˵��:      ��ָ���ģ��ģ�ִ��
-------------------------------------------------------------------------------}

function TDBMrg.OpenDataset(IadoName, ISql: string): TADOQuery;
begin
  Result := GetAnQuery(IadoName);
  with Result do begin
    Close;
    SQL.Clear;
    SQL.Add(ISql);
    Open;
  end; // with
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.PoolCount
  ����:      ������
  ����:      2006.01.11
  ����:      ��
  ����ֵ:    Integer
  ˵��:      ��ѯ�ܹ��ж��ٸ�ADOquery
-------------------------------------------------------------------------------}

function TDBMrg.PoolCount: Integer;
begin
  Result := FPool.Count;
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.PoolFreeCount
  ����:      ������
  ����:      2006.01.11
  ����:      ��
  ����ֵ:    Integer
  ˵��:      �����ŵ�ADO����
-------------------------------------------------------------------------------}

function TDBMrg.PoolFreeCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FPool.Count - 1 do
    if TADOQuery(FPool.Objects[i]).IsEmpty then
      Inc(Result);
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.FindDataInDataSet
  ����:      ������
  ����:      2006.01.11
  ����:      IData: TDataSet; IFieldName, IFieldValue: string; Iopt: TLocateOptions
  ����ֵ:    boolean
  ˵��:      �����ݼ��ڶ�λ��¼
-------------------------------------------------------------------------------}

function TDBMrg.FindDataInDataSet(IData: TDataSet; IFieldName,
  IFieldValue: string; Iopt: TLocateOptions): boolean;
var
  i, BeginNO: Integer;
  LfieldValue, LThenValue: string;
begin
  Result := false;
  with TADOQuery(IData) do begin
    IData.DisableControls;
    try
      BeginNO := IData.RecNo;
      for i := IData.RecNo to IData.RecordCount - 1 do begin // Iterate
        LfieldValue := LowerCase(Idata.FieldByName(IFieldName).AsString);
        LThenValue := LowerCase(IFieldValue);
        if loPartialKey in Iopt then begin
          if Pos(LThenValue, LfieldValue) > 0 then begin
            Result := True;
            Break;
          end;
        end
        else if CompareText(LThenValue, LfieldValue) = 0 then begin
          Result := True;
          Break;
        end;
        IData.Next;
      end; // for
      if not Result then
        Idata.RecNo := BeginNO;
    finally
      Idata.EnableControls;
    end;
  end; // with
end;

class function TDBMrg.GetAccessConnStr(IDataSource: string; Ipsd: string = ''):
  string;
begin
  if Ipsd <> '' then
    Result := Format('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Persist Security' +
      ' Info=True;Jet OLEDB:Database Password=%s;', [IDataSource, Ipsd])
  else
    Result := Format('Provider=Microsoft.Jet.OLEDB.4.0;Password="";Data Source=%s;Mode=Share Deny None;' +
      ' Extended Properties = ""', [IDataSource]);
end;

{$ENDIF}

class function TDBMrg.GetExcelConnStr(IFileName: string): string;
begin
  Result := Format('Provider = Microsoft.Jet.OLEDB.4.0;Data Source ' +
    '= %s; Extended Properties = EXCEL 8.0; Persist Security Info = False;', [IFileName]);
end;

class function TDBMrg.GetMsSQLConnStr(IDataSource, IAcc, Ipsd, IDataBase:
  string): string;
begin
  Result := Format('Provider=SQLOLEDB.1;Password=%s;Persist Security Info=' +
    'True;User ID=%s;Initial Catalog=%s;Data Source=%s', [Ipsd, IAcc,
    IDataBase, IDataSource]);
end;

class function TDBMrg.GetOracleConnStr(IDataSource, IAcc, Ipsd: string): string;
begin
  Result := Format('Provider=OraOLEDB.Oracle.1;Password=%s;Persist Security Info=True;' +
    'User ID=%s;Data Source=%s', [Ipsd, IAcc, IDataSource]);
end;


class function TDBMrg.GetDBFConnStr(IDBPath: string): string;
begin
  Result := Format('Provider=MSDASQL.1;Persist Security Info=False; Extended ' +
    'Properties="Driver={Microsoft Visual FoxPro Driver};UID=;SourceDB=%s;' +
    'SourceType=DBF;Exclusive=No;BackgroundFetch=Yes;Collate=PINYIN;Null=Yes;Deleted=no;"',
    [IDBPath]);
end;

class function TDBMrg.GetTextConnStr(IDBPath: string): string;
begin
  Result := Format('Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=%s' +
    ';Extended Properties=text', [IDBPath]);
end;

function TDBMrg.GetCount(ItabName: string): Cardinal;
begin
  with GetAnQuery(CDb_State_CanUsed) do begin
    Close;
    SQL.Text := Format('Select Count(*) as MyCount from %s',
      [ItabName]);
    Open;
    Result := Fieldbyname('MyCount').AsInteger;
  end; // with
end;

{-------------------------------------------------------------------------------
  ������:    TDBMrg.Ready
  ����:      ������
  ����:      2006.02.21
  ����:      ItabName:string;Iado:TADOQuery
  ����ֵ:    ��
  ˵��:      Ϊ������Ԥ��һ��ADO
-------------------------------------------------------------------------------}

function TDBMrg.Ready(ItabName: string; Iado: TADOQuery): TADOQuery;
begin
  with Iado do begin
    Close;
    SQL.Text := Format('Select * from %s where 1=2', [ItabName]);
    Open;
  end; // with
  Result := Iado;
end;

function TDBMrg.Ready(ItabName: string; IQueryRight: integer = 1): TADOQuery;
begin
  Result := GetAnQuery(IQueryRight);
  with TADOQuery(Result) do begin
    Close;
    SQL.Text := Format('Select * from %s where 1=2', [ItabName]);
    Open;
  end; // with
end;


function TDBMrg.OpenDataset(IQueryRight: integer; ISql: string; const Args: array
  of const): TADOQuery;
begin
  ISql := Format(Isql, Args);
  Result := GetAnQuery(IQueryRight);
  with Result do begin
    Close;
    SQL.Clear;
    SQL.Add(ISql);
    Open;
  end; // with
end;

function TDBMrg.ExecAnSql(Isql: string;
  const Args: array of const): Integer;
begin
  Isql := Format(Isql, Args);
  with GetAnQuery do begin
    try
      Close;
      SQL.Clear;
      SQL.Add(Isql);
      Result := ExecSQL;
    finally // wrap up
      Close;
    end; // try/finally
  end; // with
end;

{ TCheckThread }

constructor TCheckThread.Create(IsStop: boolean; IDbMrg: TDbmrg);
begin
  inherited Create(IsStop);
  CheckTime := GetTickCount;
  DbMrg := IDbMrg;
  FreeOnTerminate := True;
end;

procedure TCheckThread.Execute;
var
  I: Integer;
begin
  while not Terminated do begin
    if ModuleIsLib then begin
      sleep(100);
      Continue;
    end;

    if GetTickCount - CheckTime < 1000 then
      Sleep(100)
    else begin
      CheckTime := GetTickCount;
      with DbMrg.FPool do begin
        for I := DbMrg.FPool.Count - 1 downto 0 do begin // Iterate
          {����ǿ��õľ�����}
          if Strings[i] = CDb_State_NoneUsed then
            Continue;
          if StrToInt(Strings[i]) = CDb_State_EverUsed then
            Continue;
          {���򵹼�ʱ���Զ��½�1��}
          try
            {�����0�ͱ�ʾΪ����}
            if Strings[i] = '0' then
              Strings[i] := CDb_State_NoneUsed
            else
              Strings[i] := Format('%d', [StrToInt(Strings[i]) - 1]);
          except
            Strings[i] := CDb_State_NoneUsed;
          end;
        end; // for
      end; // with
    end;
  end; // while
end;


function TDBMrg.OpenDataset(ISql: string;
  const Args: array of const): TADOQuery;
begin
  ISql := Format(Isql, Args);
  Result := GetAnQuery;
  with Result do begin
    Close;
    SQL.Clear;
    SQL.Add(ISql);
    Open;
  end; // with
end;


function OpenDataset(Iado: TADOQuery; ISql: string):
  TADOQuery; overload;
begin
  Result := Iado;
  with Result do begin
    Close;
    SQL.Text := ISql;
    Open;
  end; // with
end;


function TDBMrg.OpenDataset(Iado: TADOQuery; ISql: string; const Args: array of
  const): TADOQuery;
begin
  ISql := Format(Isql, Args);
  Result := Iado;
  with Result do begin
    Close;
    SQL.Clear;
    SQL.Add(ISql);
    Open;
  end; // with
end;

function TDBMrg.ExecAnSql(IQueryRight: integer; Isql: string;
  const Args: array of const): Integer;
begin
  Isql := Format(Isql, Args);
  with GetAnQuery(IQueryRight) do begin
    try
      Close;
      SQL.Clear;
      SQL.Add(Isql);
      Result := ExecSQL;
    finally // wrap up
      Close;
    end; // try/finally
  end; // with
end;

function TDBMrg.ExecAnSql(Iado: TADoquery; Isql: string; const Args: array of const): Integer;
begin
  Isql := Format(Isql, Args);
  with Iado do begin
    try
      Close;
      SQL.Clear;
      SQL.Add(Isql);
      Result := ExecSQL;
    finally // wrap up
      Close;
    end; // try/finally
  end; // with
end;


class function TDBMrg.GetMySqlConnStr(IDataSource, IDbName, IAcc, Ipsd: string):
  string;
begin
  Result := Format('DRIVER={MySQL ODBC 3.51 Driver};SERVER=%s;DATABASE=%s;UID=%s;PASSWORD=%s;OPTION=3',
    [IDataSource, IDbName, IAcc, Ipsd]);
end;

function TDBMrg.OpenTable(ItabName: string; Iado: TADOQuery): TADOQuery;
begin
  with Iado do begin
    Close;
    SQL.Text := Format('Select * from %s ', [ItabName]);
    Open;
  end; // with
  Result := Iado;
end;

function TDBMrg.CheckModState(IAdo: TADOQuery): boolean;
begin
  Result := IAdo.State in [dsEdit, dsinsert];
end;

function TDBMrg.SafePost(Iado: TADOQuery): boolean;
begin
  Result := CheckModState(Iado);
  if Result then
    Iado.Post;
end;

function TDBMrg.OpenTable(ItabName: string; IQueryRight: integer = 1): TADOQuery;
begin
  Result := GetAnQuery(IQueryRight);
  with TADOQuery(Result) do begin
    Close;
    SQL.Text := Format('Select * from %s ', [ItabName]);
    Open;
  end; // with
end;

{ TDeBug }
{$IFDEF Debug}

constructor TDeBug.Create;
begin
  AllocConsole;
  m_hConsole := CreateConsoleScreenBuffer(GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CONSOLE_TEXTMODE_BUFFER, nil);
  SetConsoleActiveScreenBuffer(m_hConsole);
  SetConsoleMode(m_hConsole, ENABLE_LINE_INPUT or ENABLE_ECHO_INPUT);
  SetConsoleTitle('С���������Debug����');
end;

destructor TDeBug.Destroy;
begin
  FreeConsole;
  inherited;
end;

procedure TDeBug.read(var str: string);
var
  n: DWORD;
  buf: array[0..256] of char;
begin
  n := 0;
  ReadConsole(m_hConsole, @buf[0], 256, n, nil);
  SetString(str, PChar(@buf[0]), Integer(n));
end;


procedure TDeBug.ReadAnyKey;
var
  s: string;
begin
  self.write('�����������....');
  Self.read(s);
end;

procedure TDeBug.write(str: string);
var
  n: DWORD;
begin
  WriteConsole(m_hConsole,
    PChar(GetFormatTime + '-> ' + str + #13#10),
    Length(GetFormatTime + '-> ' + str) + 2,
    n,
    nil);
end;

function DeBug(ICon: Variant): Variant;
var
  LStr: string;
begin
  if not assigned(_Gob_Debug) then
    _Gob_Debug := TDeBug.Create;
  if ShowDeBug then begin
    LStr := ICon;
    _Gob_Debug.write(LStr);
  end;
  Result := LStr;
end;

procedure DeBug(ICon: string; const Args: array of const);
begin
  DeBug(Format(ICon, Args));
end;
{$ENDIF}

class function TDBMrg.CreateAccessFile(IFileName: string): string;
var
  CreateAccess: OleVariant;
begin
  CreateAccess := CreateOleObject('ADOX.Catalog');
  CreateAccess.Create('Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + IFilename);
end;

function TDBMrg.GetIsConnectioned: Boolean;
begin
  if Assigned(FConn) then
  begin
    Result := FConn.Connected;
  end
  else
  begin
    Result := False;
  end;
end;


function TDBMrg.OpenDataset(Iado: TADOQuery; ISql: string): TADOQuery;
begin
  Result := Iado;
  with Result do begin
    Close;
    SQL.Clear;
    SQL.Add(ISql);
    Open;
  end; // with
end;

initialization

finalization
{$IFDEF Db}
//------------------------------------------------------------------------------
// ���ʹ���˾��Զ��ͷ�
//------------------------------------------------------------------------------
  if assigned(Gob_DBMrg) then begin
    try
      if Gob_DBMrg.FautoFree then
        Gob_DBMrg.free;
    except
    end;
  end;
{$ENDIF}
{$IFDEF Debug}
  if assigned(_Gob_Debug) then
    _Gob_Debug.Free;
{$ENDIF}
  if assigned(GlGetEveryWord) then
    GlGetEveryWord.Free;
end.

