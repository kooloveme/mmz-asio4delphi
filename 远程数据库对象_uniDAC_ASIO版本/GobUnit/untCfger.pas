{*******************************************************}
{      ��Ԫ����  UntCFGer.pas                           }
{      �������ڣ�2006-1-15 0:32:12                      }
{      ������    ������ QQ 22900104                     }
{      ���ܣ�    �������ļ��ķ�װ��Ԫ ʡȥ�������ͷŵ�  }
{                ����                                   }
{                                                       }
{*******************************************************}

unit UntCFGer;

interface

uses IniFiles;

type
  TCFGer = class
  private
  public
    opter: TMemIniFile;
    {��ǰ�Ľ�}
    CurrSecton: string;
    constructor Create(ICfg: string);
    destructor Destroy; override;
//------------------------------------------------------------------------------
// ��ȡһЩ���õ����� 2006-3-16 ������
//------------------------------------------------------------------------------
    procedure SetSecton(iSecton: string);
    function ReadString(IName: string; IDefaultValue: string = ''): string;
    procedure WriteString(IName: string; IValue: string);
    function Readint(IName: string; IDefaultValue: integer = 0): Integer;
    procedure Writeint(IName: string; IValue: Integer);
    function ReadBoolean(IName: string; IDefaultValue: Boolean = False): Boolean;
    procedure WriteBoolean(IName: string; IValue: Boolean);
    function ReadDateTime(IName: string; IDefaultValue: TDateTime): TDateTime;
    procedure WriteDateTime(IName: string; IValue: TDateTime);
  published

  end;
var
  Gob_CFGer: TCFGer;

procedure AssignCfgFile(IfileName: string);


//------------------------------------------------------------------------------
// ����һЩ���õ������ַ��� 2006-3-16 ������
//------------------------------------------------------------------------------
const
  CCfg_fileName = 'sys.ini';

  CCFG_Secon_Server = 'server';
  CCFG_Server_ServerPort = 'serverPort';
  CCFG_Server_ServerIP = 'ServerIP';

  CCFG_Secon_App = 'Application';
  CCFG_APP_Title = 'Title';
  CCFG_APP_Vison = 'Vison';

  CCFG_Secon_AutoUpdata = 'AutoUpdata';
  CCFG_AutoUpdata_IsEnable = 'IsEnable';
  CCFG_AutoUpdata_RmoServerIni = 'RmoServerIni';
  CCFG_AutoUpdata_IsAutoUpdata = 'IsAutoUpdata';
  CCFG_AutoUpdata_IsFindNewAsk = 'IsFindNewAsk';
  CCFG_AutoUpdata_IsUpdatedAsk = 'IsUpdatedAsk';
  CCFG_AutoUpdata_IsHintInUpdateFault = 'IsHintInUpdateFault';
  CCFG_AutoUpdata_OnHaventNewVison = 'OnHaventNewVison';

  CCFG_Secon_DB = 'DB';
  CCFG_DB_FileName = 'FileName';
  CCFG_DB_OnCreateBuff = 'BuffCount';
  CCFG_DB_IsBkupOnCreateApp = 'IsBkupOnCreateApp';
  CCFG_DB_UpdateDay = 'UpdateDay';
  CCFG_DB_LastBkTime = 'LastBkTime';
  CCFG_DB_backupdir = 'backupdir';




implementation

uses SysUtils;

{ TCFGer }

{-------------------------------------------------------------------------------
  ������:    AssignCfgFile
  ����:      ������
  ����:      2006.01.15
  ����:      IfileName: string
  ����ֵ:    ��
  ˵��:      �Զ����������ļ�������
-------------------------------------------------------------------------------}

procedure AssignCfgFile(IfileName: string);
begin
  if assigned(Gob_CFGer) then
    Gob_CFGer.Free;
  Gob_CFGer := TCFGer.Create(IfileName);
end;



constructor TCFGer.Create(ICfg: string);
begin
  if not FileExists(ICfg) then
    FileClose(FileCreate(ICfg));
  Opter := TMemIniFile.Create(ICfg);
end;

destructor TCFGer.Destroy;
begin
  Opter.UpdateFile;
  Opter.Free;
  inherited;
end;

function TCFGer.ReadBoolean(IName: string; IDefaultValue: Boolean = False):
  Boolean;
begin
  Result := opter.ReadBool(CurrSecton, IName, IDefaultValue);
end;

function TCFGer.ReadDateTime(IName: string; IDefaultValue: TDateTime):
  TDateTime;
begin
  Result := opter.ReadDateTime(CurrSecton, IName, IDefaultValue);
end;

function TCFGer.Readint(IName: string; IDefaultValue: integer = 0): Integer;
begin
  Result := opter.ReadInteger(CurrSecton, IName, IDefaultValue);
end;

function TCFGer.ReadString(IName: string; IDefaultValue: string = ''): string;
begin
  Result := opter.ReadString(CurrSecton, IName, IDefaultValue);
end;

procedure TCFGer.SetSecton(iSecton: string);
begin
  CurrSecton := iSecton;
end;

procedure TCFGer.WriteBoolean(IName: string; IValue: Boolean);
begin
  opter.WriteBool(CurrSecton, IName, IValue);
end;

procedure TCFGer.WriteDateTime(IName: string; IValue: TDateTime);
begin
  opter.WriteDateTime(CurrSecton, IName, IValue);
end;

procedure TCFGer.Writeint(IName: string; IValue: Integer);
begin
  opter.WriteInteger(CurrSecton, IName, IValue);
end;

procedure TCFGer.WriteString(IName: string; IValue: string);
begin
  opter.WriteString(CurrSecton, IName, IValue);
end;

initialization

finalization
  if assigned(Gob_CFGer) then
    Gob_CFGer.Free;

end.

