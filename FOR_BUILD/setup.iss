#define MyAppName "REDkit Config Restorer"
#define MyAppVersion "0.2"
#define MyAppPublisher "leviofanh"
#define MyAppURL "https://github.com/leviofanh/redkit_config_restorer"
#define MyAppExeName "REDkit_Config_Restorer.exe"
#define MyAppFolder "REDkitConfigRestorer"

[Setup]
AppId={{5A814AAA-D4FD-42C9-965B-FAC5F0C9785B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\{#MyAppFolder}
DisableDirPage=yes
InfoBeforeFile=desc.rtf
OutputBaseFilename=REDkit Config Restorer
SetupIconFile=10979021.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
Uninstallable=no
CloseApplications=force
RestartApplications=no
CloseApplicationsFilter={#MyAppExeName}

[Languages]
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "REDkit_Config_Restorer.exe"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "REDkit Config Restorer"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue

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

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigPath: string;
  ConfigFile: string;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigPath := ExpandConstant('{app}');
    ConfigFile := ConfigPath + '\config.ini';
    
    if not ForceDirectories(ConfigPath) then
      MsgBox('Не удалось создать папку для конфигурации', mbError, MB_OK)
    else if not SaveStringToFile(ConfigFile, DirPage.Values[0], False) then
      MsgBox('Не удалось сохранить конфигурационный файл', mbError, MB_OK)
  end;
end;

function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
  Uninstaller: String;
  PrevPath: String;
begin
  Result := True;

  if RegQueryStringValue(HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1',
    'UninstallString', Uninstaller) then
  begin
    RegQueryStringValue(HKEY_CURRENT_USER,
      'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1',
      'InstallLocation', PrevPath);
    
    DelTree(PrevPath, True, True, True);
    
    Result := True;
  end;
end;

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Запустить {#MyAppName}"; Flags: nowait postinstall skipifsilent