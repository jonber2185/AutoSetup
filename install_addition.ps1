### 반디집 환경설정 ###
$bandizipRegPath = "HKCU:\Software\Bandizip\Config"
if (-not (Test-Path $bandizipRegPath)) {
    New-Item -Path $bandizipRegPath -Force | Out-Null
}

Set-ItemProperty -Path $bandizipRegPath -Name "bCheckUpdate" -Value 0 -Type DWord
Set-ItemProperty -Path $bandizipRegPath -Name "bCheckUpdateMinor" -Value 0 -Type DWord
Write-Log "[+] Set Bandizip Setting"


### 윈도우 웹검색 ###
$regPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force
Write-Log "[+] Block Bing in widow search"


### keys 이동(복붙) ###
$srcKeys = Join-Path $Root "keys"
$documentsPath = [Environment]::GetFolderPath("MyDocuments")
if (Test-Path $srcKeys) {
    Copy-Item -Path $srcKeys -Destination $documentsPath -Recurse -Force
    Write-Log "[+] Copied 'keys' folder to Documents"
} else {
    Write-Log "[WARN] 'keys' folder not found: $srcKeys"
}


### images 복붙 ###
$srcImages = Join-Path $Root "images"
$picturesPath = [Environment]::GetFolderPath("MyPicture")
if (-not (Test-Path -Path $srcImages)) {
    Write-Log "Directory not Found: $srcImages"
} else {
    $pictureSubFolders = Get-ChildItem -Path $srcImages -Directory
    if ($pictureSubFolders.Count -eq 0) { Write-Log "No File in img dir"} 
    else {
        foreach ($folder in $pictureSubFolders) {
            $destination = Join-Path -Path $picturesPath -ChildPath $folder.Name
            Copy-Item -Path $folder.FullName -Destination $destination -Recurse -Force
            Write-Log "[+] Copied '$($folder.Name)' dir to Pictures"
        }
    }
}


### directory icon ###
$laughIconPath = Join-Path $documentsPath 'keys\icon\icon_file1.ico'
$smileIconPath = Join-Path $documentsPath 'keys\icon\icon_file2.ico'
if (-not (Test-Path $laughIconPath) -or -not (Test-Path $smileIconPath)) { 
    Write-Log "directory icon file not found"
} else {
    $dirIconRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    if (-not (Test-Path $dirIconRegistryPath)) {
        New-Item -Path $dirIconRegistryPath -Force | Out-Null
    }

    Set-ItemProperty -Path $dirIconRegistryPath -Name 3 -Value $smileIconPath -Type String
    Set-ItemProperty -Path $dirIconRegistryPath -Name 4 -Value $laughIconPath -Type String
    Write-Log "[+] Set Dir Shell Icon"
}


### mouse icon ###
$mouseArrowCursor = Join-Path $documentsPath 'keys\mouse\mmm.cur'
$mouseHandCursor = Join-Path $documentsPath 'keys\mouse\waa.cur'
if (-not (Test-Path $mouseArrowCursor) -or -not (Test-Path $mouseHandCursor)) { 
    Write-Log "mouse icon file not found"
} else {
    $cursorRegPath = 'HKCU:\Control Panel\Cursors'
    Set-ItemProperty -Path $cursorRegPath -Name "Arrow" -Value $mouseArrowCursor
    Set-ItemProperty -Path $cursorRegPath -Name "Hand"  -Value $mouseHandCursor
    Write-Log "[+] Set mouse Icon"
}


### trash icon ###
$trashIconPath = Join-Path $documentsPath 'keys\icon\icon_trash.ico'
if (-not (Test-Path $trashIconPath)) { 
    Write-Log "trash icon file not found"
} else {
    $trashIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
    if (-not (Test-Path $trashIconRegPath)) {
        New-Item -Path $trashIconRegPath -Force | Out-Null
    }

    Set-ItemProperty -Path $trashIconRegPath -Name "(default)" -Value $trashIconPath
    Set-ItemProperty -Path $trashIconRegPath -Name "empty" -Value $trashIconPath
    Set-ItemProperty -Path $trashIconRegPath -Name "full" -Value $trashIconPath

    Write-Log "[+] Set TrashCan Icon"
}


### wallpaper ###
$wallpaperPath = Join-Path $picturesPath 'wallpaper\1.png'
if (-not (Test-Path -Path $wallpaperPath)) {
    Write-Warning "File not Found: $wallpaperPath"
} else {
    $wallpaperStyle = "10"
    $tileWallpaper = "0"

    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value $wallpaperStyle
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value $tileWallpaper
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $wallpaperPath

    Write-Log "[+] Set Wallpaper"
}
