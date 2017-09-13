unit UiTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ImgList, Buttons;

type
  PyFunc = function(n : Integer; pData: PChar) : integer; stdcall;

  TfrmMain = class(TForm)
    Panel1: TPanel;
    lstMain: TListView;
    imgList: TImageList;
    stBar: TStatusBar;
    Image1: TImage;
    btnMake: TSpeedButton;
    btnClear: TSpeedButton;
    edtTag: TEdit;
    btnSetTag: TButton;
    procedure AppendMessage( str : PChar; t: Integer);
    procedure SetStatus( str : PChar);
    procedure btnMakeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CloseForm;
    procedure btnClearClick(Sender: TObject);
    procedure btnSetTagClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    pFunc : PyFunc;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.AppendMessage( str : PChar; t: Integer);
begin

  with lstMain.Items.Add do begin
    Caption    := IntToStr(lstMain.Items.Count);
    ImageIndex := t;
    SubItems.Add(str);

  end;


end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  lstMain.Items.Clear;
end;

procedure TfrmMain.btnMakeClick(Sender: TObject);
begin
  pFunc(2, 'backup');
end;

procedure TfrmMain.btnSetTagClick(Sender: TObject);
begin
    pFunc(4, PChar( edtTag.Text ) );
end;

procedure TfrmMain.FormActivate(Sender: TObject);
begin
  SetStatus('디버깅 대기 중입니다. 단말기를 연결해 주십시오');
end;

procedure TfrmMain.SetStatus( str : PChar);
begin
  stBar.Panels[1].Text := str;

end;

procedure TfrmMain.CloseForm;
begin
  frmMain.Close;
end;


end.
