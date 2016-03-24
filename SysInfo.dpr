program SysInfo;

uses
  Forms,
  unMain in 'unMain.pas' {FormMain},
  unSysInfo in 'unSysInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
