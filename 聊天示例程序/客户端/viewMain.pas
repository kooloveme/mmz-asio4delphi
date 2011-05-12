unit viewMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  Tview_Main = class(TForm)
    Panel1: TPanel;
    Edit1: TEdit;
    btn1: TButton;
    Edit2: TEdit;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    mmo_show: TMemo;
    Panel6: TPanel;
    mmo_write: TMemo;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    tmr_rcv: TTimer;
    tmr_getlst: TTimer;
    procedure btn1Click(Sender: TObject);
    procedure tmr_rcvTimer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure tmr_getlstTimer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddShow(IConn: string);
  end;

var
  view_Main: Tview_Main;

implementation

uses
  untRmoDbClient, untfunctions, untASIOSvr;

{$R *.dfm}

procedure Tview_Main.AddShow(IConn: string);
begin
  IConn := StringReplace(IConn, '|', ':', [rfReplaceAll]);
  mmo_show.Lines.Add(FormatDateTime('hh:nn:ss', now) + ':' + iconn);
end;

procedure Tview_Main.btn1Click(Sender: TObject);
begin
  if Gob_RmoCtler = nil then begin
    Gob_RmoCtler := TchatClient.Create;
  end;
  if Gob_RmoCtler.ConnToSvr(Edit1.Text, 9951, Edit2.Text, Str_Encry('12345', 'cht')) = false then begin
    ShowMessage('��¼������ʧ�ܣ�');
    exit;
//    KillTask(ExtractFileName(ParamStr(0)));
  end
  else begin
    AddShow('���ӷ������ɹ������󷵻������û��б�');
    tmr_getlst.Enabled := true;
    tmr_rcv.Enabled := True;
    btn1.Enabled := false;
    Edit2.Enabled := False;
  end;
end;

procedure Tview_Main.tmr_rcvTimer(Sender: TObject);
var
  Lhead, llen: Integer;
  lls: string;
  Lspit: TStrings;
begin
  if (Gob_RmoCtler <> nil) and (Gob_RmoCtler.IsConning) then begin
    if Gob_RmoCtler.Socket.GetCanUseSize > 4 then begin
      Lhead := Gob_RmoCtler.Readinteger();
      if Lhead = 1 then begin
        llen := Gob_RmoCtler.Readinteger();
        lls := Gob_RmoCtler.ReadStr(llen);
        ListBox1.Items.CommaText := lls;
        llen := ListBox1.Items.IndexOf(Edit2.Text);
        Caption := Format('������ʾ�ͻ���-����%d', [ListBox1.Items.count]);
//        if llen > -1 then begin
//          ListBox1.Items.Delete(llen);
//        end;
      end
      else if Lhead = 2 then begin //������Ϣ  ˭����|����˭|ʲô����|
        llen := Gob_RmoCtler.Readinteger();
        lls := Gob_RmoCtler.ReadStr(llen);
        Lspit := TStringList.Create;
        try
          if lls <> '' then begin
            ExtractStrings(['|'], [' '], PansiChar(lls), lspit);
            if Lspit[0] <> Edit2.Text then
              AddShow(Format('%s����˵%s', [Lspit[0], Lspit[2]]));
          end;
        finally
          Lspit.Free;
        end;
      end
      else if Lhead = 3 then begin //�ļ�����

      end
      else if Lhead = 4 then begin //�û�������
        llen := Gob_RmoCtler.Readinteger();
        if llen = 1 then
          AddShow('�����û�����')
        else
          AddShow('���û�����');
        tmr_getlst.Enabled := True;
      end;
    end;
  end;
end;


var
  Lcrd: Cardinal;

procedure Tview_Main.Button2Click(Sender: TObject);
begin
  if GetTickCount - Lcrd > 100 then begin

  end
  else begin
  // AddShow('��Ҫ����̫����');
//    exit;
  end;
  Lcrd := GetTickCount;
  if ListBox1.ItemIndex = -1 then begin
    Gob_RmoCtler.SaySome('', mmo_write.Text);
    AddShow(Format('��Դ��˵:%s', [ListBox1.Items[ListBox1.itemindex], mmo_write.Text]));
  end
  else begin
    Gob_RmoCtler.SaySome(ListBox1.Items[ListBox1.itemindex], mmo_write.Text);
    AddShow(Format('���%s˵:%s', [ListBox1.Items[ListBox1.itemindex], mmo_write.Text]));
  end;
end;

procedure Tview_Main.tmr_getlstTimer(Sender: TObject);
begin
  tmr_getlst.Enabled := false;
  Gob_RmoCtler.Getonlineuser;
end;

procedure Tview_Main.Button3Click(Sender: TObject);
begin
  //��δʵ��
end;

procedure Tview_Main.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  Gob_RmoCtler.Free;
end;

end.

