{*******************************************************}
{      ��Ԫ����  modelCenterClient.pas                  }
{      �������ڣ�2006-2-23 23:43:07                     }
{      ������    ������                                 }
{      ���ܣ�    Զ�̽ӿڿͻ���                         }
{                �������ӷ�����ͨ��                     }
{*******************************************************}

unit modelCommClient;

interface
uses Classes, Forms, UntsocketDxBaseClient, ADODB, SyncObjs,
  Graphics;

type
  TWorkthread = class;
  //����ͻ��˶���
  TCommClient = class(TSocketClient)
  private
    function DatasetToStream(iRecordset: TADOQuery; Stream: TMemoryStream): boolean;

  public
    index: Integer;
    FUpEventLock: TCriticalSection;
    FWaiteUpWarningLst: TStrings;
    LiveTime: Cardinal;
    USerID: string; //Ψһ��ʶ
    UserKind: Integer; //1�¼��û�
    GMemBuff: TMemoryStream;

    ReadThread: TWorkthread;
    MsgWnd: Integer;
    //����Ĵ������

    LCmd: integer; //��ʼ���ǽ���
    Lid: integer; //id
    LStat: integer; //״̬
    LInfo: string;

    Fdbid: Integer;
    FState: Integer;
    FexpBMP: TMemoryStream;
    FAreaid: Integer;
    FExpTime: Integer;
    FexpInfo: string;
    lbuff: array[0..511] of byte;

    lsum: Integer;
    beginSend: Cardinal;
    Fupstate: boolean; //����ĸ���״̬
    isRcv: Boolean;
    grcvTime: Cardinal;
    //��ʼ����
    procedure StartWork;
    procedure Stop;
    //�ı�����״̬
    procedure RequestState(IWant: boolean = true);
    //֪ͨ�������ݱ�
    procedure UpTable(Ikind, Idata: integer);

    //֪ͨ�������
    procedure NowCheck(Iid: string);

    //�����¼�
    procedure DoCase; virtual;
    //���ӳɹ�
    procedure OnConnSuccess;
    procedure OnCreate; override;
    procedure OnDestory; override;
  end;

  //�����̸߳�������Ŀ��ͷ��ͻ����е�����
  TWorkthread = class(TThread)
  public
    Client: TCommClient;
    procedure execute; override;
  end;

var
  modelIntfClient: TCommClient;

implementation

uses windows, untfunctions, SysUtils, DXSock, modelASIOtest, untASIOSvr;



procedure TCommClient.DoCase;
var
  Lport: Integer;

  Ls: string;
begin
  if ReceiveLength >= 12 then begin
    LCmd := ReadBuffer(@LCmd, 4); ;
    try
  //    case LCmd of
       // 1: begin //��ʼ���
      ReadBuffer(@lport, 4); ;
      ReadBuffer(@lport, 4);
//      Lport := Readinteger;
//      Lport := Readinteger;
      isRcv := True;
      grcvTime := GetTickCount;
      SendMessage(ASIO_test.handle, 1026, Integer(self), Lport);
//            OnConnSuccess;
    //      end;

//      end;
    except
    end;
  end;
end;

procedure TCommClient.OnConnSuccess;
var
  i, ln: Integer;
begin
//  WriteInteger(length(USerID));
//  Write(USerID);
//  if isRcv then begin

  beginSend := GetTickCount;
  Writeinteger(1);
  Writeinteger(4);
  ln := 1 + Random(98);
  lsum := ln * 4;
  FillMemory(@lbuff[0], 4, ln);
  WriteBuff(lbuff[0], 4);
  isRcv := False;
 // SendMessage(ASIO_test.Handle, 1027, 0, lsum);
//  end;
end;

procedure TCommClient.OnCreate;
begin
  isRcv := True;
  Fupstate := false;
//  ReadThread := TWorkthread.Create(True);
//  ReadThread.Client := Self;
  UserKind := 1;
  GMemBuff := TMemoryStream.Create;
  FWaiteUpWarningLst := TStringList.Create;
  FUpEventLock := TCriticalSection.Create;
end;

{ TWorkthread }



procedure TWorkthread.execute;
begin
  while (Terminated = false) do begin
    try
      if Client.IsConning then begin
        Client.DoCase;
        Sleep(10);
      end
      else begin
        if Client.Connto(Client.FHost, Client.FPort) then
          Client.OnConnSuccess
        else Sleep(1000);
      end;
    except

    end;
  end;
end;

function TCommClient.DatasetToStream(iRecordset: TADOQuery; Stream:
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

procedure TCommClient.StartWork;
begin
  ReadThread.Resume;
end;

procedure TCommClient.Stop;
begin
  ReadThread.Terminate;
end;

procedure TCommClient.OnDestory;
begin
  FWaiteUpWarningLst.Free;
  FUpEventLock.Free;
end;

procedure TCommClient.RequestState(IWant: boolean);
begin
  try
    FUpEventLock.Acquire;
    Fupstate := IWant;
    if IWant then
      Self.WriteInteger(1000)
    else
      Self.WriteInteger(1001);
  finally
    FUpEventLock.Release;
  end;
end;

procedure TCommClient.UpTable(Ikind, Idata: integer);
begin
  try
    FUpEventLock.Acquire;
    WriteInteger(1002);
    WriteInteger(Ikind);
    WriteInteger(Idata);
  finally
    FUpEventLock.Release;
  end;
end;

procedure TCommClient.NowCheck(Iid: string);
begin
  try
    FUpEventLock.Acquire;
    WriteInteger(1003);
    WriteInteger(length(Iid));
    Write(Iid);
  finally
    FUpEventLock.Release;
  end;
end;

end.

