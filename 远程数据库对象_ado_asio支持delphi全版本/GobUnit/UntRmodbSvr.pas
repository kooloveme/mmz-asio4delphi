{*******************************************************
        ��Ԫ���ƣ�UntRmodbSvr.pas
        �������ڣ�2008-09-16 17:26:15
        ������	  ������
        ����:     Զ�����ݿ�����

*******************************************************}

unit UntRmodbSvr;


interface

uses Classes, UntSocketServer, UntTBaseSocketServer, untFunctions, syncobjs, Windows, Forms,
  adodb, untASIOSvr;


type
  TRmodbSvr = class(TCenterServer)
  private
    Flock: TCriticalSection;
    function ReadStream(Istream: TStream; ClientThread: TAsioClient): TMemoryStream;
  public
    Gqry: TADOQuery;
    Db: TDBMrg;
    GGDBPath: string;
    //���ӵ����ݿ�
    function ConnToDb(IConnStr: string): boolean;
    function OnDataCase(ClientThread: TAsioClient; Ihead: integer): Boolean;
      override;
    procedure OnCreate(ISocket: TBaseSocketServer); override;
    procedure OnDestroy; override;
    function GetCurrDBPath(InPath: string): string;
    function DatasetFromStream(Idataset: TADOQuery; Stream: TMemoryStream): boolean;
    function DatasetToStream(iRecordset: TADOQuery; Stream: TMemoryStream): boolean;
  end;

var
  Gob_RmoDBsvr: TRmodbSvr;

implementation

uses sysUtils, pmybasedebug, db;

{ TRmoSvr }

function TRmodbSvr.DatasetFromStream(Idataset: TADOQuery; Stream:
  TMemoryStream): boolean;
var
  RS: Variant;
begin
  Result := false;
  if Stream.Size < 1 then
    Exit;
  try
    Stream.Position := 0;
    RS := Idataset.Recordset;
    Rs.Open(TStreamAdapter.Create(Stream) as IUnknown);
    Result := true;
  finally;
  end;
end;

function TRmodbSvr.DatasetToStream(iRecordset: TADOQuery; Stream:
  TMemoryStream): boolean;
const
  adPersistADTG = $00000000;
var
  RS: Variant;
begin
  Result := false;
  if iRecordset = nil then
    Exit;
  try
    RS := iRecordset.Recordset;
    RS.Save(TStreamAdapter.Create(stream) as IUnknown, adPersistADTG);
    Stream.Position := 0;
    Result := true;
  finally;
  end;
end;

function TRmodbSvr.ConnToDb(IConnStr: string): boolean;
begin
  Db := TDBMrg.Create(IConnStr);
  Result := True;
  if Shower <> nil then begin
    Shower.AddShow('�������ݿ⹦<%s>', [IConnStr]);
  end;
  Gqry := Db.GetAnQuery('GobQryer');
end;

procedure TRmodbSvr.OnCreate(ISocket: TBaseSocketServer);
begin
  inherited;
  Flock := TCriticalSection.Create;

end;

var
  gLastCpTime: Cardinal = 0;
  gLmemStream: TMemoryStream;

function TRmodbSvr.OnDataCase(ClientThread: TAsioClient; Ihead: integer):
  Boolean;
var
  Llen: integer;
  LSQl, ls: string;
begin
  Result := True;
  try
    case Ihead of //
      0: begin //�Ͽ�����
          ClientThread.Socket.Disconnect;
        end;
      1: begin //ִ��һ��SQL��� ���»���ִ��
          Flock.Enter;
          try
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);
            if Shower <> nil then
              Shower.AddShow('�ͻ���ִ�����<%s>', [LSQl]);
            try
              ClientThread.Socket.WriteInteger(Db.ExecAnSql(Gqry, LSQl, []));
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                LSQl:=e.Message;
                ClientThread.Socket.WriteInteger(Length(lsql));
                ClientThread.Socket.Write(lsql);
                if Shower <> nil then
                  Shower.AddShow('�ͻ���ִ������쳣<%s>', [e.Message]);
              end;
            end;
          finally
            Flock.Leave;
          end;
        end;
      2: begin //ִ��һ����ѯ���
          Flock.Enter;
          try
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);
            if Shower <> nil then
              Shower.AddShow('�ͻ���ִ�����<%s>', [LSQl]);
            try
              ls := GetCurrPath + GetDocDate + GetDocTime;
              Db.OpenDataset(Gqry, LSQl).SaveToFile(ls);
              ClientThread.Socket.WriteInteger(1);
              Socket.SendZIpFile(ls, ClientThread);
              DeleteFile(ls);
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                LSQl:=e.Message;
                ClientThread.Socket.WriteInteger(Length(lsql));
                ClientThread.Socket.Write(lsql);
                if Shower <> nil then
                  Shower.AddShow('�ͻ���ִ������쳣<%s>', [e.Message]);
              end;
            end;
          finally
            Flock.Leave;
          end;
        end;
      22: begin //ִ��һ����ѯ���   ��ʽ����
          Flock.Enter;
          try
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);
            if Shower <> nil then
              Shower.AddShow('�ͻ���ִ�����<%s>', [LSQl]);
            try
              if gLmemStream = nil then
                gLmemStream := TMemoryStream.Create;
              Db.OpenDataset(Gqry, LSQl); //.SaveToFile(ls);
              if Gqry.RecordCount > 500 then begin
                ls := GetCurrPath + GetDocDate + GetDocTime;
                Gqry.SaveToFile(ls);
                ClientThread.Socket.WriteInteger(11);
                Socket.SendZIpFile(ls, ClientThread);
                DeleteFile(ls);
              end
              else begin
                if gLmemStream.Size > 0 then
                  gLmemStream.Size := 0;
                DatasetToStream(Gqry, gLmemStream);
                ClientThread.Socket.WriteInteger(1);
                Socket.SendZIpStream(gLmemStream, ClientThread);
              end;
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                lsql:=e.Message;
                ClientThread.Socket.WriteInteger(Length(lsql));
                ClientThread.Socket.Write(lsql);
                if Shower <> nil then
                  Shower.AddShow('�ͻ���ִ������쳣<%s>', [e.Message]);
              end;
            end;
          finally
            Flock.Leave;
          end;
        end;
      3: begin //��ѯ��������ݿ������Ƿ�����

        end;
      4: begin //�����

        end;
      5: begin
          Flock.Enter;
          try
            ls := GetCurrDBPath(GGDBPath) + 'cfg1.mdb';
            if (gLastCpTime = 0) or (GetTickCount - gLastCpTime > 3600 * 1000 * 5) then begin
              CopyFile(PChar(GetCurrDBPath(GGDBPath) + 'cfg.mdb'), PChar(GetCurrDBPath(GGDBPath) + 'cfg1.mdb'), False);
              gLastCpTime := GetTickCount;
            end;
            Socket.SendZIpFile(ls, ClientThread);
          finally
            Flock.Leave;
          end;
        end;
      6: begin
          Flock.Enter;
          try
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);
            gLmemStream := ReadStream(gLmemStream, ClientThread);
            if Shower <> nil then
              Shower.AddShow('�ͻ���ִ��Blob�ֶ�<%s>', [LSQl]);
            try
              Gqry.Close;
              Gqry.SQL.Clear;
              Gqry.SQL.Add(LSQl);
              Gqry.Parameters.ParamByName('Pbob').LoadFromStream(gLmemStream, ftBlob);
              Gqry.ExecSQL;
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                lsql:=e.Message;
                ClientThread.Socket.WriteInteger(Length(lsql));
                ClientThread.Socket.Write(lsql);
                if Shower <> nil then
                  Shower.AddShow('�ͻ���ִ��Blob�ֶ�<%s>', [e.Message]);
              end;
            end;
          finally
            Flock.Leave;
          end;
        end;
    end; //case
  except
    on e: Exception do
      if Shower <> nil then
        Shower.AddShow('�߳�ִ���쳣<%s>', [e.Message]);
  end;
end;

procedure TRmodbSvr.OnDestroy;
begin
  inherited;
  try
    Db.Free;
  except
  end;
  Flock.Free;
end;


function TRmodbSvr.GetCurrDBPath(InPath: string): string;
var
  ISql: string;
  IGetPath: string;
  TStr: TStrings;
  i: Integer;
  iCount: Integer;
begin
  try
    Result := '';
    ISql := InPath;
    TStr := TStringList.Create;
    GetEveryWord(ISql, TStr, '\');
    iCount := TStr.Count;
    for i := 0 to Tstr.Count - 2 do begin
      IGetPath := IGetPath + TStr[i] + '\';
    end;
    TStr.Free;
  finally
    Result := IGetPath;
  end;
end;

function TRmodbSvr.ReadStream(Istream: TStream; ClientThread: TAsioClient):
  TMemoryStream;
var
  LBuff: Pointer;
  i, ltot, x: Integer;
begin
  if Istream = nil then
    Istream := TMemoryStream.Create;
  x := ClientThread.Socket.ReadInteger;
  TMemoryStream(Istream).Size := x;
  LBuff := TMemoryStream(Istream).Memory;
  ltot := Istream.Size;
  x := 0;
  while ltot > 0 do begin
    i := ClientThread.Socket.ReadBuff(PChar(LBuff) + x, ltot);
    Dec(ltot, i);
    inc(x, i);
  end; // while
  Result := TMemoryStream(Istream);
end;


end.

