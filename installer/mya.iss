; MYA — installateur Windows (Inno Setup 6)
; Recommandé : powershell -ExecutionPolicy Bypass -File .\scripts\build-installer.ps1 -BumpBuild

#ifndef MyAppVersion
#define MyAppVersion "1.0.0"
#endif
#ifndef MyAppBuild
#define MyAppBuild "1"
#endif

#define MyAppName "MYA"
#define MyAppPublisher "MYA"
#define MyAppExeName "mya.exe"
#define MyAppVersionFull MyAppVersion + "." + MyAppBuild
#define BuildDir "..\build\windows\x64\runner\Release"
; Inno enregistre la clé avec les accolades autour du GUID.
#define UninstallRegKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\{{A8C22B55-049E-422F-B30F-863694DE08C8}_is1"
; D1 avait accidentellement ajouté une accolade finale à l'AppId.
; Cette clé permet de reconnaître et migrer les installations 1.0.1 concernées.
#define LegacyMalformedUninstallRegKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\{{A8C22B55-049E-422F-B30F-863694DE08C8}}_is1"

#define OutputName "MYA-Setup-" + MyAppVersion
#if MyAppBuild != "1"
#define OutputName OutputName + "-build" + MyAppBuild
#endif

[Setup]
AppId={{A8C22B55-049E-422F-B30F-863694DE08C8}
AppName={#MyAppName}
AppVersion={#MyAppVersionFull}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={code:GetDefaultInstallDir}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DisableDirPage=auto
UsePreviousAppDir=yes
UsePreviousGroup=yes
CloseApplications=force
OutputDir=..\dist
OutputBaseFilename={#OutputName}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
VersionInfoVersion={#MyAppVersionFull}

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "Créer une icône sur le bureau"; GroupDescription: "Raccourcis :"; Check: IsFreshInstall
Name: "startup"; Description: "Lancer MYA au démarrage de Windows"; GroupDescription: "Options :"; Flags: checkedonce; Check: IsFreshInstall
Name: "cloudsync"; Description: "Préparer la synchronisation cloud (bientôt disponible)"; GroupDescription: "Options :"; Flags: unchecked; Check: IsFreshInstall

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "Icon01.bmp"; Flags: dontcopy
Source: "Icon02.bmp"; Flags: dontcopy
Source: "Icon03.bmp"; Flags: dontcopy

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer MYA"; Flags: nowait postinstall skipifsilent

[Registry]
; Supprime uniquement l'entrée de désinstallation du build D1 dont l'AppId
; contenait une accolade en trop. La nouvelle entrée canonique est recréée
; par Inno Setup et les données utilisateur restent hors de {app}.
Root: HKCU; Subkey: "{#LegacyMalformedUninstallRegKey}"; Flags: deletekey; Check: IsUpgradeInstall

[Code]
var
  FreshInstall: Boolean;
  InstalledVersion: String;
  InstalledDirectory: String;
  IconPage: TWizardPage;
  IconRadioButton1: TRadioButton;
  IconRadioButton2: TRadioButton;
  IconRadioButton3: TRadioButton;
  IconImage1: TBitmapImage;
  IconImage2: TBitmapImage;
  IconImage3: TBitmapImage;

function ReadExistingInstall(
  RootKey: Integer;
  SubKey: String;
  var Version: String;
  var InstallDirectory: String
): Boolean;
var
  UninstallCommand: String;
begin
  Result :=
    RegQueryStringValue(RootKey, SubKey, 'InstallLocation', InstallDirectory) or
    RegQueryStringValue(RootKey, SubKey, 'UninstallString', UninstallCommand);

  if Result and
     (not RegQueryStringValue(RootKey, SubKey, 'DisplayVersion', Version)) then
  begin
    if not RegQueryStringValue(RootKey, SubKey, 'DisplayName', Version) then
      Version := 'version existante';
  end;
end;

function GetInstalledVersion(
  var Version: String;
  var InstallDirectory: String
): Boolean;
begin
  Result :=
    ReadExistingInstall(HKCU, '{#UninstallRegKey}', Version, InstallDirectory) or
    ReadExistingInstall(HKCU, '{#LegacyMalformedUninstallRegKey}', Version, InstallDirectory) or
    ReadExistingInstall(HKLM, '{#UninstallRegKey}', Version, InstallDirectory) or
    ReadExistingInstall(HKLM, '{#LegacyMalformedUninstallRegKey}', Version, InstallDirectory);
end;

function GetDefaultInstallDir(Param: String): String;
begin
  if (not FreshInstall) and (InstalledDirectory <> '') then
    Result := RemoveBackslashUnlessRoot(InstalledDirectory)
  else
    Result := ExpandConstant('{autopf}\{#MyAppName}');
end;

function IsFreshInstall: Boolean;
begin
  Result := FreshInstall;
end;

function IsUpgradeInstall: Boolean;
begin
  Result := not FreshInstall;
end;

procedure WriteInstallOptions();
var
  OptionsPath: String;
  JsonContent: String;
  StartupEnabled: String;
  CloudSync: String;
  BubbleIcon: String;
begin
  if WizardIsTaskSelected('startup') then
    StartupEnabled := 'true'
  else
    StartupEnabled := 'false';

  if WizardIsTaskSelected('cloudsync') then
    CloudSync := 'true'
  else
    CloudSync := 'false';

  if IconRadioButton2.Checked then
    BubbleIcon := 'icon02'
  else if IconRadioButton3.Checked then
    BubbleIcon := 'icon03'
  else
    BubbleIcon := 'icon01';

  OptionsPath := ExpandConstant('{localappdata}\MYA');
  if not DirExists(OptionsPath) then
    ForceDirectories(OptionsPath);

  OptionsPath := OptionsPath + '\install_options.json';
  JsonContent := '{' + #13#10 +
    '  "startup_enabled": ' + StartupEnabled + ',' + #13#10 +
    '  "prefer_cloud_sync": ' + CloudSync + ',' + #13#10 +
    '  "bubble_icon": "' + BubbleIcon + '"' + #13#10 +
    '}';

  SaveStringToFile(OptionsPath, JsonContent, False);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssPostInstall) and FreshInstall then
    WriteInstallOptions();
end;

procedure CreateIconSelectionPage();
var
  Panel1, Panel2, Panel3: TPanel;
  IconPath1, IconPath2, IconPath3: String;
begin
  IconPage := CreateCustomPage(wpSelectTasks, 'Choix de l''icône de la pastille', 'Sélectionnez le style d''icône pour la pastille MYA.');

  ExtractTemporaryFile('Icon01.bmp');
  ExtractTemporaryFile('Icon02.bmp');
  ExtractTemporaryFile('Icon03.bmp');
  IconPath1 := ExpandConstant('{tmp}\Icon01.bmp');
  IconPath2 := ExpandConstant('{tmp}\Icon02.bmp');
  IconPath3 := ExpandConstant('{tmp}\Icon03.bmp');

  // Option 1 : Icon01 (Style 1 - Défaut)
  Panel1 := TPanel.Create(IconPage);
  Panel1.Parent := IconPage.Surface;
  Panel1.Left := 10;
  Panel1.Top := 10;
  Panel1.Width := 130;
  Panel1.Height := 160;
  Panel1.BevelOuter := bvLowered;

  IconRadioButton1 := TRadioButton.Create(IconPage);
  IconRadioButton1.Parent := IconPage.Surface;
  IconRadioButton1.Left := Panel1.Left + 10;
  IconRadioButton1.Top := Panel1.Top + 10;
  IconRadioButton1.Width := 110;
  IconRadioButton1.Caption := 'Style 1 (Défaut)';
  IconRadioButton1.Checked := True;

  IconImage1 := TBitmapImage.Create(IconPage);
  IconImage1.Parent := Panel1;
  IconImage1.Left := 25;
  IconImage1.Top := 40;
  IconImage1.Width := 80;
  IconImage1.Height := 80;
  IconImage1.Stretch := True;
  if FileExists(IconPath1) then
    IconImage1.Bitmap.LoadFromFile(IconPath1);

  // Option 2 : Icon02 (Style 2)
  Panel2 := TPanel.Create(IconPage);
  Panel2.Parent := IconPage.Surface;
  Panel2.Left := 155;
  Panel2.Top := 10;
  Panel2.Width := 130;
  Panel2.Height := 160;
  Panel2.BevelOuter := bvLowered;

  IconRadioButton2 := TRadioButton.Create(IconPage);
  IconRadioButton2.Parent := IconPage.Surface;
  IconRadioButton2.Left := Panel2.Left + 10;
  IconRadioButton2.Top := Panel2.Top + 10;
  IconRadioButton2.Width := 110;
  IconRadioButton2.Caption := 'Style 2';

  IconImage2 := TBitmapImage.Create(IconPage);
  IconImage2.Parent := Panel2;
  IconImage2.Left := 25;
  IconImage2.Top := 40;
  IconImage2.Width := 80;
  IconImage2.Height := 80;
  IconImage2.Stretch := True;
  if FileExists(IconPath2) then
    IconImage2.Bitmap.LoadFromFile(IconPath2);

  // Option 3 : Icon03 (Style 3)
  Panel3 := TPanel.Create(IconPage);
  Panel3.Parent := IconPage.Surface;
  Panel3.Left := 300;
  Panel3.Top := 10;
  Panel3.Width := 130;
  Panel3.Height := 160;
  Panel3.BevelOuter := bvLowered;

  IconRadioButton3 := TRadioButton.Create(IconPage);
  IconRadioButton3.Parent := IconPage.Surface;
  IconRadioButton3.Left := Panel3.Left + 10;
  IconRadioButton3.Top := Panel3.Top + 10;
  IconRadioButton3.Width := 110;
  IconRadioButton3.Caption := 'Style 3';

  IconImage3 := TBitmapImage.Create(IconPage);
  IconImage3.Parent := Panel3;
  IconImage3.Left := 25;
  IconImage3.Top := 40;
  IconImage3.Width := 80;
  IconImage3.Height := 80;
  IconImage3.Stretch := True;
  if FileExists(IconPath3) then
    IconImage3.Bitmap.LoadFromFile(IconPath3);
end;

procedure InitializeWizard();
begin
  if IsFreshInstall then
    CreateIconSelectionPage();

  if not IsUpgradeInstall then
    Exit;

  WizardForm.Caption := '{#MyAppName} — Mise à jour';
  WizardForm.WelcomeLabel1.Caption := 'Mise à jour ou réparation de MYA';

  if InstalledVersion = '{#MyAppVersionFull}' then
  begin
    WizardForm.WelcomeLabel2.Caption :=
      'MYA version {#MyAppVersionFull} est déjà installé.' + #13#10 + #13#10 +
      'Cliquez sur Suivant pour réinstaller ou réparer les fichiers du programme.' + #13#10 +
      'Vos tâches et paramètres (%LocalAppData%\mya, %AppData%\com.mya) seront conservés.';
  end
  else
  begin
    WizardForm.WelcomeLabel2.Caption :=
      'MYA version ' + InstalledVersion + ' est actuellement installé.' + #13#10 + #13#10 +
      'Cet assistant va mettre à jour MYA vers la version {#MyAppVersionFull}.' + #13#10 +
      'Vos tâches et paramètres (%LocalAppData%\mya, %AppData%\com.mya) seront conservés.';
  end;
end;

function InitializeSetup(): Boolean;
begin
  FreshInstall := not GetInstalledVersion(InstalledVersion, InstalledDirectory);

  if not DirExists(ExpandConstant('{#BuildDir}')) then
  begin
    MsgBox('Build introuvable. Exécutez d''abord :' + #13#10 +
      '  flutter build windows --release', mbError, MB_OK);
    Result := False;
  end
  else
    Result := True;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  if IsUpgradeInstall and
     ((PageID = wpSelectTasks) or (PageID = wpSelectDir)) then
    Result := True;
end;

[Messages]
french.WelcomeLabel2=MYA vous aide à retenir ce que vous devez faire, sans usine à gaz.%n%nCet assistant installe MYA sur votre PC et vous guide pour les options de démarrage.%n%nVos tâches et paramètres (%LocalAppData%\mya et %AppData%\com.mya) restent sur votre machine.
