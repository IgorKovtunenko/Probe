unit unMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, ExtCtrls,IniFiles;

type
  TFormMain = class(TForm)
    IdHTTP: TIdHTTP;
    Panel1: TPanel;
    Memo: TMemo;
    Splitter1: TSplitter;
    Panel2: TPanel;
    btCollect: TButton;
    btSend: TButton;
    btExit: TButton;
    procedure btCollectClick(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure btExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    httplink,AppName,UserName:string;
  end;

var
  FormMain: TFormMain;

implementation

uses unSysInfo,IdMultipartFormData;

{$R *.dfm}

procedure TFormMain.btCollectClick(Sender: TObject);
var WinVersion:Longint;
    f:TIniFile;
begin
 f:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'SysInfo.ini');
 AppName:=f.ReadString('SysInfo','AppName','');
 HttpLink:=f.ReadString('SysInfo','HttpLink','');
 UserName:=f.ReadString('SysInfo','UserId','');
 f.Free;
 Memo.Lines.Add('------------OS parameters----------------------');
 Memo.Lines.Add(GetWindowsVersion);
 Memo.Lines.Add(GetModeCapacity);
 Memo.Lines.Add('File system - '+GetHardDiskPartitionType('C'));
 Memo.Lines.Add('------------Hardware parameters----------------');
 GetProcType(Memo.Lines);
 Memo.Lines.Add('------------Memory parameters------------------');
 GetMemoryStatus(Memo.Lines);
end;

procedure TFormMain.btExitClick(Sender: TObject);
begin
 Close;
end;

procedure TFormMain.btSendClick(Sender: TObject);
 var data:TIdMultiPartFormDataStream;
     bmp:TBitmap;
begin
 if MessageDlg('This option will send your system information to the program vendor.'+#13
 +'Are you shure ?',mtConfirmation,[mbYes,mbNo],0)<>mrYes then exit;
 bmp:=DoScreenShot(AppName);
 data:=TIdMultiPartFormDataStream.Create;
 data.addFormField('User ID',UserName);
 data.addFormField('Application',AppName);
 data.addFormField('System Data',Memo.Lines.Text);
 if Assigned(bmp) then
  begin
   bmp.SaveToFile('C:\Shot.bmp');
   data.AddFile('ScreenShot','c:\shot.bmp','');
   deleteFile('C:\shot.bmp');
   bmp.Free;
  end;
 IdHttp.Post(HttpLink,Data);
 data.free;
end;

end.
