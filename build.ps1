#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

# --------------------------------------------
# 1. Extract the two pieces of info we need
# --------------------------------------------
$appVer = (Select-String pubspec.yaml -Pattern '^version:' |
           ForEach-Object { $_.Line.Split()[1] })
Write-Host "Detected version: $appVer"
$relNameRaw = (Select-String pubspec.yaml -Pattern '^release_name:' | % { $_.Line.Split()[1] })
$relName    = $relNameRaw.Trim('"')              # strip any surrounding quotes
Write-Host "Building $appVer  (label: $relName)" -ForegroundColor Cyan

# --------------------------------------------
# 2. Web  (embed version, deploy)
# --------------------------------------------
flutter build web --release
# 2a) build/web/index.html  – replace token __APP_VERSION__
(Get-Content build\web\index.html -Raw) -replace '__APP_VERSION__', $appVer | Set-Content build\web\index.html
# 2b) docs/releases.html   – replace whatever is after “Obecna wersja:”
(Get-Content docs\releases.html -Raw) -replace '(?<=Obecna wersja:\s*<strong>)[^<]+' , $appVer | Set-Content docs\releases.html

firebase deploy         --only hosting
# --------------------------------------------
# 3. Android  – rename APK & AAB
# --------------------------------------------
flutter  build apk      --release
flutter  build appbundle --release

$apkOut = "build\app\outputs\flutter-apk\app-release.apk"
$aabOut = "build\app\outputs\bundle\release\app-release.aab"

Move-Item $apkOut ".\releases\app_${relName}.apk" -Force
Move-Item $aabOut ".\releases\app_${relName}.aab" -Force

# --------------------------------------------
# 4. Windows EXE  – rename archive
# --------------------------------------------
flutter  build windows  --release
dart     run msix:create

Move-Item ".\build\windows\x64\runner\Release\*.msix" ".\releases\jeden_${relName}.msix" -Force

$exeDir   = "build\windows\x64\runner\Release"
$out7z    = Join-Path $PSScriptRoot "releases\Win_x64_${relName}.7z"
$sevenZip = 'C:\Program Files\7-Zip\7z.exe'
if (-not (Test-Path $exeDir)) {
    throw "❌  Windows Release folder  '$exeDir' not found"
}
# 7-Zip:  a = Add  ;  -t7z = 7-Zip format
# -xr!*.7z  -xr!*.msix   = eXclude Recurse (wildcard) any existing .7z / .msix C:\Program Files\7-Zip
Push-Location $exeDir
$args = @(
  'a'             # add
  '-t7z'          # 7-Zip format
  $out7z          #   ← variable is expanded
  '.'             # current dir
  '-xr!*.msix'    # exclude any MSIX already there
  '-xr!*.7z'      # exclude previous .7z files
)

& $sevenZip @args

Pop-Location
Write-Host "• Windows files packed as $out7z"



# --------------------------------------------------------------
# Update docs/releases.html download link  ➜ uses $relName tag
# --------------------------------------------------------------

(Get-Content docs\releases.html -Raw)                          `
  -replace 'releases/download/[^/]+/Win_x64_[^"]+\.7z',
           "releases/download/$relName/Win_x64_${relName}.7z"  |
  Set-Content docs\releases.html

(Get-Content docs\releases.html -Raw)                          `
  -replace 'releases/download/[^/]+/[^"]+\.apk',
           "releases/download/$relName/app_${relName}.apk"  |
  Set-Content docs\releases.html

Write-Host "`n✅  All outputs renamed under .\releases" -ForegroundColor Green