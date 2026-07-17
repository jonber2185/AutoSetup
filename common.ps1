function Write-Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $msg
    Write-Host $line
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

function Process-Folder {
    param(
        [string]$FolderPath,
        [string]$TaskName,
        [array]$ConfigList
    )

    Write-Log "--- $TaskName ---"
    
    if (-not (Test-Path $FolderPath)) {
        Write-Log "[WARN] directory doesn't exist: $FolderPath"
        return
    }

    Get-ChildItem -Path $FolderPath -File -Recurse | ForEach-Object {
        $file = $_
        foreach ($item in $ConfigList) {
            if ($file.FullName -like "*$($item.Pattern)*") {
                if ($item.TargetDir -and -not (Test-Path $item.TargetDir)) {
                    New-Item -ItemType Directory -Path $item.TargetDir -Force | Out-Null
                }
                if ($file.Extension -eq '.zip') {
                    tar -xf `"$($file.FullName)`" -C `"$($item.TargetDir)`"
                    Write-Log "  [+] Extract Zip Files: $($file.name)"
                }
                elseif ($item.Action) {
                    Write-Log "  -> Installation: $($file.Name)"
                    & $item.Action $file.FullName $item.TargetDir
                }
            }
        }
    }
}

function Set-SystemEnvironment {
    param(
        [array]$EnvVariables,
        [array]$PathList
    )

    Write-Log "--- Set env ---"

    # 변수 등록
    foreach ($item in $EnvVariables) {
        foreach ($key in $item.Keys) {
            $val = $item[$key]
            [Environment]::SetEnvironmentVariable($key, $val, "Machine")
            Set-Item "env:$key" $val
            Write-Log "  [+] registration system var: $key = $val"
        }
    }

    # PATH 등록
    if ($PathList -and $PathList.Count -gt 0) {
        $regKey = "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment"
        $currentPath = (Get-ItemProperty -Path $regKey).Path
        $pathArray = $currentPath -split ';' | Where-Object { $_ -ne "" }

        # 중복 체크
        $cleanPathArray = $pathArray | Where-Object {
            $existingItem = $_
            $isDuplicate = $false
            foreach ($p in $PathList) {
                $expandedNew = [Environment]::ExpandEnvironmentVariables($p)
                $expandedExisting = [Environment]::ExpandEnvironmentVariables($existingItem)

                if ($existingItem -eq $p -or $expandedExisting -eq $expandedNew) {
                    $isDuplicate = $true
                    break
                }
            }
            -not $isDuplicate
        }

        # PATH에 삽입
        $finalPathArray = $PathList + $cleanPathArray
        $newPathString = $finalPathArray -join ';'
        Set-ItemProperty -Path $regKey -Name "Path" -Value $newPathString -Type ExpandString

        # 터미널에 추가
        $sessionPaths = $PathList | ForEach-Object { [Environment]::ExpandEnvironmentVariables($_) }
        $currentEnvArray = $env:PATH -split ';' | Where-Object { $_ -ne "" -and ($sessionPaths -notcontains $_) }
        $env:PATH = ($sessionPaths + $currentEnvArray) -join ';'

        Write-Log "  [+] Append to top of PATH :"
        foreach ($p in $PathList) {
            Write-Log "      -> $p"
        }
    }
}


function Install-Program {
    param(
        [string]$id,
        [string]$param = "--silent"
    )

    $argumentList = @(
        "install",
        "--id", $id,
        "--accept-source-agreements",
        "--accept-package-agreements"
    )
    if ($param) {
        $argumentList += $param
    }

    Start-Process winget -ArgumentList $argumentList -Wait
    Write-Log "  -> Installation: $id"
}
