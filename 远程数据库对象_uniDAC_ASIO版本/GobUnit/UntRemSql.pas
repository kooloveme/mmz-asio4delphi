unit UntRemSql;

interface

uses
  Classes, SysUtils, Forms, Windows, DB,
  untRmoDbClient, Dbclient,midaslib;


type
  TRmoHelper = class


  public
    FPublic: TClientDataSet;
    FsqlBatchlst: TStrings;
    FLastSql: string; //���һ�β�ѯ�����
    FRmoClient: TRmoClient;

      {��ѯISqlStr��TClientDataSet�ؼ�}
    procedure MyQuery(IQry: TClientDataSet; ISqlStr: string);
    {ִ��ISqlStr���}
    procedure MyExec(ISqlStr: string);
    function GetCount(ItabName, IFieldName: string; Ivalue: variant):
      Cardinal;
    function OpenDataset(ISql: string; const Args: array of const): TClientDataSet; overload;
    function OpenDataset(ISql: string): TClientDataSet; overload;
    function OpenDataset(IQry: TClientDataSet; ISql: string): TClientDataSet;
      overload;
    function OpenDataset(IQry: TClientDataSet; ISql: string; const Args: array of
      const): TClientDataSet; overload;

    function ExecAnSql(IQry: TClientDataSet; Isql: string; const Args: array of
      const): Integer; overload;
    function ExecAnSql(Isql: string; const Args: array of const): Integer; overload;

    function OpenTable(ItabName: string; IQry: TClientDataSet): TClientDataSet;


   // function OpenTable(ItabName: string; Iado: TClientDataSet): TClientDataSet; overload;
    //function OpenTable(ItabName: string; IQueryRight: integer = 1): TClientDataSet; overload;
      {�������ݿ����� iTestTable�ǲ��Բ�ѯ�ı���������Ҫ��}
    function ConnetToSvr(ISvrIP: string; ISvrPort: Word): Boolean;
    //�������ӷ�����
    function ReConnSvr(ISvrIP: string; ISvrPort: Integer = -1; Iacc: string = '';
      iPsd: string = ''): boolean;
    //�����ύ���  ����ִ�������������б�
    function BathExecSqls(IsqlList: TStrings): Integer;
    //��������ύ��䵽�����б�
    function AddBathExecSql(Isql: string): boolean; overload;
    //��������ύ��� �ȴ�ִ��          BathExec
    function AddBathExecSql(Isql: string; const Args: array of const): boolean; overload;
    //������������ӵ���䷢�͵������ִ��
    function BathExec: Integer;


    constructor Create(Iport: integer = 9989);
    destructor Destroy; override;
  end;




var
  Gob_Rmo: TRmoHelper;

implementation

uses winsock, untFunctions;



function HostToIP(Name: string; var Ip: string): Boolean;
var
  wsdata: TWSAData;
  hostName: array[0..255] of char;
  hostEnt: PHostEnt;
  addr: PChar;
begin
  WSAStartup($0101, wsdata);
  try
    gethostname(hostName, sizeof(hostName));
    StrPCopy(hostName, Name);
    hostEnt := gethostbyname(hostName);
    if Assigned(hostEnt) then
      if Assigned(hostEnt^.h_addr_list) then begin
        addr := hostEnt^.h_addr_list^;
        if Assigned(addr) then begin
          IP := Format('%d.%d.%d.%d', [byte(addr[0]),
            byte(addr[1]), byte(addr[2]), byte(addr[3])]);
          Result := True;
        end
        else
          Result := False;
      end
      else
        Result := False
    else begin
      Result := False;
    end;
  finally
    WSACleanup;
  end
end;

procedure TRmoHelper.MyQuery(IQry: TClientDataSet; ISqlStr: string);
begin
  FRmoClient.OpenAndataSet(ISqlStr, IQry);
end;

procedure TRmoHelper.MyExec(ISqlStr: string);
begin
//  try
  FRmoClient.ExeSQl(ISqlStr);
//  except
//    on e: Exception do
//      Application.MessageBox(PChar('ROִ��SQL�쳣��' + e.message), '��ʾ', MB_OK +
//        MB_ICONINFORMATION);
//  end;
end;

constructor TRmoHelper.Create(Iport: integer = 9989);
begin
  FPublic := TClientDataSet.Create(nil);
  FRmoClient := TRmoClient.Create;
  FRmoClient.FHost := '127.0.0.1';
  FRmoClient.FPort := Iport;
  FsqlBatchlst := TStringList.Create;
end;

destructor TRmoHelper.Destroy;
begin
  FRmoClient.Free;
  FsqlBatchlst.Free;
  inherited;
end;



function TRmoHelper.OpenDataset(ISql: string;
  const Args: array of const): TClientDataSet;
begin
  ISql := Format(Isql, Args);
  MyQuery(FPublic, ISql);
  Result := FPublic;
end;


function TRmoHelper.OpenDataset(ISql: string): TClientDataSet;
begin
  MyQuery(FPublic, ISql);
  Result := FPublic;
end;

function TRmoHelper.OpenDataset(IQry: TClientDataSet; ISql: string):
  TClientDataSet;
begin
  MyQuery(IQry, ISql);
  Result := IQry;
end;

function TRmoHelper.OpenDataset(IQry: TClientDataSet; ISql: string; const Args:
  array of const): TClientDataSet;
begin
  ISql := Format(Isql, Args);
  MyQuery(IQry, ISql);
  Result := IQry;
end;

function TRmoHelper.GetCount(ItabName, IFieldName: string;
  Ivalue: variant): Cardinal;
var
  sql: string;
begin
  sql := 'select Count(' + IFieldName + ') as MyCount from ' + ItabName + ' where ' + IFieldName + ' = ' + Ivalue + '';
  MyQuery(FPublic, sql);
  Result := FPublic.fieldbyname('MyCount').AsInteger;
end;


function TRmoHelper.ExecAnSql(IQry: TClientDataSet; Isql: string; const Args:
  array of const): Integer;
begin
  MyExec(Format(Isql, Args));
end;

function TRmoHelper.ExecAnSql(Isql: string;
  const Args: array of const): Integer;
begin
  MyExec(Format(Isql, Args));
end;

function TRmoHelper.ConnetToSvr(ISvrIP: string; ISvrPort: Word): Boolean;
var
  LSql: string;
begin
  try
    if IsLegalIP(ISvrIP) = false then
      HostToIP(ISvrIP, ISvrIP);

    Result := FRmoClient.ConnToSvr(ISvrIP, ISvrPort);
  except
    Result := False;
  end;
end;

function TRmoHelper.OpenTable(ItabName: string; IQry: TClientDataSet):
  TClientDataSet;
begin
  MyQuery(IQry, Format('Select * from %s ', [ItabName]));
  Result := IQry;
end;

function TRmoHelper.ReConnSvr(ISvrIP: string; ISvrPort: Integer = -1;
  Iacc: string = ''; iPsd: string = ''): boolean;
begin
  if IsLegalIP(ISvrIP) = false then
    HostToIP(ISvrIP, ISvrIP);
  Result := FRmoClient.ReConn(ISvrIP, ISvrPort, Iacc, ipsd);
end;

function TRmoHelper.AddBathExecSql(Isql: string): boolean;
begin
  Result := true;
  if Isql <> '' then
    FsqlBatchlst.Add(Isql);
end;

function TRmoHelper.BathExecSqls(IsqlList: TStrings): Integer;
begin
  Result := FRmoClient.BathExecSqls(IsqlList);
end;

function TRmoHelper.AddBathExecSql(Isql: string;
  const Args: array of const): boolean;
begin
  Isql := format(Isql, Args);
  Result := AddBathExecSql(Isql);
end;

function TRmoHelper.BathExec: Integer;
begin
  if FsqlBatchlst.Count > 0 then begin
    Result := FRmoClient.BathExecSqls(FsqlBatchlst);
    FsqlBatchlst.Clear;
  end;
end;

initialization


finalization
  if Assigned(Gob_Rmo) then
    Gob_Rmo.Free;

end.

