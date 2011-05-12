{ *******************************************************
  ��Ԫ���ƣ�UntRmodbSvr.pas
  �������ڣ�2008-09-16 17:26:15
  ������	  ������
  ����:     Զ�����ݿ�����
  ��ǰ�汾��v3.0.0
  ��ʷ��
  v2.0.0 2011-04-18
  ��ASIO���и�Ч�ʵķ�װ��
  ͬʱ��װ��Ч�����ݴ���ģ��
  v2.0.1 2011-04-19
  ���Ӵ洢���̵��õ�֧�֣��ο���ˮ��������޸İ汾��
  �ڴ˶Ծ�ˮ�����ʾ��л
  v2.0.2 2011-04-20
  ����MAX()��ʽ��ȡ���ݼ�¼�����ݱ��ڴ��ڴ�����¼ʱ����������ҿ��ܵ���ID��ͻ��
  �����أ����ӿ��ٻ�ȡ������ID�ķ�ʽ���ͻ��˿������Ƿ�ʹ�����ַ�ʽ
  v2.0.3 2011-04-25
  ����Ⱥ��Daniel���� ����ִ�����ʱ�������ȫ
  v3.00  2011-04-29
     �޸�һ���򵥵����������ʾ����
  ******************************************************* }

unit UntRmodbSvr;

interface

uses Classes, UntSocketServer, untFunctions, syncobjs,
  Windows, Forms, DBClient, untASIOSvr;

type
  Tuserinfo = class
  public
    Name: string;
    psd: string;
  end;

  TchatSvr = class(TCenterServer)
  private
    Flock: TCriticalSection;
    function ReadStream(Istream: TStream; ClientThread: TAsioClient)
      : TMemoryStream;
  public
    function Getonlineuser: string; //��ȡ�����û��б�
    procedure BroCastUserChange(ikind: integer; iclient: TAsioClient);
    procedure SendtoInfo(Ifrom, iwho: string; IContent: ansistring); overload;
    procedure SendtoInfo(Ifrom: string; IClientobj: TAsioClient; IContent:
      ansistring); overload;
    function OnCheckLogin(ClientThread: TAsioClient): boolean; override;
    function OnDataCase(ClientThread: TAsioClient; Ihead: Integer)
      : boolean; override;
    procedure OnDisConn(ClientThread: TAsioClient); override;
    procedure OnCreate(ISocket: TBaseSocketServer); override;
    procedure OnDestroy; override;
  end;

var
  Gob_Chatsvr: TchatSvr;

implementation

uses sysUtils, Variants;

procedure TchatSvr.OnCreate(ISocket: TBaseSocketServer);
begin
  inherited;
  Flock := TCriticalSection.Create;
end;


function TchatSvr.OnDataCase(ClientThread: TAsioClient;
  Ihead: Integer): boolean;
var
  i: Integer;
  Llen: Integer;
  LSQl, ls, lp: ansistring;
  lspit: TStrings;
begin
  Result := true;
  try
    case Ihead of //
      0: begin // �Ͽ�����
          ClientThread.Socket.Disconnect;
        end;
      1: begin //��ȡ�����û��б�
          ls := Getonlineuser;
          Llen := length(ls);
          if Llen > 0 then begin
            ClientThread.Socket.Writeinteger(1);
            ClientThread.Socket.Writeinteger(Llen);
            ClientThread.Socket.Write(ls);
          end;
        end;
      2: begin //����
          Llen := ClientThread.Socket.Readinteger();
          ls := ClientThread.Socket.ReadStr(Llen);
          lspit := TStringList.Create;
          //�ҵ�Ҫ���͵Ŀͻ���
          try
            ExtractStrings(['|'], [' '], PansiChar(ls), lspit);
            if lspit.Count = 2 then begin
              if lspit[0] = 'all' then begin
                for i := Socket.FClientLst.Count - 1 downto 0 do begin
                  try
                    SendtoInfo(Tuserinfo(ClientThread.userdata).Name, TAsioClient(Socket.FClientLst.Objects[i]), lspit[1]);
                  except
                  end;
                end;
              end
              else begin
                SendtoInfo(Tuserinfo(ClientThread.userdata).Name, lspit[0], lspit[1]);
              end;
            end;
          //����
          finally
            lspit.Free;
          end;
        end;
      3: begin //�ļ�����

        end;
    end; // case
  except
    on e: Exception do
      if Shower <> nil then
        Shower.AddShow('�߳�ִ���쳣<%s>', [e.Message]);
  end;
end;

procedure TchatSvr.OnDestroy;
begin
  inherited;
  Flock.Free;
end;

function TchatSvr.ReadStream(Istream: TStream; ClientThread: TAsioClient)
  : TMemoryStream;
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


function TchatSvr.OnCheckLogin(ClientThread: TAsioClient): boolean;
var
  i: Integer;
  lbuff: Tuserinfo;
  lspit: TStrings;
  lname, lpsd, ls: ansistring;
  lws: string;
begin
  inherited OnCheckLogin(ClientThread);
  i := ClientThread.Socket.ReadInteger;
  ls := ClientThread.Socket.ReadStr(i);
  Result := false;
  try
    lspit := TStringList.Create;
    lws := ls;
    ExtractStrings(['|'], [' '], PChar(lws), lspit);
    if lspit.Count = 2 then begin
      if trim(lspit[0]) <> '' then begin
        // ���ͻ��˵�½Ȩ����֤
        if Length(lspit[1]) > 0 then begin
          Result := True;
          for i := 0 to Socket.FClientLst.Count - 1 do begin
            if TAsioClient(Socket.FClientLst.Objects[i]).userdata <> nil then
              if Tuserinfo(TAsioClient(Socket.FClientLst.Objects[i]).userdata).Name = lspit[0] then begin
                Result := False;
                Break;
              end;
          end;
          if Result then begin
            lbuff := Tuserinfo.Create;
            lbuff.Name := lspit[0];
            lbuff.psd := lspit[1];
            ClientThread.userdata := lbuff;
            Result := true;
            BroCastUserChange(1, ClientThread);
            if Shower <> nil then
              Shower.AddShow('�û�:%s����֤ͨ�����ɹ�����...(�����û���:%d)', [lspit[0], Socket.FClientLst.Count]);
          end
          else begin
            if Shower <> nil then
              Shower.AddShow('�û�:%s���Ѿ����ڣ���¼ʧ��...', [lspit[0]]);
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

function TchatSvr.Getonlineuser: string;
var
  i: integer;
begin
  for i := 0 to Socket.FClientLst.Count - 1 do begin
    if TAsioClient(Socket.FClientLst.Objects[i]).userdata <> nil then begin
      Result := Result + Tuserinfo(TAsioClient(Socket.FClientLst.Objects[i]).userdata).Name;
      if i < Socket.FClientLst.Count - 1 then
        Result := Result + ','
    end;
  end;
end;

procedure TchatSvr.SendtoInfo(Ifrom, iwho: string; IContent: ansistring);
var
  i, llen: integer;
  ls: AnsiString;
begin
  for i := 0 to Socket.FClientLst.Count - 1 do begin
    if iwho = Tuserinfo(TAsioClient(Socket.FClientLst.Objects[i]).userdata).Name then begin
      TAsioClient(Socket.FClientLst.Objects[i]).Socket.Writeinteger(2);
      ls := Format('%s|%s|%s', [Ifrom, iwho, IContent]);
      llen := length(ls);
      TAsioClient(Socket.FClientLst.Objects[i]).Socket.Writeinteger(llen);
      TAsioClient(Socket.FClientLst.Objects[i]).Socket.Write(ls);
      if Shower <> nil then
        Shower.AddShow('%s��%s˵:%s', [Ifrom, iwho, IContent]);
      break;
    end;
  end;
end;

procedure TchatSvr.SendtoInfo(Ifrom: string; IClientobj: TAsioClient; IContent:
  ansistring);
var
  i, llen: integer;
  ls: AnsiString;
begin
  IClientobj.Socket.Writeinteger(2);
  ls := Format('%s|%s|%s', [Ifrom, Tuserinfo(IClientobj.userdata).Name, IContent]);
  llen := length(ls);
  IClientobj.Socket.Writeinteger(llen);
  IClientobj.Socket.Write(ls);
  if Shower <> nil then
    Shower.AddShow('%s��%s˵:%s', [Ifrom, Tuserinfo(IClientobj.userdata).Name, IContent]);
end;

procedure TchatSvr.BroCastUserChange(ikind: integer; iclient: TAsioClient);
var
  i: integer;
begin
  for i := 0 to Socket.FClientLst.Count - 1 do begin
    if (iclient <> TAsioClient(Socket.FClientLst.Objects[i])) and (TAsioClient(Socket.FClientLst.Objects[i]).userdata <> nil) then begin
      TAsioClient(Socket.FClientLst.Objects[i]).Socket.Writeinteger(4);
      TAsioClient(Socket.FClientLst.Objects[i]).Socket.Writeinteger(ikind); //1 ����, 2 �뿪
    end;
  end;
end;

procedure TchatSvr.OnDisConn(ClientThread: TAsioClient);
begin
  if ClientThread.userdata <> nil then begin
    BroCastUserChange(2, ClientThread);
    Tuserinfo(ClientThread.userdata).Free;
  end;
  inherited;
end;

end.

