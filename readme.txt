{*******************************************************************************
        ��Ԫ���ƣ�untASIOSvr.pas
        �������ڣ�2011-04-07 17:26:15
        ������	  ������
        ����:     ASIO ��ɶ˿ڷ�����ͨ�÷�װ
        ��ǰ�汾��v1.1.0
        ��ʷ��
        v1.0.0 2011-04-07
                  ��������Ԫ����ASIO���и�Ч�ʵķ�װ��
                  ͬʱ��װ��Ч�����ݴ���ģ��
        v1.0.1 2011-04-20
                  �����˿ͻ����˳�ʱ��ʱ���쳣��BUG
                  ��������ȷ�� �ڿͻ��˷��ʹ�����ʱ�����ֶ���Ƭ����
                  �޸�write���̵ķ���ʵ��
        v1.0.2 2011-04-25
                  �����������ͻ��˵����쳣����Ӱ���������ӵ�BUG��
                  ������������һ�����Ӳ��������BUG
        v1.0.2a 2011-05-07
                  ����TASIOCLIENT�� readinteger������һ��bug��
                  ��лȺ��FlashDance������BUG : )
                  ����������˳�ʱ���쳣���޸�ͨ��killtask�������̵ķ�ʽ
                  �����������ͻ��˳�ʱ�䲻�����ݳ�ʱ���µ��쳣
                  �����ͻ����û�������ʱ����ε�¼���·�����쳣
                  ��лȺ��С�ĵĲ��Ժ����ⷴ��

          v1.1.0 2011-05-16
                  ��������첽Ͷ�ݿ��ܵ��µ��������򣨶���ļ�ͬʱ���أ�������������⣩
                  �Ż��ײ�����Ч��
********************************************************************************}

Ŀ¼�ṹ����

mmz-asio4delphi\���ܲ��Գ���   
      asio��װ�����ܲ��Գ��򣬰�������˺Ϳͻ����Լ����Դ��

mmz-asio4delphi\����ʾ������  
      һ���򵥵�����ʾ�����򣬵ײ�ʹ��mmz-asio4delphiʵ��
			
mmz-asio4delphi\�ļ�����ʾ������  
      һ���򵥵��ļ�����ʾ�����򣬻�������ʾ�����ײ�ʹ��mmz-asio4delphiʵ��

     
mmz-asio4delphi\AsioDLL  
      asio��c++��̬���װԴ�룬����vs2005��vs2003����Ŀ�ļ�

mmz-asio4delphi\untAsioSvr  
      mmz-asio4delphi��Դ�룬������asio�ĸ�Ч�ʷ�װ
      �ṩtcp������Լ��ͻ��˽ӿ�
  
mmz-asio4delphi\Զ�����ݿ����_ado_asio֧��delphiȫ�汾   
      UnidacԶ�̶�������°汾���ײ�ʹ��mmz-asio4delphiʵ��

mmz-asio4delphi\Զ�����ݿ����_uniDAC_ASIO�汾    
      AdoԶ�̶�������°汾���ײ�ʹ��mmz-asio4delphiʵ��
			
			
			
ʵ��˵����

TAsioSvr ��������ķ���˶��� 
TBaseSocketServer �Ǹ��ϲ��װ����Ҫ������һЩ�������� �����շ����ļ��շ��Ƚӿ�
TCenterServer �Ǹ��ϲ��װ��ģ�⴦���û���¼ Ȩ�޼�� �¼����� �Լ��Ͽ�����
TRmodbSvr  ����Ӧ�ò���

���Ҫ�Լ�����TCP����� ����ѡ�������һ�����̳� 

�ͻ��˶���������� 
TAsioClient  �ǻ����Ŀͻ��˶���
TSocketClient �Ǹ��ϲ��װ����Ҫ������һЩ�������� �����շ����ļ��շ��Ƚӿڣ�
TRmoClient  ����Ӧ�ò����Զ����� ��������Ҳ������һ��

----------------------------------------------------------------------------------------��˵�еĳ��(22900104)  15:18:44
Э��ͺܼ򵥰�   ͷ��4�ֽڣ�|���ȣ�4�ֽڣ�|���壨��������
��˵�еĳ��(22900104)  15:19:12
��ASIO�����ȡ��ʱ�� ����ȡ8���ֽڣ�Ȼ����ȡ����
���¿�ʼ(704121401)  15:19:29
 ����ʲô��ͷ����ɶ��˼�����Լ����壿
��˵�еĳ��(22900104)  15:19:34
���������ҵ��Э��
��˵�еĳ��(22900104)  15:20:10
���Э������ ASIO������õģ� �����ҵ��Э�� �ڰ����ڶ���
��˵�еĳ��(22900104)  15:20:48
Ҳ���ǿͻ��� �����κ�һ�����ݰ� ��������ͷ�ͳ���
��˵�еĳ��(22900104)  15:21:17
 SendAsioHead(8 + llen);
��˵�еĳ��(22900104)  15:21:33
���Կͻ��˺���ǰ��ȶ����������
��˵�еĳ��(22900104)  15:21:38
������û��
��ˮ����(369859772)  15:22:09
ÿ�η���֮ǰ�Ȱ����ݳ��ȼ�8����ȥ��
��˵�еĳ��(22900104)  15:22:33
�Ǹ�8Ҳ�ǰ���� ����
��˵�еĳ��(22900104)  15:22:42
var
  llen, i: Integer;
  ls: string;
  Lend: integer;
  Litem: TSelectitems;
begin
  inc(Fsn);
  Lend := 0;
  ls := ISql;
  llen := length(isql);
  SendAsioHead(8 + llen);
��˵�еĳ��(22900104)  15:22:51
var
  llen, i: Integer;
  ls: string;
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
��˵�еĳ��(22900104)  15:23:04
8 ��   WriteInteger(2);   WriteInteger(llen);  ��2��
��ˮ����(369859772)  15:23:32
������
��˵�еĳ��(22900104)  15:23:41
  ����һ��Э�� 
��˵�еĳ��(22900104)  15:23:49
����˵Ĵ����֮ǰ��ȫһ��
��ˮ����(369859772)  15:24:14
�š�������ҿ�������ûʲô�仯
��˵�еĳ��(22900104)  15:24:49
�����ֱ�ӷ�װ TAsioSvr  �����Э�����ʡ��
��˵�еĳ��(22900104)  15:26:09
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
            
��˵�еĳ��(22900104)  15:26:39
�����֮���Բ��� ����ΪЭ���װ�������� TCenterServer�����
��ˮ����(369859772)  15:26:41
 

�ǲ���asioDataBufferһ���Զ�ȡ�ľͰ������淢���İ�ͷ�����峤�ȺͰ�������
��������dxsockÿһ��write��Ӧһ��read?
��˵�еĳ��(22900104)  15:27:21
���ǵ�  asioֻҪ���յ����ݾͻ� ֪ͨ�ϲ�Ӧ�ã� ���ڰ�ͷ����ȴ��� ����Ӧ�ò��������
��˵�еĳ��(22900104)  15:27:57
Ҳ����ճ�� �����ղ������ݵȵ����� ������������ģ� 
��˵�еĳ��(22900104)  15:28:08
����Ӧ�ò��ʱ�� �Ѿ��ǽ��յ�����������
��˵�еĳ��(22900104)  15:28:12
�ͻ���Ҳһ��
��˵�еĳ��(22900104)  15:29:57
��ͷ|����|���� ������Э�����֧���κδ�������
��˵�еĳ��(22900104)  15:30:13
���������Ƚ����
��˵�еĳ��(22900104)  15:32:00
�����ϲ�������Ĵ���ʽ Ҳ�ǿ��Դ� TAsioSvr ֱ�Ӽ̳� ʵ���Լ���Э�鴦��
��˵�еĳ��(22900104)  15:33:57
TAsioSvr ��������ķ���˶��� 
TBaseSocketServer �Ǹ��ϲ��װ����Ҫ������һЩ�������� �����շ����ļ��շ��Ƚӿ�
TCenterServer �Ǹ��ϲ��װ��ģ�⴦���û���¼ Ȩ�޼�� �¼����� �Լ��Ͽ�����
TRmodbSvr  ����Ӧ�ò���
��˵�еĳ��(22900104)  15:34:36
���Ҫ�Լ�����TCP����� ����ѡ�������һ�����̳� 
��˵�еĳ��(22900104)  15:36:12
�ͻ��˶���������� 
TAsioClient  �ǻ����Ŀͻ��˶���
TSocketClient �Ǹ��ϲ��װ����Ҫ������һЩ�������� �����շ����ļ��շ��Ƚӿڣ��Զ����� ��������Ҳ������һ��
TRmoClient  ����Ӧ�ò���

��˵�еĳ��(22900104)  15:36:51
Ŷ������˼ �Զ����� ���������� TRmoClient Ӧ�ò�ʵ�ֵ�

��˵�еĳ��(22900104)  15:39:15
TAsioClient�����
{������ʽ��������}
    function Writeinteger(Iint: Integer; ITrans: boolean = true): Integer;
    function Write(Ibuffer: Pointer; Ilen: Integer): Integer; overload;
    function Write(Istr: AnsiString): Integer; overload;


    function WriteString(Istr: AnsiString): Integer;
    {������ʽ��������}
    function Readinteger(Itrans: Boolean = true): integer;
    function ReadBuffer(Ibuffer: Pointer; Ilen: Integer): integer;
    function ReadStr(Ilen: Integer): AnsiString;
����Ϊ�ͻ����õ�

��˵�еĳ��(22900104)  15:39:18
    Socket: TAsioDataBuffer; //Ϊ�����ϳ��������� ����RcvDataBuffer�����ָ��
    RcvDataBuffer: TAsioDataBuffer; //����buffer
��˵�еĳ��(22900104)  15:39:38
��TAsioDataBuffer ����Ϊ�ڷ���˵����ӵĶ���ʱ���õġ�
��˵�еĳ��(22900104)  15:39:50
// ��Щ�������Ƿ����ʱ�õ�  2011-04-14 15:28:27   ������
    function ReadInteger(IrcvGob: Boolean = false; ITrans: Boolean = True): Integer;
    function ReadStr(Ilen: integer; IrcvGob: Boolean = false): AnsiString;
    function ReadBuff(Ibuffer: Pointer; Ilen: integer; IrcvGob: Boolean = false):
      Integer;
    procedure Writeinteger(Iin: Integer; Ihtn: boolean = true);
    procedure Write(IBuffer: Pointer; Ilen: Integer); overload;
    procedure Write(IStr: AnsiString); overload;
    {�Ͽ�����}
    procedure Disconnect;
//------------------------------------------------------------------------------
��˵�еĳ��(22900104)  15:40:18
��Ϊ�ͻ��� �ͷ���� ��ż������TAsioClient ����
��˵�еĳ��(22900104)  15:40:26
��Ϊ�ͻ��� �ͷ���� ��������TAsioClient ����
��˵�еĳ��(22900104)  15:42:36
���仰˵ Ҳ���� ��Ϊtcp�ͻ��������ֱ�Ӵ���TAsioClient ����Ҫ�շ�����Ҳ��ֱ�ӵ���TAsioClient �µ�readxxx����writexxx������
����tcp����ˣ�ÿ������Ҳ��TAsioClient���� �շ����ݾ�Ҫ����
TAsioClient.Socket.writexxx��readxxx 
��˵�еĳ��(22900104)  15:42:51
����������𣺣� 
��˵�еĳ��(22900104)  15:44:58
����˵���� �Ǻ� �����ʻ�ӭ����
