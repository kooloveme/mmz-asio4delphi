{*******************************************************
        ��Ԫ���ƣ�untRmoDbClient.pas
        �������ڣ�2008-09-16 17:25:52
        ������	  ������
        ����:     Զ�����ݿ�ͻ���
        ��ǰ�汾�� v2.0.2

������ʷ
v1.0  ��Ԫʵ��
v1.1  �����֧���������ֶε�����
v1.2  ���id�ű����ǵ�1���ֶε�����
v1.3  Ϊ�����ٶȣ������岻��ÿ��������� ���ı��Զ�����ʱ����filter�������õķ�ʽ
v1.4  ��sabason �ֵ����İ����£���������Դ�����ڵ����⣬�������˴���Ч�� 20100413
v1.5  ȫ���޸�Ϊ֧�ָ�Ч�ʵ�UniDAC���ݿ������׼� ��ClientDataset (ԭ����ADO��ʽ)֧�������������ݿ⣬�����ߴ���Ч�ʣ���ʹ�÷���û�иı�
v1.6  �����������ڵ�BUG  ���������һ���ֶ�Ϊblob�ֶε���������ɴ����BUG
v1.7  ���ӷ����sys.ini�ļ����ÿͻ��˵�½Ȩ�ޣ���������ִ��SQL���ӿ�
v1.8  ���ӷ�����ṩ�Զ��������ܣ�������������ļ�����Ŀ¼����ѡ��ǿ���������߿ͻ��˿�ѡ����
v2.0  ����asio������ C++ ��ɶ˿��ȶ���ķ�װ֧��
v2.1  ���Ӵ洢���̵��õ�֧�֣��ο���ˮ������޸İ汾���ڴ˱�ʾ��л��
v2.0.2 2011-04-20
                  ͳһ�ͷ���˵İ汾�� ����v2.1�޸�Ϊv2.0.2
                  ����MAX()��ʽ��ȡ���ݼ�¼�����ݱ��ڴ��ڴ�����¼ʱ����������ҿ��ܵ���ID��ͻ��
                  �����أ����ӿ��ٻ�ȡ������ID�ķ�ʽ���ͻ��˿������Ƿ�ʹ�����ַ�ʽ
*******************************************************}


unit untRmoDbClient;

interface

uses
  Classes, UntsocketDxBaseClient, IdComponent, Controls, ExtCtrls, db, dbclient, midaslib;

type
  TConnthread = class;
  TSelectitems = class
  public
    Sql: string;
  end;
  TRmoClient = class(TSocketClient)
  private
    gLmemStream: TMemoryStream;
    FCachSQllst, FsqlLst: TStrings; //������¼�Ѿ����˵����ݼ� �Լ����ڵ����
    FSqlPart1, FSqlPart2: string;

    Fsn: Cardinal;
    FQryForID: TClientDataSet;
    FIsDisConn: boolean; //�Ƿ����Լ��ֶ��Ͽ����ӵ�
    Ftimer: TTimer; //���ӱ�����
    FisConning: Boolean; //�Ƿ����ӳɹ�
    //��ʱ����Ƿ���Ҫ���� �������ӶϿ�
    procedure OnCheck(Sender: TObject);
     //����Ƿ����Ӵ��
    procedure checkLive;

    procedure OnBeginPost(DataSet: TDataSet);
    procedure OnBeforeDelete(DataSet: TDataSet);
    function GetSvrmaxID(Iidname, itablename: string): integer;
  public
    IsSpeedGetID: Boolean; //�Ƿ�ʹ�ø��ٷ�ʽ��ȡ������ID
    IsInserIDfield: boolean; //�Ƿ������� ֧��ID�ֶ� �����������������ֶ�Ĭ����false
    FLastInsertID: Integer; //insert���ʱ���ز����¼�������ֶε�ֵ

    //���ӷ����
    function ConnToSvr(ISvrIP: ansistring; ISvrPort: Integer = 9988; Iacc: ansistring = '';
      iPsd: ansistring = ''): boolean;
    //�Ͽ�����
    procedure DisConn;
    //���������µ�IP
    function ReConn(ISvrIP: ansistring; IPort: Integer = -1; Iacc: ansistring = '';
      iPsd: ansistring = ''): boolean;

    //��postģʽ���Ϊ ������䵽Զ��ִ��
    procedure ReadySqls(IAdoquery: TClientDataSet);

    //ִ��һ�����
    function ExeSQl(ISql: ansistring): Integer;
    //��һ�������ݼ�
    function OpenAndataSet(ISql: ansistring; IADoquery: TClientDataSet): Boolean;
    //�����ύ���  ����ִ�������������б�
    function BathExecSqls(IsqlList: TStrings): Integer;
    //ִ��һ���洢����
    //���� ִ�����  �Ƿ���Ҫ�������ݼ�
    function ExecProc(iSQL: ansistring; IsBackData: boolean; cds: TClientDataSet =
      nil): Boolean;

    //�������
    procedure CheckUpdate;

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
  GCurrVer: integer = 1; //��ǰ���������汾��

implementation

uses untfunctions, sysUtils, UntBaseProctol, IniFiles, ADOInt, Variants,
  Windows, untASIOSvr;


function TRmoClient.BathExecSqls(IsqlList: TStrings): Integer;
var
  IErr: ansistring;
  llen, i: Integer;
  ls: TMemoryStream;
begin
  //����ִ��SQL���
  ls := TMemoryStream.Create;
  IsqlList.SaveToStream(ls);
  EnCompressStream(ls);
  llen := 4 + 4 + ls.Size;
  SendAsioHead(llen);
  WriteInteger(110);
  SendZIpStream(ls, Self, true);
  llen := ReadInteger();
  if llen = -1 then begin
    llen := ReadInteger();
    IErr := ReadStr(llen);
//    IsqlList.SaveToFile('D:\2.txt');
    raise Exception.Create(IErr);
  end
  else begin
    Result := llen;
  end;
end;

procedure TRmoClient.checkLive;
begin
  try
    if IsConnected then begin
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

procedure TRmoClient.CheckUpdate;
var
  i, lstrlrn, illen: Integer;
  li, lr, lm: integer;
  ls, lspath, lflst: ansistring;
  lspit: TStringList;
begin
  SendAsioHead(4);
  WriteInteger(9998);
  lr := ReadInteger;
  if lr > 0 then begin
    lspit := TStringList.Create;
    lr := ReadInteger; //ver
    lm := ReadInteger;
    lstrlrn := Readinteger;
    lspath := ReadStr(lstrlrn);
    lstrlrn := Readinteger;
    ls := ReadStr(lstrlrn);
    li := ReadInteger;
    lflst := ReadStr(li);
    if lr > GCurrVer then begin
      lspit.Add(IntToStr(lm));
      lspit.Add(ls);
      //��̨��������
      GetEveryWord(lflst, '|');
      lspit.Add(IntToStr(GlGetEveryWord.Count));

      for i := 0 to GlGetEveryWord.Count - 1 do begin // Iterate
        ls := GlGetEveryWord[i];
        illen := Length(ls);
        SendAsioHead(8 + illen);
        SendHead(9997);
        Writeinteger(illen);
        Write(ls);
        li := ReadInteger;
        if li = 1 then begin
          ls := StringReplace(GlGetEveryWord[i], lspath, '', []);
          ls := GetCurrPath + ls;
          ForceDirectories(ExtractFilePath(ls));
          GetZipFile(ls);
          lspit.Add(ls);
        end;
      end; // for
      lspit.SaveToFile('up.cfg');
      lspit.Free;
      WinExec(pansichar('up.exe  ' + ExtractFileName(ParamStr(0))), SW_SHOW);
    end;
  end;
end;

function TRmoClient.ConnToSvr(ISvrIP: ansistring; ISvrPort: Integer = 9988;
  Iacc: ansistring = ''; iPsd: ansistring = ''): boolean;
var
  i: Integer;
  ls: ansistring;
begin
  Result := True;
  if (IsConnected = false) or (FHost <> ISvrIP) or (FPort <> ISvrPort) then begin
    if IsConnected then
      DisConn;
    FHost := ISvrIP;
    FPort := ISvrPort;
    Facc := Iacc;
    Fpsd := iPsd;
    FIsDisConn := False;
    try
      Result := Connto(FHost, FPort);
    except
      Result := False;
      FIsDisConn := False;
    end;
    if Result = True then begin
//        SendHead(CTSLogin);
//        WriteInteger(CClientID);
//        if ReadInteger <> STCLogined then
//          Result := False;
      ls := format('%s|%s', [Iacc, Str_Encry(iPsd, 'rmo')]);
      Writeinteger(Length(ls));
      Write(ls);
      if ReadInteger <> STCLogined then begin
        Result := False;
        DisConn;
        FisConning := false;
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
    CloseConn;
//    if IsConnected then
//      DisConn;
  except
  end;
  FIsDisConn := True;
end;

{ TConnthread }

procedure TConnthread.execute;
begin
  try
    if Client.ConnToSvr(Client.FHost, Client.FPort, Client.Facc, Client.Fpsd) then begin
      Client.FisConning := True;
    end;
  finally
    Client.Ftimer.Tag := 0;
  end;
end;


function StreamToVarArray(const S: TStream): Variant;
var P: Pointer;
  C: Integer;
  L: Integer;
begin
  S.Position := 0;
  C := S.Size;
  Result := VarArrayCreate([1, C], varByte);
  L := Length(Result);
  if L <> 0 then
    ;
  P := VarArrayLock(Result);
  try
    S.Read(P^, C);
  finally
    VarArrayUnlock(Result);
  end;
end;

procedure VarArrayToStream(const V: Variant; S: TStream);
var P: Pointer;
  C: Integer;
begin
  if not VarIsArray(V) then
    raise Exception.Create('Var is not array');
  if VarType(V[1]) <> varByte then
    raise Exception.Create('Var array is not blob array');
  C := VarArrayHighBound(V, 1) - VarArrayLowBound(V, 1) + 1;
  if not (C > 0) then
    Exit;

  P := VarArrayLock(V);
  try
    S.Write(P^, C * SizeOf(Byte));
    S.Position := 0;
  finally
    VarArrayUnLock(V);
  end;
end;

function DatasetFromStream(Idataset: TClientDataSet; Stream:
  TMemoryStream): boolean;
var
  RS: Variant;
begin
  Result := false;
  if Stream.Size < 1 then
    Exit;
  try
    Idataset.Data := StreamToVarArray(Stream);
    Result := true;
  finally;
  end;

end;

function TRmoClient.ExecProc(iSQL: ansistring; IsBackData: boolean; cds:
  TClientDataSet = nil): Boolean;
var
  nReturn, i: Integer;
  sErr: ansistring;
  stmp: ansistring;
begin
  //��firebird��
  //ִ�д洢����
  //sql = 'Execute procedure ' + ProcName + '(' + Format(ParamsValues, args) + ')';
  //ִ�з������ݼ��Ĵ洢����
  //sql = 'select * from ' + ProcName + '(' + Format(ParamsValues, args) + ')';
  Result := True;
  FLastInsertID := -1;
  if not IsBackData then begin //ִ�д洢����
    SendAsioHead(4 + 4 + length(iSQL));
    WriteInteger(1010);
    WriteInteger(Length(iSQL));
    Write(iSQL);
    nReturn := ReadInteger();
    if nReturn = -1 then begin
      nReturn := ReadInteger();
      sErr := ReadStr(nReturn);
      Result := False;
      raise Exception.Create(Format('����: %s', [sErr]));
    end else begin
      //{ TODO -owshx -c :  2010-11-10 ���� 02:26:32 }
      //stmp := ReadStr(ReadInteger());   //����output����ֵ
    end;
  end else begin //�з������ݼ�
    SendAsioHead(4 + 4 + length(iSQL));
    WriteInteger(1011); //�Ӵ洢���̷������ݼ�
    WriteInteger(Length(iSQL));
    Write(iSQL);
    nReturn := ReadInteger();
    if nReturn = -1 then begin
      nReturn := ReadInteger();
      sErr := ReadStr(nReturn);
      raise Exception.Create(Format('ִ�����<%s>ʱ��������', [sErr]));
    end else begin
      if glmemStream = nil then
        glmemStream := TMemoryStream.Create
      else
        glmemStream.clear;
      GetZipStream(glmemStream, self);
      if Assigned(cds) then
        DatasetFromStream(cds, glmemStream)
      else begin
        raise Exception.Create('���ص����ݼ�û��ָ�����塣');
        Result := False;
      end;
    end;
  end;

end;

function TRmoClient.ExeSQl(ISql: ansistring): Integer;
var
  llen, i: Integer;
begin
  llen := Length(ISql);
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

function TRmoClient.GetSvrmaxID(Iidname, itablename: string): integer;
var
  llen, i: Integer;
  ISql: string;
begin
  if IsSpeedGetID then begin
    ISql := Format('%s|%s', [Iidname, itablename]);
    llen := Length(ISql);
    SendAsioHead(8 + llen);
    WriteInteger(7);
    WriteInteger(llen);
    Write(ISql);
    llen := ReadInteger();
    Result := ReadInteger;
    if llen = -1 then begin
      llen := ReadInteger();
      ISql := ReadStr(llen);
      raise Exception.Create(ISql);
    end;
  end
  else begin
                  //�����ҪID�ֶ� �Զ���ȡ
    if FQryForID = nil then
      FQryForID := TClientDataSet.Create(nil);
//    ��ȡID
    OpenAndataSet(Format('select max(%s) as myid from %s', [Iidname, itablename]), FQryForID);
//
    Result := FQryForID.FieldByName('myid').AsInteger + 1;
  end;
end;


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
  case TClientDataSet(DataSet).State of //
    dsinsert: begin
        with DataSet.Fields do begin
        //�����һ���ֶ�Ϊֻ����˵����������ID�ֶ� �ĵ���
          if Fields[0].ReadOnly = true then begin
            IsInserIDfield := True;
            Fields[0].ReadOnly := False;
          end;
          if DataSet.State = dsInsert then begin
//------------------------------------------------------------------------------
// ����Ϊͨ������˻�ȡID  2011-4-20 10:46:02   ������
//------------------------------------------------------------------------------
            DataSet.Fields[0].AsInteger := GetSvrmaxID(DataSet.Fields[0].FieldName, FtableName);
          end;
          if IsInserIDfield then begin
            n := 0;
          end
          else
            n := 1;
          FSqlPart1 := 'insert into ' + FtableName + '(';
          FSqlPart2 := '';
          for i := n to count - 1 do begin
            if (fields[i].IsNull) or (trim(fields[i].AsString) = '') then
              continue;
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
              ftDate, ftDateTime: if Fields[i].AsString = '' then FSqlPart2 := FSqlPart2 + ifthen(i = n, '', ',') + 'null' else
                  FSqlPart2 := FSqlPart2 + ifthen(i = n, '', ',') + '''' + Fields[i].AsString + '''' // Modified by qnaqbgss 2010/9/11 17:56:49
              else FSqlPart2 := FSqlPart2 + ifthen(i = n, '', ',') + '''' + Fields[i].AsString + '''';
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
//            if (fields[i].IsNull) or (trim(fields[i].AsString) = '') then
//              continue;
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
              ftBoolean:Result := Result +Booltostr(fields[i].AsBoolean,true);
              ftDate, ftDateTime: if Fields[i].AsString = '' then result := Result + 'null' else
                  result := Result + '''' + Fields[i].AsString + '''' // Modified by qnaqbgss 2010/9/11 17:57:14
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
  IsSpeedGetID := True;
  FCachSQllst := THashedStringList.Create;
  Ftimer := TTimer.Create(nil);
  Ftimer.OnTimer := OnCheck;
  Ftimer.Interval := 3000;
  Ftimer.Enabled := False;
  Ftimer.Tag := 0;
  FisConning := false;
  FIsDisConn := False;
  FsqlLst := THashedStringList.Create;
  gLmemStream := TMemoryStream.Create;
end;

procedure TRmoClient.OnDestory;
begin
  inherited;
  FCachSQllst.Free;
  if FQryForID <> nil then
    FQryForID.Free;
  Ftimer.Free;
  FsqlLst.Free;
  gLmemStream.Free;
end;

function TRmoClient.OpenAndataSet(ISql: ansistring;
  IADoquery: TClientDataSet): Boolean;
var
  llen, i: Integer;
  ls: ansistring;
  Lend: integer;
  Litem: TSelectitems;
begin
  inc(Fsn);
  Lend := 0;
  ls := ISql;
  llen := length(isql);
  SendAsioHead(8 + llen);
  WriteInteger(2);
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
      DeleteFile(pchar(ISql));
    end;
    Result := True;
  end;
end;

procedure TRmoClient.ReadySqls(IAdoquery: TClientDataSet);
begin
  IAdoquery.BeforePost := OnBeginPost;
  IAdoquery.BeforeDelete := OnBeforeDelete;
end;

function TRmoClient.ReConn(ISvrIP: ansistring; IPort: Integer = -1; Iacc: ansistring = '';
  iPsd: ansistring = ''): boolean;
begin
  Result := False;
  if IsLegalIP(ISvrIP) then begin
    Result := ConnToSvr(ISvrIP, IfThen(IPort = -1, FPort, IPort), iacc, ipsd);
  end;
end;

end.

