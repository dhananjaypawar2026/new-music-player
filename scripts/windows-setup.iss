#define MyAppName "Play Music"
#define MyAppPublisher "Dhananjay Pawar"
#define MyAppPublisherURL "https://github.com/DhananjayPawar2023/"
#define MyAppURL "https://github.com/DhananjayPawar2023/play-music-"
#define MyAppExeName "play_music.exe"
#define MyAppContact "https://github.com/DhananjayPawar2023/play-music-/issues"
#define MyAppCopyright "Copyright (C) 2026 Dhananjay Pawar"
#define Workspace GetEnv("GITHUB_WORKSPACE")

[Setup]
AppId={{94F37DBE-FC81-4E38-B1F1-701EEE9C3D0A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppPublisherURL}
AppSupportURL={#MyAppURL}
AppReadmeFile={#MyAppURL}/README.md
AppUpdatesURL={#MyAppURL}/releases/latest
AppComments={#MyAppName}
AppContact={#MyAppContact}
AppCopyright={#MyAppCopyright}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir={#Workspace}
OutputBaseFilename=Play Music-Windows
SetupIconFile={#Workspace}\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
VersionInfoProductName={#MyAppName}
VersionInfoDescription={#MyAppName} Setup
VersionInfoCompany={#MyAppPublisher}
VersionInfoVersion={#MyAppVersion}.0
VersionInfoProductTextVersion={#MyAppVersion}
VersionInfoCopyright={#MyAppCopyright}
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#Workspace}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{app}\uninstall-{#MyAppName}"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{userdocs}\Play Music\metadata_box.hive"
Type: files; Name: "{userdocs}\Play Music\metadata_box.lock"
Type: files; Name: "{userdocs}\Play Music\playlist_box.hive"
Type: files; Name: "{userdocs}\Play Music\playlist_box.lock"
Type: files; Name: "{userdocs}\Play Music\excluded_directories_box.hive"
Type: files; Name: "{userdocs}\Play Music\excluded_directories_box.lock"
