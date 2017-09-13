(*
   ����  : PyThon���� DLL ȣ��
   �ۼ���: �ڼ���(adsloader@naver.com)
   �ۼ���: 2010.05.24
   ����  : ���̽� DLL ȣ�⿹��
   ����  : Delphi2010���� PChar�� WideString(wchar)�̴�.
*)
library PyDLLTest;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Dialogs,
  Classes,
  UiTest in 'UiTest.pas' {frmMain};

var
  f : TfrmMain;

{$R *.res}
type
  PyFunc = function(n : Integer; pData: PChar) : integer; stdcall;
  ParaData =  packed record
    func: PyFunc;
    desc: PChar;
  end;

function SetFunc( p : ParaData) :Integer ; stdcall;
begin

  f := TfrmMain.Create(Nil);
  f.pFunc := p.func;
  f.pFunc(1, 'start');

  result := 0;
end;

procedure AppendMessage( str : PChar; t: Integer); stdcall;
begin
  f.AppendMessage(str, t);
end;

procedure SetStatus( str : PChar); stdcall;
begin
  f.SetStatus(str);
end;

procedure DoEvent;
begin
  f.ShowModal();
end;

procedure CloseForm;
begin
  f.Close();
end;

exports
  SetFunc,
  AppendMessage,
  SetStatus,
  CloseForm,
  DoEvent;

begin
end.
