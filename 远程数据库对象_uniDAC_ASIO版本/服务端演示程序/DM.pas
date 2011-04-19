unit DM;

//�ڴ˿������ݿ�����ѡ��
{$DEFINE  Access}
{.$DEFINE  InterBase}
{.$DEFINE  SqlServer}
{.$DEFINE  Sqlite}
{.$DEFINE  Oracle}
{.$DEFINE  MySql}
{.$DEFINE  Odbc}

interface
uses
  SysUtils, Classes, DB, MemDS, DBAccess, Uni, Provider, UniProvider
{$IFDEF Access}, AccessUniProvider{$ENDIF}
{$IFDEF InterBase}, InterBaseUniProvider{$ENDIF}
{$IFDEF SqlServer}, SQLServerUniProvider{$ENDIF}
{$IFDEF Sqlite}, SQLiteUniProvider{$ENDIF}
{$IFDEF Oracle}, OracleUniProvider, {$ENDIF}
{$IFDEF MySql}, MySQLUniProvider{$ENDIF}
{$IFDEF Odbc}, ODBCUniProvider{$ENDIF}
  ;

type
  TDataModel = class(TDataModule)
    DP: TDataSetProvider;
    dpProc: TDataSetProvider;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Coner: TUniConnection;
    Gqry: TUniQuery;
    UniSQL: TUniSQL;
    UniProc: TUniStoredProc;
  end;

var
  DataModel: TDataModel;

implementation

uses
  untFunctions;

{$R *.dfm}



procedure TDataModel.DataModuleCreate(Sender: TObject);
begin
  coner := TUniConnection.Create(self);
//------------------------------------------------------------------------------
// �ڴ˴����Ը�����Ҫ���Ӳ�ͬ�����ݿ��Լ����벻ͬ���Ӳ��� 2010-04-23 ������
//------------------------------------------------------------------------------
  with Coner do begin
//����Access
{$IFDEF Access}
    coner.ProviderName := 'Access';
    coner.Database := GetCurrPath() + 'demo.mdb';
{$ENDIF}
//����Interbase����Firebird
{$IFDEF InterBase}
    ProviderName := 'InterBase'; //ΪInterBase,֧��InterBase��FireBird
    UserName := 'SYSDBA'; //���ݿ�����
    Password := 'masterkey'; //���ݿ�����
    SpecificOptions.Clear;
{$IFDEF EMBED} //�����ļ���ʽ��
    Server := ''; //Ƕ��ʽΪ��
    DataBase := GetCurrPath() + 'demo.fdb';

{$ELSE} // ���ӷ�����ʽ��
    Server := '192.168.1.88';
    Port := 3050; //ȷ������������Firebird��3050�˿�
    Database := 'UniDemoDB'; //CS������ʹ�������ݿ����
    SpecificOptions.Add('InterBase.ClientLibrary=fbembed.dll'); //����embeddll��dll�ļ�λ��
{$ENDIF}
    SpecificOptions.Add('InterBase.CharLength=0'); //����Ϊ0���Զ���ȡFireBird����
    SpecificOptions.Add('SQLDialet=3'); //����Ϊ3
    SpecificOptions.Add('CharSet=GBK'); //����ΪGBK
    SpecificOptions.Add(Format('InterBase.ClientLibrary=%s', ['gds32.dll'])); //����fbclient.dllλ��
{$ENDIF}
//����SqlServer
{$IFDEF SqlServer}
    ProviderName := 'SQL Server'; //
    server := '127.0.0.1,7788';
    database := 'ubi100db';
    UserName := 'sa'; //���ݿ�����
    Password := 'admin'; //���ݿ�����
{$ENDIF}
//����Sqlite
{$IFDEF Sqlite}
    ProviderName := 'SQLite'; //
    database := GetCurrPath() + 'test.db';
{$ENDIF}
//����Oracle
{$IFDEF Oracle}
    ProviderName := 'Oracle'; //
    server := '192.168.0.36,7788';
    database := 'test';
    UserName := 'sa'; //���ݿ�����
    Password := 'sa'; //���ݿ�����
{$ENDIF}
//����MySql
{$IFDEF MySql}
    ProviderName := 'MySQL'; //
    server := '192.168.0.36,7788';
    database := 'test';
    UserName := 'root'; //���ݿ�����
    Password := '123'; //���ݿ�����
{$ENDIF}
//����Odbc
{$IFDEF Odbc}

{$ENDIF}
  end;
  coner.Connect;
  Gqry := TUniQuery.Create(Self);
  Gqry.Connection := coner;
  UniSQL := TUniSQL.Create(Self);
  UniSQL.Connection := coner;
  UniProc := TUniStoredProc.Create(self);
  UniProc.Connection := Coner;
  DP.DataSet := Gqry;
  dpProc.DataSet := UniProc;
end;

end.

