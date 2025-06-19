#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

flutter  build web      --release
$appVer = (Select-String -Path pubspec.yaml -Pattern '^version:' | %{$_.Line.Split()[1]})
(Get-Content build\web\index.html) -replace '__APP_VERSION__', $appVer |
    Set-Content build\web\index.html
firebase deploy         --only hosting
flutter  build apk      --release
flutter  build windows  --release
dart     run msix:create
flutter  build appbundle --release