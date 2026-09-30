@echo off
setlocal EnableExtensions
cd /d "%~dp0"
if not exist .gitignore type nul > .gitignore
findstr /x /c:"orange.jks" .gitignore >nul 2>nul || echo orange.jks>>.gitignore
findstr /x /c:"android/key.properties" .gitignore >nul 2>nul || echo android/key.properties>>.gitignore
findstr /x /c:"*.p8" .gitignore >nul 2>nul || echo *.p8>>.gitignore
findstr /x /c:"*.p12" .gitignore >nul 2>nul || echo *.p12>>.gitignore
findstr /x /c:"*.mobileprovision" .gitignore >nul 2>nul || echo *.mobileprovision>>.gitignore
findstr /x /c:"*.cer" .gitignore >nul 2>nul || echo *.cer>>.gitignore
if /i not "%~1"=="/silent" (
  echo Git ignore rules added safely.
  pause
)
