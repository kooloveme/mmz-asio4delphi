{*******************************************************
        ��Ԫ���ƣ�UntRmodbSvr.pas
        �������ڣ�2008-09-16 17:26:15
        ������	  ������
        ����:     Զ�����ݿ�����
        ��ǰ�汾��v2.0.1
        ��ʷ��
        v2.0.0 2011-04-18
                   ��ASIO���и�Ч�ʵķ�װ��
                  ͬʱ��װ��Ч�����ݴ���ģ��
        v2.0.1 2011-04-19
                  ���Ӵ洢���̵��õ�֧�֣��ο���ˮ��������޸İ汾��
                  �ڴ˶Ծ�ˮ�����ʾ��л
*******************************************************}

unit UntRmodbSvr;


interface

uses Classes, UntSocketServer, UntTBaseSocketServer, untFunctions, syncobjs, Windows, Forms,
  DBClient, untASIOSvr;


type
  TRmodbSvr = class(TCenterServer)
  private
    Flock: TCriticalSection;
    function ReadStream(Istream: TStream; ClientThread: TAsioClient): TMemoryStream;
  public
    GGDBPath: ansistring;
    gLastCpTime: Cardinal;
    gLmemStream: TMemoryStream;
    glBatchLst: TStrings;
    //���ӵ����ݿ�
    function ConnToDb(IConnStr: ansistring): boolean;
    function OnCheckLogin(ClientThread: TAsioClient): boolean; override;
    function OnDataCase(ClientThread: TAsioClient; Ihead: integer): Boolean;
      override;
    procedure OnCreate(ISocket: TBaseSocketServer); override;
    procedure OnDestroy; override;
    function GetCurrDBPath(InPath: ansistring): ansistring;
    function DatasetFromStream(Idataset: TClientDataSet; Stream: TMemoryStream): boolean;
    function DatasetToStream(iRecordset: TClientDataSet; Stream: TMemoryStream): boolean;
  end;

var
  Gob_RmoDBsvr: TRmodbSvr;

implementation

uses sysUtils, pmybasedebug, db, DM, Variants, UntCFGer, IniFiles;

{ TRmoSvr }

function TRmodbSvr.DatasetFromStream(Idataset: TClientDataSet; Stream:
  TMemoryStream): boolean;
var
  RS: Variant;
begin
  Result := false;
  if Stream.Size < 1 then
    Exit;
  try
    Stream.Position := 0;
//    RS := Idataset.Recordset;
    Rs.Open(TStreamAdapter.Create(Stream) as IUnknown);
    Result := true;
  finally;
  end;
end;

function TRmodbSvr.DatasetToStream(iRecordset: TClientDataSet; Stream:
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
//    RS := iRecordset.Recordset;
    RS.Save(TStreamAdapter.Create(stream) as IUnknown, adPersistADTG);
    Stream.Position := 0;
    Result := true;
  finally;
  end;
end;

function TRmodbSvr.ConnToDb(IConnStr: ansistring): boolean;
begin

  Result := True;
  if Shower <> nil then begin
    Shower.AddShow('�������ݿ⹦<%s>', [IConnStr]);
  end;
end;

procedure TRmodbSvr.OnCreate(ISocket: TBaseSocketServer);
begin
  inherited;
  Flock := TCriticalSection.Create;
  gLmemStream := TMemoryStream.Create;
  gLastCpTime := 0;
  glBatchLst := TStringList.Create;
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

var
  lini: TIniFile;

procedure MGetFileListToStr(var Resp: ansistring; ISpit: ansistring; iFilter, iPath:
  ansistring; ContainSubDir: Boolean = True; INeedPath: boolean = True);
var
  FSearchRec, DSearchRec: TSearchRec;
  FindResult: Cardinal;
begin
  FindResult := FindFirst(iPath + iFilter, sysutils.faAnyFile, FSearchRec);
  try
    while FindResult = 0 do begin
      if ((FSearchRec.Attr and faDirectory) = faDirectory) or (FSearchRec.Name = '.') or (FSearchRec.Name = '..') or (ExtractFileExt(FSearchRec.Name) = '.lnk') then begin
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
    if ContainSubDir then begin
      FindResult := FindFirst(iPath + iFilter, faDirectory, DSearchRec);
      while FindResult = 0 do begin
        if ((DSearchRec.Attr and faDirectory) = faDirectory)
          and (DSearchRec.Name <> '.') and (DSearchRec.Name <> '..') then begin
          MGetFileListToStr(Resp, ISpit, iFilter, iPath + DSearchRec.Name + '\', ContainSubDir);
        end;
        FindResult := FindNext(DSearchRec);
      end;
    end;
  finally
    sysUtils.FindClose(FSearchRec);
    sysUtils.FindClose(DSearchRec);
  end;
end;

function TRmodbSvr.OnDataCase(ClientThread: TAsioClient; Ihead: integer):
  Boolean;
var
  i: Integer;
  Llen: integer;
  LSQl, ls: string;
begin
  Result := True;
  try
    case Ihead of //
      9998: begin
        //�ͻ��˲�ѯ������Ϣ
          if FileExists(GetCurrPath() + 'update.ini') then begin
            if lini = nil then
              lini := TIniFile.Create(GetCurrPath + 'update.ini');
            ClientThread.Socket.WriteInteger(1);
            ClientThread.Socket.WriteInteger(lini.ReadInteger('info', 'ver', 0));
            i := lini.ReadInteger('info', 'isfrce', 1);
            ClientThread.Socket.WriteInteger(i);
            ClientThread.Socket.WriteInteger(length(GetCurrPath));
            ClientThread.Socket.Write(GetCurrPath);
            ls := lini.ReadString('info', 'hint', '��');
            ClientThread.Socket.WriteInteger(length(ls));
            ClientThread.Socket.Write(ls);
            ls := '';
            MGetFileListToStr(ls, '|', '*.*', GetCurrPath + lini.ReadString('info', 'filepath', 'update'), True);
            ClientThread.Socket.WriteInteger(length(ls));
            ClientThread.Socket.Write(ls);
          end
          else
            ClientThread.Socket.WriteInteger(0);
        end;
      9997: begin
          Llen := ClientThread.Socket.ReadInteger;
          ls := ClientThread.Socket.ReadStr(Llen);
          if FileExists(ls) then begin
            ClientThread.Socket.WriteInteger(1);
            Socket.SendZIpFile(ls, ClientThread);
          end
          else
            ClientThread.Socket.WriteInteger(0);
        end;
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
              DataModel.UniSQL.SQL.Clear;
              DataModel.UniSQL.SQL.Add(LSQl);
              DataModel.UniSQL.Execute;
              ClientThread.Socket.WriteInteger(1);
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                ClientThread.Socket.WriteInteger(Length(e.Message));
                ClientThread.Socket.Write(e.Message);
                if Shower <> nil then
                  Shower.AddShow('�ͻ���ִ������쳣<%s>', [e.Message]);
              end;
            end;
          finally
            Flock.Leave;
          end;
        end;
      1011: {//ִ�д洢���� �����ؽ����} begin
          Flock.Enter;
          try
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);

            DataModel.UniProc.SQL.Clear;
            DataModel.UniProc.SQL.Add(lsql);
            try
              DataModel.UniProc.Open;
              if gLmemStream <> nil then
                gLmemStream.Clear;
              VarArrayToStream(DataModel.dpProc.Data, gLmemStream);
              ClientThread.Socket.WriteInteger(1);
              Socket.SendZIpStream(gLmemStream, ClientThread);
              if Shower <> nil then
                Shower.AddShow('�洢���̷������ݼ�����¼����%s',
                  [IntToStr(DataModel.dpProc.DataSet.RecordCount)]);
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                ClientThread.Socket.WriteInteger(Length(e.Message));
                ClientThread.Socket.Write(e.Message);
                if Shower <> nil then
                  Shower.AddShow('%s�洢���̴�ȡʧ��<%s>', [e.Message]);
              end;
            end;
          finally
            Flock.Leave;
          end;
        end;

      110: begin //����ִ�����
          Flock.Enter;
          try
            gLmemStream.Size := 0;
            Socket.GetZipStream(gLmemStream, ClientThread);
            glBatchLst.LoadFromStream(gLmemStream);
            gLmemStream.Size := 0;
            if Shower <> nil then
              Shower.AddShow('�ͻ�������ִ�����', [LSQl]);
            try
              if glBatchLst.Count > 0 then begin
                for Llen := 0 to glBatchLst.Count - 1 do begin // Iterate
                  DataModel.UniSQL.SQL.Clear;
                  DataModel.UniSQL.SQL.Add(glBatchLst[Llen]);
                  DataModel.UniSQL.Execute;
                end; // for
              end;
              ClientThread.Socket.WriteInteger(1);
            except
              on e: Exception do begin
//                glBatchLst.SaveToFile('D:\1.txt');
                ClientThread.Socket.WriteInteger(-1);
                ClientThread.Socket.WriteInteger(Length(e.Message));
                ClientThread.Socket.Write(e.Message);
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
            gLmemStream.Size := 0;
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);
            try
//              ls := GetCurrPath + GetDocDate + GetDocTime;
              if Shower <> nil then
                Shower.AddShow('�ͻ���ִ�в�ѯ���<%s>', [LSQl]);
              DataModel.Gqry.Close;
              DataModel.Gqry.SQL.Clear;
              DataModel.Gqry.SQL.Add(LSQl);
              DataModel.Gqry.Open;
              VarArrayToStream(DataModel.Dp.Data, gLmemStream);
              ClientThread.Socket.WriteInteger(1);
              Socket.SendZIpStream(gLmemStream, ClientThread);
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                ClientThread.Socket.WriteInteger(Length(e.Message));
                ClientThread.Socket.Write(e.Message);
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
              CopyFile(PansiChar(GetCurrDBPath(GGDBPath) + 'cfg.mdb'), PansiChar(GetCurrDBPath(GGDBPath) + 'cfg1.mdb'), False);
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
            gLmemStream.Size := 0;
            Llen := ClientThread.Socket.ReadInteger;
            LSQl := ClientThread.Socket.ReadStr(Llen);
            gLmemStream := ReadStream(gLmemStream, ClientThread);
            if Shower <> nil then
              Shower.AddShow('�ͻ���ִ��Blob�ֶ�<%s>', [LSQl]);
            try
              DataModel.Gqry.Close;
              DataModel.Gqry.SQL.Clear;
              DataModel.Gqry.SQL.Add(LSQl);
              DataModel.Gqry.Params.ParamByName('Pbob').LoadFromStream(gLmemStream, ftBlob);
              DataModel.Gqry.Execute;
            except
              on e: Exception do begin
                ClientThread.Socket.WriteInteger(-1);
                ClientThread.Socket.WriteInteger(Length(e.Message));
                ClientThread.Socket.Write(e.Message);
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
  Flock.Free;
  glBatchLst.Free;
  gLmemStream.Free;
end;


function TRmodbSvr.GetCurrDBPath(InPath: ansistring): ansistring;
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
    i := ClientThread.Socket.ReadBuff(PansiChar(LBuff) + x, ltot);
    Dec(ltot, i);
    inc(x, i);
  end; // while
  Result := TMemoryStream(Istream);
end;


function TRmodbSvr.OnCheckLogin(ClientThread: TAsioClient): boolean;
var
  i: Integer;
  lspit: TStrings;
  lname, lpsd, ls: string;
begin
  inherited OnCheckLogin(ClientThread);
  i := ClientThread.Socket.ReadInteger;
  ls := ClientThread.Socket.ReadStr(i);
  Result := false;
  try
    Gob_CFGer.SetSecton('auth');
    lspit := TStringList.Create;
    ExtractStrings(['|'], [' '], pansichar(ls), lspit);
    if lspit.Count = 2 then begin
      if trim(lspit[0]) <> '' then begin
        //���ͻ��˵�½Ȩ����֤
        lpsd := Gob_CFGer.ReadString(lspit[0]);
        if length(lspit[1]) > 0 then begin
          if lpsd = Str_Decry(lspit[1], 'rmo') then begin
            Result := true;
            if Shower <> nil then
              Shower.AddShow('�û�:%s����֤ͨ�����ɹ�����...', [lspit[0]]);
          end;
        end;
      end;
    end
  finally
    lspit.Free;
  end;
  if Result then
    ClientThread.Socket.WriteInteger(1001)
  else
    ClientThread.Socket.WriteInteger(1002)
end;

end.

