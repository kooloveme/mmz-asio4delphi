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
  UntTIO, untFunctions, untCfger;

{$R *.dfm}

var
  Gio: TIOer; //��־���� ����ʾ�ͼ�¼��־��Ϣ

procedure Tfrm_main.FormCreate(Sender: TObject);
begin
  //������־����
  Gio := TIOer.Create(lvLog, GetCurrPath + 'log\');
//  Gio.Enabled:=false;
  //�������ݷ��������� ʹ��9000�˿�
  Gob_RmoDBsvr := TRmodbSvr.Create(9000, Gio);
  AssignCfgFile(GetCurrPath() + 'sys.ini');
end;

procedure Tfrm_main.FormDestroy(Sender: TObject);
begin
//�ǵ������н��л��ĺ�ϰ��
  Gob_RmoDBsvr.Free;
  Gio.Free;
end;

end.

