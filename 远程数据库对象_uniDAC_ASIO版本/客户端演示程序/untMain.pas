unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UntRemSql, ComCtrls, ExtCtrls, StdCtrls, Grids, DBGrids, DB, dbclient,midaslib;

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
    btn1: TButton;
    btn2: TButton;
    ts_sub: TTabSheet;
    ds_master: TDataSource;
    ds_slave: TDataSource;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    Label1: TLabel;
    Button7: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure pgc_ctlChange(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    QryShower, Qryopt, QryMaster, QrySlave: TClientDataSet;
  end;

var
  frm_main: Tfrm_main;
implementation

uses untfunctions, ViewGraph, PMyBaseDebug;

{$R *.dfm}

procedure Tfrm_main.FormCreate(Sender: TObject);
begin

  Gob_DBMrg := TDBMrg.Create();
  //�����ͻ��˶���  ���ӷ����9000�˿�
  Gob_Rmo := TRmoHelper.Create(9000);
  //���ӷ���� Ϊ�˼���ʾ��Ϊ����  �����Ҫ����Զ�̻�����Ϊ����������IP ����
  //��½ʱ��Ҫ�����û��������� ����������ļ�sys.ini�������á�
  if Gob_Rmo.ReConnSvr('127.0.0.1', -1, 'client', '456') = false then begin
    ErrorInfo('�������ݿ�������ʧ�ܣ����������������!');
    Application.Terminate;
  end;
  //��ȡһ��
  Qryopt := Gob_DBMrg.GetAnQuery('Qryopt');
  //��ȡ����һ�����ݼ� ��Ϊ��dbgrid����
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
  TipInfo('������¼�ɹ��¼�¼ID��<%d>', [QryShower.FieldByName('id').AsInteger]);
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


procedure Tfrm_main.FormShow(Sender: TObject);
var
  Litem: TInfoMap;
begin
  Litem := TInfoMap.Create;
  Litem.id := '1';
  Litem.Cpt := '�ϷŽڵ�1';
  ListBox1.Clear;
  ListBox1.Items.AddObject(Litem.Cpt, Litem);


  Litem := TInfoMap.Create;
  Litem.id := '2';
  Litem.Cpt := '�ϷŽڵ�2';
  ListBox1.Items.AddObject(Litem.Cpt, Litem);




  View_Graph := TView_Graph.Create(Application);
  View_Graph.Parent := pnlower;
  View_Graph.Show;
  ListBox1.OnClick := View_Graph.OnModelTreeClick;

end;

procedure Tfrm_main.btn1Click(Sender: TObject);
var
  i: Integer;
  lst: TStringList;

begin
  //����һ
  Gob_Rmo.AddBathExecSql('insert into treeinfo(caption) values(''%s'')', ['��������1']);
  Gob_Rmo.AddBathExecSql('insert into treeinfo(caption) values(''%s'')', ['��������2']);
  Gob_Rmo.AddBathExecSql('insert into treeinfo(caption) values(''��������3'')');
  Gob_Rmo.BathExec; //��һ��������ύ��������ִ��

  //����2
  lst := TStringList.Create;
  lst.Add(format('insert into treeinfo(caption) values(''%s'')', ['��������1']));
  lst.Add(format('insert into treeinfo(caption) values(''%s'')', ['��������2']));
  lst.Add('insert into treeinfo(caption) values(''��������3'')');
  Gob_Rmo.BathExecSqls(lst); //��һ��������ύ��������ִ��
  lst.Free;


end;

procedure Tfrm_main.btn2Click(Sender: TObject);
var
  i: Integer;
  lst: TStringList;
begin
 //ִ���Զ�����������1000����¼
//  Gob_Debug.StartLogTime;
//  for i := 0 to 1000 - 1 do begin // Iterate
//    QryShower.Insert;
//    QryShower.FieldByName('caption').AsString := format('��������%d', [i + 1]);
//    QryShower.Post;
//  end; // for
//  Gob_Debug.ShowVar(Format('Post��ʽ����������1000����¼��ʹ����%d��', [Gob_Debug.EndLogTIme div 1000]));

  //ִ�в���1000����¼
  Gob_Debug.StartLogTime;
  for i := 0 to 1000 - 1 do begin // Iterate
    Gob_Rmo.AddBathExecSql('insert into treeinfo(caption) values(''����������%d'')', [i + 1]);
  end; // for
  Gob_Rmo.BathExec; //��һ��������ύ��������ִ��
  Gob_Debug.ShowVar(Format('��������1000����¼��ʹ����%d��', [Gob_Debug.EndLogTIme div 1000]));
end;

procedure Tfrm_main.pgc_ctlChange(Sender: TObject);
begin
  if pgc_ctl.ActivePageIndex = 2 then begin
    if QryMaster = nil then begin
      QryMaster := Gob_DBMrg.GetAnQuery('QryMaster');
      ds_master.DataSet := QryMaster;
      QrySlave := Gob_DBMrg.GetAnQuery('QrySlave');
      ds_slave.DataSet := QrySlave;
      QrySlave.MasterSource := ds_master;
      QrySlave.MasterFields := 'id';
      QrySlave.IndexFieldNames := 'fpid'
    end;
    Gob_Rmo.OpenTable('Tmaster', QryMaster);
    Gob_Rmo.OpenDataset(QrySlave, 'select * from Tslave');
  end;
end;

procedure Tfrm_main.Button7Click(Sender: TObject);
begin
  Gob_Rmo.FRmoClient.CheckUpdate;
end;

end.

