{*******************************************************}
{      ��Ԫ����  UntSocketServer.pas                    }
{      �������ڣ�2006-2-28 20:36:19                     }
{      ������    ������                                 }
{      ���ܣ�    Tcp����������                        }
{                                                       }
{*******************************************************}



unit UntSocketServer;

interface
uses
  UntTBaseSocketServer, UntTIO, sysutils, untASIOSvr, WinSock;
type
  TCenterServer = class
  private
  protected
    procedure OnCreate(ISocket: TBaseSocketServer); virtual;
    procedure OnDestroy; virtual;
    procedure OnConning(ClientThread: TAsioClient); virtual;
    function OnCheckLogin(ClientThread: TAsioClient): boolean; virtual;
    {�û��Ͽ��¼�}
    procedure OnDisConn(ClientThread: TAsioClient); virtual;
    function OnDataCase(ClientThread: TAsioClient; Ihead: integer): Boolean;
      virtual;
    procedure OnException(ClientThread: TAsioClient; Ie: Exception); virtual;
//------------------------------------------------------------------------------
// �����Լ�ʹ�õķ��� 2006-8-23 ������
//------------------------------------------------------------------------------
    {�û������¼� Ҳ������¼�}
    procedure UserConn(ClientThread: TAsioClient; Iwantlen: integer);
    {���������¼�}
    procedure DataCase(ClientThread: TAsioClient); virtual;
  public
    Shower: TIOer;
    Socket: TBaseSocketServer;
    {*�����̻߳�ȡIP�Ͷ˿ں�}
    function GetUserIpAndPort(ClientThread: TAsioClient): string;
    constructor Create(IServerPort: Integer; Iio: TIOer = nil);
    destructor Destroy; override;
  end;


implementation

uses UntBaseProctol, pmybasedebug;

{ TSocketServer }

constructor TCenterServer.Create(IServerPort: Integer; Iio: TIOer = nil);
begin
  Socket := TBaseSocketServer.Create(IServerPort);
  Socket.Server.FOnCaseData := UserConn;
  Socket.Server.FOnClientDisConn := OnDisConn;
  Socket.Server.StartSvr(IServerPort);
  Shower := Iio;
  OnCreate(Socket);
end;

destructor TCenterServer.Destroy;
begin
  OnDestroy;
  Socket.Free;
  inherited;
end;

procedure TCenterServer.DataCase(ClientThread: TAsioClient);
var
  Lhead: Integer;
begin
  if (ClientThread.DeadTime = 0) then begin
    Lhead := ClientThread.RcvDataBuffer.ReadInteger;
    case Lhead of //
      -1: ; //Shower.AddShow('�յ�Client %s:%d ��������Ϣ',[ClientThread.Socket.PeerIPAddress, ClientThread.Socket.PeerPort]);
    else
      if not OnDataCase(ClientThread, Lhead) then
        if Shower <> nil then
          Shower.AddShow(Format('�յ�����������%d', [Lhead]));
    end; // case
  end; // while
end;


procedure TCenterServer.OnCreate(ISocket: TBaseSocketServer);
begin
  if Shower <> nil then
    Shower.AddShow('����ɹ�����...�˿�:%d', [ISocket.Server.Fport]);
end;

type
  RBaseCaserd = packed record
    Id: Integer;
    Len: Integer;
    Pointer: integer;
  end;
  PRBaseCaserd = ^RBaseCaserd;

procedure TCenterServer.UserConn(ClientThread: TAsioClient; Iwantlen: integer);
var
  i, Lhead: Integer;
  LPrd: PRBaseCaserd;
  Lbuff: TPoolItem;
  IClient: TAsioClient;
begin
  IClient := ClientThread;
  if IClient.DeadTime > 0 then Exit;
  try
    if IClient.ConnState = Casio_State_Init then begin
      OnConning(ClientThread);
      if OnCheckLogin(ClientThread) then begin
        ClientThread.ConnState := Casio_State_Conned
      end
      else begin
        ClientThread.ConnState := Casio_State_DisConn;
        OnDisConn(ClientThread);
        ClientThread.Socket.Disconnect;
      end;
    end
    else if IClient.ConnState = Casio_State_Conned then begin
      //�ж����ݴ���״̬
      case IClient.RcvDataBuffer.State of //��ȡ����ͷ
        CdataRcv_State_head: begin
            IClient.RcvDataBuffer.ReadInteger(true); //��ͷ
            IClient.RcvDataBuffer.WantData := IClient.RcvDataBuffer.ReadInteger(true); //4���ֽ� //����
            IClient.RcvDataBuffer.State := CdataRcv_State_Body; //��ȡ����
//        DeBug('�յ�����<Currpost:%d ReadPos:%d NextSize:%d wantdata:%d>',
//          [IClient.RcvDataBuffer.CurrPost, IClient.RcvDataBuffer.ReadPos,
//          IClient.RcvDataBuffer.Memory.Position, IClient.RcvDataBuffer.WantData]);
          end;
        CdataRcv_State_len: begin //��ȡ���ݳ���
            IClient.RcvDataBuffer.WantData := IClient.RcvDataBuffer.ReadInteger(true); //4���ֽ�
            IClient.RcvDataBuffer.State := CdataRcv_State_Body;
//        DeBug('������<Currpost:%d ReadPos:%d NextSize:%d wantdata:%d>',
//          [IClient.RcvDataBuffer.CurrPost, IClient.RcvDataBuffer.ReadPos,
//          IClient.RcvDataBuffer.Memory.Position, IClient.RcvDataBuffer.WantData]);
          end;
        CdataRcv_State_Body: begin //�������
           //IClient.RcvDataBuffer.ReadBuff(IClient.RcvDataBuffer.WantData); //4���ֽ�
            IClient.RcvDataBuffer.WantData := 8;
            IClient.RcvDataBuffer.State := CdataRcv_State_head;
//        DeBug('�������<Currpost:%d ReadPos:%d NextSize:%d wantdata:%d>',
//          [IClient.RcvDataBuffer.CurrPost, IClient.RcvDataBuffer.ReadPos,
//          IClient.RcvDataBuffer.Memory.Position, IClient.RcvDataBuffer.wantdata]);
          {�������ݰ�}
            DataCase(IClient);
//            LPrd := PRBaseCaserd(@IClient.RcvDataBuffer.Gbuff[0]);
//            case LPrd^.Id of
//              1: begin //����echo����
//                  Lbuff := IClient.MemPool.GetBuff(Ckind_FreeMem);
//                  Lbuff.FMem.Position := 0;
//              //���㲢���ؽ��
//                  Lhead := 0;
//                  for i := 8 to 11 do begin
//                    inc(Lhead, IClient.RcvDataBuffer.Gbuff[i]);
//                  end;
//                  LPrd^.Pointer := Lhead;
//                  Lbuff.FMem.WriteBuffer(LPrd^, 8 + 4);
//                  IClient.SendData(Lbuff);
////              DeBug('�ظ�->%d', [LPrd^.Pointer]);
//                end;
//              2: ; //������
//            end;
          end;
      end;
    end;
  except
    on e: exception do begin
      OnException(ClientThread, e);
    end;
  end;
end;

procedure TCenterServer.OnConning(ClientThread: TAsioClient);
begin
  if Shower <> nil then
    Shower.AddShow(Format('����%s:%d�û���������', [ClientThread.PeerIP, ClientThread.PeerPort]));
end;

function TCenterServer.OnCheckLogin(ClientThread: TAsioClient): boolean;
begin
  Result := True;
  if ClientThread.RcvDataBuffer.ReadInteger <> CTSLogin then begin
    Result := False;
    Socket.SendHead(STCLoginFault_Vison, ClientThread);
  end;
  if ClientThread.Socket.ReadInteger <> CClientID then begin
    Result := False;
    Socket.SendHead(STCLoginFault_Vison, ClientThread);
  end;
  if Result then
    Socket.SendHead(STCLogined, ClientThread);
end;

procedure TCenterServer.OnDisConn(ClientThread: TAsioClient);
begin
  if (ClientThread <> nil) and (ClientThread.Socket <> nil) then begin
    if Shower <> nil then
      Shower.AddShow('�û��Ͽ�������');
    ClientThread.Socket.Disconnect;
  end
end;

function TCenterServer.OnDataCase(ClientThread: TAsioClient; Ihead: integer):
  Boolean;
begin
  Result := True;
end;

procedure TCenterServer.OnException(ClientThread: TAsioClient; Ie: Exception);
begin
  if Shower <> nil then
    Shower.AddShow(Format('�û������߳��쳣 ԭ��:%s', [Ie.ClassName + '>> ' + Ie.Message]));
end;

procedure TCenterServer.OnDestroy;
begin
  if Shower <> nil then
    Shower.AddShow('�����ͷųɹ�...');
end;

function TCenterServer.GetUserIpAndPort(ClientThread: TAsioClient): string;
begin
  Result := ClientThread.PeerIP + ':' + IntToStr(ClientThread.PeerPort);
end;

end.

