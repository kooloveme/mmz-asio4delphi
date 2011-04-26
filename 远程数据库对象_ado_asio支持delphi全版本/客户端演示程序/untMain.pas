unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UntRemSql, ComCtrls, ExtCtrls, StdCtrls, Grids, DBGrids, DB, adodb;

type
  Tfrm_main = class(TForm)
    pnl_head: TPanel;
    pgc_ctl: TPageControl;
    ts_one: TTabSheet;
    ds1: TDataSource;
    DBGrid1: TDBGrid;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    lbl_hint: TLabel;
    Button6: TButton;
    ts_two: TTabSheet;
    pnlower: TPanel;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    QryShower, Qryopt: TADOQuery;
  end;

var
  frm_main: Tfrm_main;
implementation

uses untfunctions;

{$R *.dfm}

procedure Tfrm_main.FormCreate(Sender: TObject);
begin
  //��ΪADO���� ������û���������ݿ�������ʹ�ã����Խ���һ���յ�access���ݿ�����
  Gob_DBMrg := TDBMrg.Create(TDBMrg.GetAccessConnStr(GetCurrPath + 'temp.mdb'));

  //�����ͻ��˶���  ���ӷ����9000�˿�
  Gob_Rmo := TRmoHelper.Create(9000);
  //����postʱ ͬʱ���id�ֶ�
  Gob_Rmo.FRmoClient.IsInserIDfield := True;
  //���ӷ���� Ϊ�˼���ʾ��Ϊ����  �����Ҫ����Զ�̻�����Ϊ����������IP ����
  if Gob_Rmo.ReConnSvr('127.0.0.1') = false then begin
    ErrorInfo('�������ݿ�������ʧ�ܣ����������������!');
    Application.Terminate;
  end;

  //��ȡһ��ADOQUERY
  Qryopt := Gob_DBMrg.GetAnQuery('Qryopt');
  //��ȡ����һ��adoquery ��Ϊ��dbgrid����
  QryShower := Gob_DBMrg.GetAnQuery('qry_show');
  ds1.DataSet := QryShower;

  Button5.Click;
end;

procedure Tfrm_main.Button5Click(Sender: TObject);
begin
  //��ѯԶ�����ݿ�ı� ����ʾ��dbgrid���
  Gob_Rmo.OpenTable('treeinfo', QryShower);

end;

procedure Tfrm_main.Button2Click(Sender: TObject);
var
  lid: Integer;
begin
  //������ݼ��ǿյ� �Ͳ�ѯһ��
  if QryShower.IsEmpty then
    Button5.Click;

  //��ȡ��һ����¼��ID
  QryShower.Append;
  QryShower.FieldByName('Caption').AsString := '������¼' + QryShower.FieldByName('id').AsString;
  QryShower.FieldByName('parentid').AsInteger := -1;
  QryShower.FieldByName('Flevel').AsInteger := 10;
  QryShower.FieldByName('kind').AsInteger := 1;
  QryShower.Post;
  TipInfo('������¼�ɹ�');


end;

procedure Tfrm_main.Button4Click(Sender: TObject);
begin
  QryShower.Delete;
  TipInfo('ɾ����¼�ɹ�');
end;

procedure Tfrm_main.Button1Click(Sender: TObject);
begin
  //ִ��һ�����
  Gob_Rmo.ExecAnSql('delete from treeinfo where id=%d', [QryShower.FieldByName('id').AsInteger]);
end;

procedure Tfrm_main.Button3Click(Sender: TObject);
begin
  //ִ��һ�����
  Gob_Rmo.OpenDataset(QryShower, 'select  * from treeinfo where id> 0', []);
  TipInfo('����ѯ��%d����¼', [QryShower.RecordCount]);
end;

procedure Tfrm_main.Button6Click(Sender: TObject);
begin
  //��������� ���Ի�úͱ������ݿ�һ�µĴ�����ʾ���Ա㷢������
  Gob_Rmo.OpenDataset(QryShower, 'select * from treeinfo where Fid> 0', []);
end;


end.

