#define MyAppName "REDkit Config Restorer"
#define MyAppVersion "0.4"
#define MyAppPublisher "leviofanh"
#define MyAppURL "https://github.com/leviofanh/redkit_config_restorer"
#define MyAppExeName "REDkit_Config_Restorer.exe"
#define MyAppFolder "REDkitConfigRestorer"
#define MyServiceName "REDkitConfigRestorer"

[Setup]
AppId={{5A814AAA-D4FD-42C9-965B-FAC5F0C9785B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf}\{#MyAppFolder}
DisableDirPage=yes
InfoBeforeFile=desc.rtf
OutputBaseFilename=REDkit Config Restorer
SetupIconFile=10979021.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
Uninstallable=yes
CloseApplications=force
RestartApplications=no
CloseApplicationsFilter=*{#MyAppExeName}

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "REDkit_Config_Restorer.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "nssm.exe"; DestDir: "{app}"; Flags: ignoreversion

[Code]
var
  DirPage: TInputDirWizardPage;

function IsValidDirectory(Dir: string): Boolean;
begin
  Result := FileExists(Dir + '\bin\r4LavaEditor2.ini');
end;

procedure InitializeWizard;
begin
  DirPage := CreateInputDirPage(wpSelectDir,
    'Выберите папку REDkit',
    'Где установлен REDkit.',
    'Выберите папку, в которой установлен REDkit, затем нажмите Далее.',
    False, '');
  DirPage.Add('');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = DirPage.ID then
  begin
    if not IsValidDirectory(DirPage.Values[0]) then
    begin
      MsgBox('Неверный путь. Если путь верный, попробуйте запустить REDkit.', mbError, MB_OK);
      Result := False;
    end
    else
      Result := True;
  end
  else
    Result := True;
end;

procedure TerminateProcess(const FileName: string);
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /IM "' + FileName + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure RemoveOldInstallation;
var
  OldPath, OldExePath: string;
begin
  TerminateProcess('{#MyAppExeName}');

  OldPath := ExpandConstant('{localappdata}\{#MyAppFolder}');
  OldExePath := OldPath + '\{#MyAppExeName}';
  
  if FileExists(OldExePath) then
  begin
    DeleteFile(OldExePath);
  end;
  
  if FileExists(OldExePath) then
  begin
    if not DeleteFile(OldExePath) then
    begin
      if not DeleteFile(OldExePath) then
      begin
        MsgBox('Не удалось удалить файл ' + OldExePath + '. Пожалуйста, удалите его вручную после установки.', mbError, MB_OK);
      end;
    end;
  end;

  if DirExists(OldPath) then
  begin
    DelTree(OldPath, True, True, True);
  end;
  
  RegDeleteValue(HKEY_CURRENT_USER, 'Software\Microsoft\Windows\CurrentVersion\Run', '{#MyAppName}');
end;

procedure StopService;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\sc.exe'),
       'stop ' + ExpandConstant('"{#MyServiceName}"'),
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  Sleep(2000);
end;

procedure RemoveService;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\sc.exe'),
       'delete ' + ExpandConstant('"{#MyServiceName}"'),
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure InstallService;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{app}\nssm.exe'),
       'install ' + ExpandConstant('"{#MyServiceName}"') + ' ' + ExpandConstant('"{app}\{#MyAppExeName}"'),
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  Exec(ExpandConstant('{app}\nssm.exe'),
       'set ' + ExpandConstant('"{#MyServiceName}"') + ' Start SERVICE_AUTO_START',
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec(ExpandConstant('{app}\nssm.exe'),
       'set ' + ExpandConstant('"{#MyServiceName}"') + ' AppRestartDelay 10000',
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure StartService;
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\sc.exe'),
       'start ' + ExpandConstant('"{#MyServiceName}"'),
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigPath: string;
  ConfigFile: string;
begin
  if CurStep = ssInstall then
  begin
    StopService;
    RemoveService;
    RemoveOldInstallation;
  end;
  
  if CurStep = ssPostInstall then
  begin
    ConfigPath := ExpandConstant('{app}');
    ConfigFile := ConfigPath + '\config.ini';
    
    if not ForceDirectories(ConfigPath) then
      MsgBox('Не удалось создать папку для конфигурации', mbError, MB_OK)
    else if not SaveStringToFile(ConfigFile, DirPage.Values[0], False) then
      MsgBox('Не удалось сохранить конфигурационный файл', mbError, MB_OK);
    
    InstallService;
    StartService;
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

[UninstallRun]
Filename: "{sys}\sc.exe"; Parameters: "stop {#MyServiceName}"; Flags: runhidden
Filename: "{sys}\sc.exe"; Parameters: "delete {#MyServiceName}"; Flags: runhidden