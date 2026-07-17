$config = @(
    @{ 
        Pattern   = 'vandizip_installer.exe'; 
        TargetDir = $null;
        Action    = { param($p, $dir) Start-Process $p -ArgumentList '/S' -Wait } 
    },
    @{ 
        Pattern   = 'Chrome*.exe'; 
        TargetDir = $null;
        Action    = { param($p, $dir) Start-Process $p -ArgumentList '/silent /install' -Wait } 
    },
    @{ 
        Pattern   = 'AULA*.exe'; 
        TargetDir = $null;
        Action    = { param($p, $dir) Start-Process $p -ArgumentList '/silent' -Wait } 
    },
    @{ 
        Pattern   = 'LEOBOG*.exe'; 
        TargetDir = $null;
        Action    = { param($p, $dir) Start-Process $p -ArgumentList '/silent' -Wait } 
    },
    @{ 
        Pattern   = 'atk*.exe'; 
        TargetDir = $null;
        Action    = { param($p, $dir) Start-Process $p -ArgumentList '/S' -Wait } 
    },
    @{ 
        Pattern   = 'VMware*.exe'; 
        TargetDir = $null;
        Action    = { 
            param($p, $dir) 
            $argsList = "/s /v`"/qn EULAS_AGREED=1 AUTOSOFTWAREUPDATE=1`""
            Start-Process $p -ArgumentList $argsList -Wait 
        } 
    },
    @{ 
        Pattern   = 'OfficeSetup.exe'; 
        TargetDir = $null;
        Action    = { param($p, $dir) Start-Process $p -Wait } 
    }
)

Process-Folder (Join-Path $Root 'installer\program') 'Install Programs' $config


# Everything
Install-Program 'voidtools.Everything'
# TreeSize
Install-Program 'XP9M26RSCLNT88' '--source msstore'
# ShowKeyPlus
Install-Program '9PKVZCPRX9NV' '--source msstore'
# PowerToy
Install-Program 'Microsoft.PowerToys'
# LogiOptions
Install-Program 'Logitech.OptionsPlus' '--override "/quiet"'
# AutoHotKey
Install-Program 'AutoHotkey.AutoHotkey' '--override "/silent"'
# Rufus
Install-Program '9PC3H3V7Q9CH' '--source msstore'
# Kakao
Install-Program 'Kakao.KakaoTalk'
# Discord
Install-Program 'Discord.Discord'
# Notion
Install-Program 'Notion.Notion'
# IDA
Install-Program 'Hex-Rays.IDA.Free' '--override "--unattendedmodeui none --mode unattended"'
# HXD
Install-Program 'MHNexus.HxD'
# Claude
Install-Program 'Anthropic.Claude' '--override "/S"'
# vscode
Install-Program 'Microsoft.VisualStudioCode' '--override "/SILENT /mergetasks=`"!runcode,addcontextmenufiles,addcontextmenufolders`""'
# visual studio
Install-Program 'Microsoft.VisualStudio.Community' '--override "--quiet"'
# eclipse
Install-Program 'EclipseFoundation.Eclipse.JEE'
# Android Studio
Install-Program 'Google.AndroidStudio'
# MySQL
Install-Program 'Oracle.MySQLWorkbench'
# Figma
Install-Program 'Figma.Figma' '--override "-s"'
