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
  Classes, UntsocketDxBaseClient, IdComponent, Controls, ExtCtrls, db, viewFileMM,
  SyncObjs;

type
  TConnthread = class;



  TchatClient = class(TSocketClient)
  private
    gLmemStream: TMemoryStream;
    FCachSQllst, FsqlLst: TStrings; //������¼�Ѿ����˵����ݼ� �Լ����ڵ����
    FSqlPart1, FSqlPart2: string;

    Fsn: Cardinal;
    FIsDisConn: boolean; //�Ƿ����Լ��ֶ��Ͽ����ӵ�
    Ftimer: TTimer; //���ӱ�����
    FisConning: Boolean; //�Ƿ����ӳɹ�
    //��ʱ����Ƿ���Ҫ���� �������ӶϿ�
    procedure OnCheck(Sender: TObject);
     //����Ƿ����Ӵ��
    procedure checkLive;

  public
    Flock: TCriticalSection;
    IsSpeedGetID: Boolean; //�Ƿ�ʹ�ø��ٷ�ʽ��ȡ������ID
    IsInserIDfield: boolean; //�Ƿ������� ֧��ID�ֶ� �����������������ֶ�Ĭ����false
    FLastInsertID: Integer; //insert���ʱ���ز����¼�������ֶε�ֵ

    //���ӷ����
    function ConnToSvr(ISvrIP: ansistring; ISvrPort: Integer = 9988; Iacc: ansistring = '';
      iPsd: ansistring = ''): boolean;
    //�Ͽ�����
    procedure DisConn;

    //��ȡ�����û��б�
    procedure Getonlineuser;
    //��ȡ������ļ��б�
    procedure GetsvrFilelist;

    //��ȡ�ļ�ID
    procedure GetFileID(IFile: string);
    //�ļ�����
    procedure TransFile(IMisson: TFileMisson);

    //����
    procedure SaySome(itoWho: string; IContent: string);

    //���������µ�IP
    function ReConn(ISvrIP: ansistring; IPort: Integer = -1; Iacc: ansistring = '';
      iPsd: ansistring = ''): boolean;

    procedure OnCreate; override;
    procedure OnDestory; override;
  end;


  TConnthread = class(TThread)
  public
    Client: TchatClient;
    procedure execute; override;
  end;

var
  //Զ�����ӿ��ƶ���
  Gob_RmoCtler: TchatClient;
  GCurrVer: integer = 1; //��ǰ���������汾��

implementation

uses untfunctions, sysUtils, UntBaseProctol, IniFiles, ADOInt, Variants,
  Windows, untASIOSvr, Math;


procedure TchatClient.checkLive;
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

function TchatClient.ConnToSvr(ISvrIP: ansistring; ISvrPort: Integer = 9988;
  Iacc: ansistring = ''; iPsd: ansistring = ''): boolean;
var
  i: Integer;
  ls: ansistring;
begin
  Result := True;
  if (FisConning = false) or (FHost <> ISvrIP) or (FPort <> ISvrPort) then begin
   // DisConn;
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
      ls := format('%s|%s', [Iacc, Str_Encry(iPsd, 'cht')]);
      Writeinteger(Length(ls));
      Write(ls);
      if ReadInteger <> STCLogined then begin
        Result := False;
        DisConn;
        FisConning := False;
        Exit;
      end;
      FisConning := True;
      FIsDisConn := False;
      Ftimer.Enabled := True;

    end;
  end;
end;

procedure TchatClient.DisConn;
begin
  try
//    if IsConnected then
    CloseConn;
  except
  end;
  FisConning := False;
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



procedure TchatClient.GetsvrFilelist;
begin
  if Gob_RmoCtler.IsConning then begin
    Flock.Enter;
    try
      SendAsioHead(4);
      Writeinteger(3);
    finally
      Flock.Release;
    end;
  end;
end;

procedure TchatClient.Getonlineuser;
begin
  if Gob_RmoCtler.IsConning then begin
    Flock.Enter;
    try
      SendAsioHead(4);
      Writeinteger(1);
    finally
      Flock.Release;
    end;
  end;
end;

procedure TchatClient.OnCheck(Sender: TObject);
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

procedure TchatClient.OnCreate;
begin
  inherited;
  Flock := TCriticalSection.Create;
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

procedure TchatClient.OnDestory;
begin
  inherited;
  FCachSQllst.Free;
  Ftimer.Free;
  FsqlLst.Free;
  gLmemStream.Free;
  Flock.Free;
end;

function TchatClient.ReConn(ISvrIP: ansistring; IPort: Integer = -1; Iacc: ansistring = '';
  iPsd: ansistring = ''): boolean;
begin
  Result := False;
  if IsLegalIP(ISvrIP) then begin
    Result := ConnToSvr(ISvrIP, untfunctions.IfThen(IPort = -1, FPort, IPort), iacc, ipsd);
  end;
end;

procedure TchatClient.SaySome(itoWho: string; IContent: string);
var
  llen: integer;
  lls: string;
begin
  IContent := StringReplace(IContent, #13, ' ', [rfReplaceAll]);
  IContent := StringReplace(IContent, #10, ' ', [rfReplaceAll]);
  lls := Format('%s|%s', [iToWho, IContent]);
  llen := length(lls);
  Flock.Acquire;
  try
    SendAsioHead(8 + llen);
    Writeinteger(2);
    Writeinteger(llen);
    WriteString(lls);
  finally
    Flock.Release;
  end;
end;

procedure TchatClient.GetFileID(IFile: string);
var
  llen: integer;
begin
  Flock.Acquire;
  try
    llen := length(IFile);
    SendAsioHead(8 + llen);
    Writeinteger(5);
    Writeinteger(llen);
    WriteString(IFile);
  finally
    Flock.Release;
  end;
end;

procedure TchatClient.TransFile(IMisson: TFileMisson);
var
  llen: integer;
begin
  if IMisson.Transrd.Dir = 1 then begin //�ϴ�

  end
  else begin //����
    IMisson.Transrd.len := Min(256000, IMisson.FileSize - IMisson.Transrd.RangeStart);
    llen := sizeof(IMisson.Transrd);
    Flock.Acquire;
    try
      SendAsioHead(4 + llen);
      Writeinteger(6);
      Gob_RmoCtler.WriteBuff(IMisson.Transrd, sizeof(IMisson.Transrd));
    finally
      Flock.Release;
    end;
//    IMisson.FileSize.
  end;
end;

end.

