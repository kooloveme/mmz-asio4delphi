unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UntRmodbSvr, ImgList, ComCtrls;

type
  Tfrm_main = class(TForm)
    lvLog: TListView;
    ImageListLogLevel: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_main: Tfrm_main;

implementation
uses
  UntTIO, untFunctions;

{$R *.dfm}

var
  Gio: TIOer; //��־���� ����ʾ�ͼ�¼��־��Ϣ

procedure Tfrm_main.FormCreate(Sender: TObject);
begin
  //������־����
  Gio := TIOer.Create(lvLog, GetCurrPath + 'log\');
  //�������ݷ��������� ʹ��9000�˿�
  Gob_RmoDBsvr := TRmodbSvr.Create(9000, Gio);

   //�˴�����exeĿ¼�µ�access���ݿ��ļ� demo.mdb
   //��Ȼ������������һ�����ݿ�
  if Gob_RmoDBsvr.ConnToDb(TDBMrg.GetAccessConnStr(GetCurrPath() + 'demo.mdb')) then
    Gio.AddShow('���ӱ������ݿ�ɹ��������ṩԶ�����ݷ�����!');


// TDBMrg���кܷ�����෽�� �����ṩ���ɲ�ͬ���ݿ�������ַ���Ŷ
//    {��ȡACCESS�����ַ���}
//    class function GetAccessConnStr(IDataSource: string; Ipsd: string = ''): string;
//    {��ȡMSSQL�����ַ���}
//    class function GetMsSQLConnStr(IDataSource, IAcc, Ipsd, IDataBase: string): string;
//    {��ȡOracle�����ַ���}
//    class function GetOracleConnStr(IDataSource, IAcc, Ipsd: string): string;
//    {��ȡExcel�����ַ���}
//    class function GetExcelConnStr(IFileName: string): string;
//    {��ȡText�����ַ���}
//    class function GetTextConnStr(IDBPath: string): string;
//    {��ȡDbf�����ַ���}
//    class function GetDBFConnStr(IDBPath: string): string;
//    {��ȡMySQl�����ַ���}
//    class function GetMySqlConnStr(IDataSource, IDbName, IAcc, Ipsd: string): string;
end;

procedure Tfrm_main.FormDestroy(Sender: TObject);
begin
//�ǵ������н��л��ĺ�ϰ��
  Gob_RmoDBsvr.Free;
  Gio.Free;
end;

end.

