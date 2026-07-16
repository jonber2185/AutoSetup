$config = @(
    @{ 
        Pattern = 'jdk-17*.exe';  
        TargetDir = (Join-Path $sdkRoot 'java\jdk-17');
        Action  = { param($p, $dir) Start-Process $p -ArgumentList "/s INSTALLDIR=`"$dir`"" -Wait } 
    }
    @{ 
        Pattern = 'jdk-21*.exe';  
        TargetDir = (Join-Path $sdkRoot 'java\jdk-21');
        Action  = { param($p, $dir) Start-Process $p -ArgumentList "/s INSTALLDIR=`"$dir`"" -Wait } 
    }
    @{ 
        Pattern = 'node-*.msi';   
        TargetDir = (Join-Path $sdkRoot 'nodejs');
        Action  = { param($p, $dir) Start-Process msiexec.exe -ArgumentList "/i `"$p`" /quiet /norestart INSTALLDIR=`"$dir`"" -Wait } 
    }
    @{ 
        Pattern = 'python-*.exe'; 
        TargetDir = (Join-Path $sdkRoot 'python');
        Action  = { param($p, $dir) Start-Process $p -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 TargetDir=`"$dir`"" -Wait } 
    }
    @{ 
        Pattern   = 'flutter_windows_*.zip'
        TargetDir = $sdkRoot
    }
    @{ 
        Pattern   = 'Git-*.exe'
        TargetDir = (Join-Path $sdkRoot 'git')
        Action    = { param($p, $dir) Start-Process $p -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /DIR=`"$dir`"" -Wait } 
    }
)

Process-Folder (Join-Path $Root 'installer\SDK') 'Install SDK' $config

$envVars = @(
    @{ "JAVA_HOME" = (Join-Path $sdkRoot 'java\jdk-21') }
)
$pathsToAdd = @(
    '%JAVA_HOME%\bin',
    (Join-Path $sdkRoot 'nodejs\'),
    (Join-Path $sdkRoot 'flutter\bin'),
    (Join-Path $sdkRoot 'python\'),
    (Join-Path $sdkRoot 'python\Scripts'),
    (Join-Path $sdkRoot 'git\cmd')
)
Set-SystemEnvironment -EnvVariables $envVars -PathList $pathsToAdd