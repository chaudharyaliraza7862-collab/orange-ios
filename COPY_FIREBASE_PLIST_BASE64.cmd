@echo off
setlocal EnableExtensions
set /p PLIST=Paste full path to your GoogleService-Info.plist: 
if not exist "%PLIST%" (
  echo ERROR: File not found.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$v=[Convert]::ToBase64String([IO.File]::ReadAllBytes('%PLIST%')); Set-Clipboard -Value $v; Write-Host ('Copied Base64 to clipboard. Characters: ' + $v.Length)"
echo.
echo Paste this clipboard value into Codemagic variable GOOGLE_SERVICE_INFO_PLIST_BASE64.
pause
