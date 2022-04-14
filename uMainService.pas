unit uMainService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type

  TMyThread = class(TThread)
  private
  public
    procedure Execute; override;
  end;

  TMainService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceBeforeInstall(Sender: TService);
    procedure ServiceBeforeUninstall(Sender: TService);
  private
    FMyThread: TMyThread;
    procedure GetServiceName;
    procedure GetServiceDisplayName;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  MainService: TMainService;

implementation

uses
  System.Win.Registry,
  uDebugViaServer;

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MainService.Controller(CtrlCode);
end;

function TMainService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TMainService.GetServiceDisplayName;
var
  ServiceDisplayName : String;
begin
  ServiceDisplayName := Trim(ParamStr(2));
  if ServiceDisplayName <> '' then
    DisplayName := ServiceDisplayName;
end;

procedure TMainService.GetServiceName;
var
  ServiceName : String;
begin
  ServiceName := Trim(ParamStr(2));
  if ServiceName <> '' then
   Name := ServiceName;
end;

procedure TMainService.ServiceAfterInstall(Sender: TService);
var
  Reg       : TRegistry;
  ImagePath : String;
begin
  Reg := TRegistry.Create(KEY_READ OR KEY_WRITE);
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('SYSTEM\CurrentControlSet\Services\'+Name, False) then
     begin
       // set service description
       Reg.WriteString('Description', 'Multi instance for service '+Name);
       // add name parameter to ImagePath value
       ImagePath := ParamStr(0) + ' /name '+Name;
       Reg.WriteString('ImagePath', ImagePath);
       Reg.CloseKey;
     end;
  finally
    Reg.Free;
  end;
end;

procedure TMainService.ServiceBeforeInstall(Sender: TService);
begin
  GetServiceName;
  GetServiceDisplayName;
end;

procedure TMainService.ServiceBeforeUninstall(Sender: TService);
begin
  GetServiceName;
end;

procedure TMainService.ServiceCreate(Sender: TObject);
begin
  if not Application.Installing then
    GetServiceName;
  FMyThread := nil;
end;

procedure TMainService.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
  if FMyThread = nil then
  begin
    FMyThread := TMyThread.Create;
    Started := True;
  end;
end;

procedure TMainService.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  if FMyThread <> nil then
  begin
    FMyThread.Terminate;
    while WaitForSingleObject(FMyThread.Handle, WaitHint-100) = WAIT_TIMEOUT do
      ReportStatus;
    FreeAndNil(FMyThread);
  end;
  Stopped := True;
end;


procedure TMyThread.Execute;
begin
  inherited;
  //Do Something
end;

initialization



end.
