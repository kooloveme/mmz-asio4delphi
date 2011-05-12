{*******************************************************
        ��Ԫ���ƣ�untRmoDbClient.pas
        �������ڣ�2008-09-16 17:25:52
        ������	  ������
        ����:     Զ�����ݿ�ͻ���
        ��ǰ�汾�� v2.0

��ʷ�ͼƻ�
v1.0  ��Ԫʵ��
v1.1  �����֧���������ֶε�����
v1.2  ���id�ű����ǵ�1���ֶε�����
v1.3  Ϊ�����ٶȣ������岻��ÿ���������
v1.4  ��sabason �ֵ����İ����£���������Դ�����ڵ����⣬�������˴���Ч�� 20100413
v2.0  ado�汾����asio����˵�֧�֣���Ч�ʸ߲���

*******************************************************}


unit untRmoDbClient;

interface

uses
  Classes, UntsocketDxBaseClient, Controls, ExtCtrls, db, adodb;

type
  TConnthread = class;
  TSelectitems = class
  public
    Sql: string;
  end;
  TRmoClient = class(TSocketClient)
  private
    FsqlLst: TStrings; //������¼�Ѿ����˵����ݼ� �Լ����ڵ����
    FSqlPart1, FSqlPart2: string;

    Fsn: Cardinal;
    FQryForID: TADOQuery;
    FIsDisConn: boolean; //�Ƿ����Լ��ֶ��Ͽ����ӵ�
    Ftimer: TTimer; //���ӱ�����
    FisConning: Boolean; //�Ƿ����ӳɹ�
    //��ʱ����Ƿ���Ҫ���� �������ӶϿ�
    procedure OnCheck(Sender: TObject);
     //����Ƿ����Ӵ��
    procedure checkLive;

    procedure OnBeginPost(DataSet: TDataSet);
    procedure OnBeforeDelete(DataSet: TDataSet);
  public

    IsInserIDfield: boolean; //�Ƿ������� ֧��ID�ֶ� �����������������ֶ�Ĭ����false

    //���ӷ����
    function ConnToSvr(ISvrIP: string; ISvrPort: Integer = 9988): boolean;
    //�Ͽ�����
    procedure DisConn;
    //���������µ�IP
    function ReConn(ISvrIP: string; IPort: Integer = -1): boolean;

    //��postģʽ���Ϊ ������䵽Զ��ִ��
    procedure ReadySqls(IAdoquery: TADOQuery);

    //ִ��һ�����
    function ExeSQl(ISql: ansistring): Integer;
    //��һ�������ݼ�
    function OpenAndataSet(ISql: ansistring; IADoquery: TADOQuery): Boolean;

    procedure OnCreate; override;
    procedure OnDestory; override;
  end;


  TConnthread = class(TThread)
  public
    Client: TRmoClient;
    procedure execute; override;
  end;

var
  //Զ�����ӿ��ƶ���
  Gob_RmoCtler: TRmoClient;

implementation

uses untfunctions, sysUtils, UntBaseProctol, IniFiles, ADOInt, Variants,
  untASIOSvr;


procedure TRmoClient.checkLive;
begin
  try
    if IsConning then begin
      SendAsioHead(4);
      if WriteInteger(4) <> 4 then begin
        if FIsDisConn = False then
          FisConning := False;
      end;
    end
    else begin
      if FIsDisConn = False then
        FisConning := False;
    end;

  except
    if FIsDisConn = False then
      FisConning := False;
  end;
end;

function TRmoClient.ConnToSvr(ISvrIP: string;
  ISvrPort: Integer): boolean;
begin
  Result := True;
  if (IsConnected = false) or (FHost <> ISvrIP) or (FPort <> ISvrPort) then begin
    if IsConnected then
      DisConn;
    FHost := ISvrIP;
    FPort := ISvrPort;
    FIsDisConn := False;
    try
      Result := Connto(FHost, FPort);
    except
      Result := False;
      FIsDisConn := False;
    end;
    if Result = True then begin
      SendHead(CTSLogin);
      WriteInteger(CClientID);
      if ReadInteger <> STCLogined then begin
        Result := False;
        FisConning := False;
        DisConn;
        Exit;
      end;
      FisConning := True;
      FIsDisConn := False;
      Ftimer.Enabled := True;
    end;
  end;
end;

procedure TRmoClient.DisConn;
begin
  try
    if IsConnected then
      DisConn;
  except
  end;
  FIsDisConn := True;
end;

{ TConnthread }

procedure TConnthread.execute;
begin
  try
    if Client.ConnToSvr(Client.FHost, Client.FPort) then begin
      Client.FisConning := True;
    end;
  finally
    Client.Ftimer.Tag := 0;
  end;
end;

function TRmoClient.ExeSQl(ISql: ansistring): Integer;
var
  llen, i: Integer;
begin
  llen := length(ISql);
  SendAsioHead(8 + llen);
  WriteInteger(1);
  WriteInteger(llen);
  Write(ISql);
  llen := ReadInteger();
  if llen = -1 then begin
    llen := ReadInteger();
    ISql := ReadStr(llen);
    raise Exception.Create(ISql);
  end
  else begin
    Result := llen;
  end;
end;


//------------------------------------------------------------------------------
// ����postʱ�Զ����·���� 2009-05-22 ������
// Ҫ��������id�Ŷ��ұ����ǵ�һ���ֶ�
//------------------------------------------------------------------------------


var
  lglst: Tstrings;

procedure TRmoClient.OnBeforeDelete(DataSet: TDataSet);
var
  I: Integer;
  lsql: string;
  Result, ltablename: string;
  Lkey, lvalue: string;
  Lindex: integer;
begin

  //��ȡ����
  i := FsqlLst.IndexOf(IntToStr(integer(DataSet)));
  if i > -1 then
    lsql := LowerCase(TSelectitems(FsqlLst.Objects[i]).Sql); //  LowerCase(DataSet.Filter);
  if Pos('select', lsql) > 0 then begin
    if lglst = nil then
      lglst := TStringList.Create;
    GetEveryWord(lsql, lglst, ' ');
    for i := 0 to lglst.Count - 1 do
      if lglst.Strings[i] = 'from' then begin
        Lindex := i;
        Break;
      end;
    if Lindex < 2 then
      ExceptTip('SQL������');
    ltablename := '';
    for i := Lindex + 1 to lglst.Count - 1 do
      if lglst.Strings[i] <> '' then begin
        ltablename := lglst.Strings[i];
        Break;
      end;
    if ltablename = '' then
      ExceptTip('SQL������');
  end
  else
    ExceptTip('�޷��Զ��ύ������ִ��select');
  //��ȡ����
  with DataSet.Fields do begin
    Result := 'delete from ' + ltablename + Format(' where %s=%d', [Fields[0].FieldName, Fields[0].AsInteger]);
    ExeSQl(Result);
  end;
end;


procedure TRmoClient.OnBeginPost(DataSet: TDataSet);
var
  I, n: Integer;
  lsql, lBobName: string;
  Result, FtableName: string;
  Lkey, lvalue: string;
  Lindex: integer;
  LblobStream: TStream;
begin
  //��ȡ����
  i := FsqlLst.IndexOf(IntToStr(integer(DataSet)));
  if i > -1 then
    lsql := LowerCase(TSelectitems(FsqlLst.Objects[i]).Sql); //  LowerCase(DataSet.Filter);
  if Pos('select', lsql) > 0 then begin
    if lglst = nil then
      lglst := TStringList.Create;
    GetEveryWord(lsql, lglst, ' ');
    for i := 0 to lglst.Count - 1 do
      if lglst.Strings[i] = 'from' then begin
        Lindex := i;
        Break;
      end;
    if Lindex < 2 then
      ExceptTip('SQL������');
    FtableName := '';
    for i := Lindex + 1 to lglst.Count - 1 do
      if lglst.Strings[i] <> '' then begin
        FtableName := lglst.Strings[i];
        Break;
      end;
    if FtableName = '' then
      ExceptTip('SQL������');
  end
  else
    ExceptTip('�޷��Զ��ύ������ִ��select');

  //��ȡ����
  case TADOQuery(DataSet).State of //
    dsinsert: begin
        with DataSet.Fields do begin
        //�����һ���ֶ�Ϊֻ����˵����������ID�ֶ� �ĵ���
          if Fields[0].ReadOnly = true then begin
            IsInserIDfield := True;
            Fields[0].ReadOnly := False;
          end;
          if DataSet.State = dsInsert then begin
  //�����ҪID�ֶ� �Զ���ȡ
            if FQryForID = nil then
              FQryForID := TADOQuery.Create(nil);
            OpenAndataSet(Format('select max(%s) as myid from %s', [DataSet.Fields[0].FieldName, FtableName]), FQryForID);
            DataSet.Fields[0].AsInteger := FQryForID.FieldByName('myid').AsInteger + 1;
          end;
//          if IsInserIDfield then begin
//            n := 1;
//          end
//          else
          n := 0;
          FSqlPart1 := 'insert into ' + FtableName + '(';
          FSqlPart2 := '';
          for i := n to count - 1 do begin
            //�����blob�ֶ�������
            if Fields[i].DataType in [ftBlob] then begin
              LblobStream := TMemoryStream.Create;
              TBlobField(Fields[i]).SaveToStream(LblobStream);
              EnCompressStream(TMemoryStream(LblobStream));
              lBobName := Fields[i].FieldName;
//------------------------------------------------------------------------------
// ��������һ���ֶ�������֮ǰȥ���ϴ����ɵģ���  2010-04-21 ������
//------------------------------------------------------------------------------
              if i = count - 1 then begin
                if FSqlPart1[length(FSqlPart1) - 1] = ',' then begin
                  FSqlPart1 := copy(FSqlPart1, 1, length(FSqlPart1) - 1);
                  FSqlPart2 := copy(FSqlPart2, 1, length(FSqlPart2) - 1);
                end;
              end;
              Continue;
            end;

            FSqlPart1 := FSqlPart1 + ifthen(i = n, '', ',') + Fields[i].FieldName;
            case Fields[i].DataType of
              ftCurrency, ftBCD, ftWord, ftFloat, ftBytes: FSqlPart2 := FSqlPart2 + ifthen(i = n, '', ',') + ifthen(Fields[i].AsString = '', '0', Fields[i].AsString);
              ftBoolean, ftSmallint, ftInteger: FSqlPart2 := FSqlPart2 + ifthen(i = n, '', ',') + IntToStr(Fields[i].AsInteger);
            else
              FSqlPart2 := FSqlPart2 + ifthen(i = n, '', ',') + '''' + Fields[i].AsString + '''';
            end;
          end;
          Result := FSqlPart1 + ') values (' + FSqlPart2 + ')';
        end;
      end;
    dsEdit: begin
        with DataSet.Fields do begin
          Result := 'Update ' + FtableName + ' Set ';
          for I := 0 to count - 1 do begin // Iterate
            if I = 0 then begin
              Lkey := Fields[i].FieldName;
              lvalue := Fields[i].AsString;
              Continue;
            end;
             //�����blob�ֶ�������
            if Fields[i].DataType in [ftBlob] then begin
              LblobStream := TMemoryStream.Create;
              TBlobField(Fields[i]).SaveToStream(LblobStream);
              EnCompressStream(TMemoryStream(LblobStream));
              lBobName := Fields[i].FieldName;
//------------------------------------------------------------------------------
// ��������һ���ֶ�������֮ǰȥ���ϴ����ɵģ���  2010-04-21 ������
//------------------------------------------------------------------------------
              if i = count - 1 then begin
                Result := copy(Result, 1, length(Result) - 1);
              end;
              Continue;
            end;

            Result := Result + Fields[i].FieldName + '=';
            case Fields[i].DataType of //
              ftCurrency, ftBCD, ftWord: Result := Result + Fields[i].AsString;
              ftFloat: Result := Result + Fields[i].AsString;
              ftBytes, ftSmallint, ftInteger: Result := Result + IntToStr(Fields[i].AsInteger);
            else
              Result := Result + '''' + Fields[i].AsString + '''';
            end; // case
            if i <> Count - 1 then
              Result := Result + ',';
          end; // for
          Result := Result + Format(' where %s=%s', [Lkey, lvalue]);
        end; // with
      end;
  end; // case
  ExeSQl(Result);

  //�����blob�ֶ��� ׷��д��
  if LblobStream <> nil then begin
    lsql := format('update %s set %s=:%s where %s=%d', [FtableName, lBobName, 'Pbob'
      , DataSet.Fields[0].FieldName, DataSet.Fields[0].AsInteger]);
    SendAsioHead(8 + length(lsql) + 4 + LblobStream.Size);
    WriteInteger(6);
    WriteInteger(length(lsql));
    Write(lsql);
    WriteStream(LblobStream);
    LblobStream.Free;
  end;
end;


procedure TRmoClient.OnCheck(Sender: TObject);
begin
  if TTimer(sender).tag = 0 then begin
    if ((IsConnected = false) or (FisConning = false)) and (FIsDisConn = false) then begin
      TTimer(sender).tag := 1;
      with TConnthread.Create(True) do begin
        FreeOnTerminate := True;
        Client := Self;
        Resume;
      end;
    end
    else begin
      checkLive;
    end;
  end;
end;

procedure TRmoClient.OnCreate;
begin
  inherited;
  Ftimer := TTimer.Create(nil);
  Ftimer.OnTimer := OnCheck;
  Ftimer.Interval := 3000;
  Ftimer.Enabled := False;
  Ftimer.Tag := 0;
  FisConning := false;
  FIsDisConn := False;
  FsqlLst := THashedStringList.Create;
end;

procedure TRmoClient.OnDestory;
begin
  inherited;
  if FQryForID <> nil then
    FQryForID.Free;
  Ftimer.Free;
  FsqlLst.Free;
end;



type
  TinnerADOQuery = class(TADOQuery)
  public
    function LoadFromStream(Stream: TStream): Boolean;
  end;

function TinnerADOQuery.LoadFromStream(Stream: TStream): Boolean;
var
  mRecordSet: _Recordset;
begin
  Result := False;
  Close;
  DestroyFields;
  mRecordSet := CoRecordset.Create;
  try
    if mRecordSet.State = adStateOpen then
      mRecordset.Close;
    Stream.Position := 0;
    mRecordset.Open(TStreamAdapter.Create(Stream) as IUnknown, EmptyParam, adOpenStatic, adLockBatchOptimistic, adAsyncExecute);
    Stream.Position := 0;
    if not mRecordSet.BOF then
      mRecordset.MoveFirst;
    RecordSet := mRecordSet;
    inherited OpenCursor(False);
    Resync([]);
    Result := True;
  except
        //
  end;
end;

var
  GInnerQry: TinnerADOQuery;
  gLmemStream: TMemoryStream;

function DatasetFromStream(Idataset: TADOQuery; Stream:
  TMemoryStream): boolean;
var
  RS: Variant;
begin
  Result := false;
  if Stream.Size < 1 then
    Exit;
  if GInnerQry = nil then
    GInnerQry := TinnerADOQuery.Create(nil);
  try
    GInnerQry.LoadFromStream(Stream);
    Idataset.Clone(GInnerQry);
    Result := true;
  finally;
  end;
end;

function TRmoClient.OpenAndataSet(ISql: ansistring;
  IADoquery: TADOQuery): Boolean;
var
  llen, i: Integer;
  ls: string;
  Lend: integer;
  Litem: TSelectitems;
begin
  inc(Fsn);
  Lend := 0;
  ls := ISql;
  llen := Length(ISql);
  SendAsioHead(8 + llen);
  WriteInteger(22);
  WriteInteger(llen);
  Write(ISql);
  llen := ReadInteger();
  if llen = -1 then begin
    llen := ReadInteger();
    ISql := ReadStr(llen);
    raise Exception.Create(ISql);
  end
  else begin
    //��¼�� �Ƿ�����Զ�����
    i := FsqlLst.IndexOf(IntToStr(integer(IADoquery)));
    if i = -1 then begin
      Litem := TSelectitems.Create;
      FsqlLst.AddObject(IntToStr(integer(IADoquery)), Litem);
    end
    else
      Litem := TSelectitems(FsqlLst.Objects[i]);
    Litem.Sql := ISql;
     //��¼һ��
    ReadySqls(IADoquery);
    if llen = 1 then begin
      if gLmemStream = nil then
        gLmemStream := TMemoryStream.Create;
      GetZipStream(gLmemStream, self);
      DatasetFromStream(IADoquery, gLmemStream);
    end
    else begin
      ISql := GetCurrPath + GetDocDate + GetDocTime + IntToStr(Fsn);
      GetZipFile(ISql);
      IADoquery.LoadFromFile(ISql);
      DeleteFile(ISql);
    end;
    Result := True;
  end;
end;

procedure TRmoClient.ReadySqls(IAdoquery: TADOQuery);
begin
  IAdoquery.BeforePost := OnBeginPost;
  IAdoquery.BeforeDelete := OnBeforeDelete;
end;

function TRmoClient.ReConn(ISvrIP: string; IPort: Integer): boolean;
begin
  Result := False;
  if IsLegalIP(ISvrIP) then begin
    Result := ConnToSvr(ISvrIP, IfThen(IPort = -1, FPort, IPort));
  end;
end;

end.

