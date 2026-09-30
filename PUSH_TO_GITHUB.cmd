@echo off
setlocal EnableExtensions
cd /d "%~dp0"
echo.
echo ============================================
echo   ORANGE - PUSH FLUTTER PROJECT TO GITHUB
echo ============================================
echo.
where git >nul 2>nul || (echo ERROR: Git is not installed or not in PATH.& pause & exit /b 1)
if not exist pubspec.yaml (echo ERROR: Put this file in the Flutter project root beside pubspec.yaml.& pause & exit /b 1)

call ADD_GITIGNORE_FOR_GITHUB.cmd /silent

set /p REPO=Paste EMPTY PRIVATE GitHub repository URL (https://github.com/USERNAME/REPO.git): 
if "%REPO%"=="" (echo Repository URL is required.& pause & exit /b 1)

if not exist .git git init
git checkout -B main
git add .
git commit -m "Prepare Orange Flutter app for iOS Codemagic build" 2>nul || echo No new commit was required.
git remote remove origin >nul 2>nul
git remote add origin "%REPO%"
git push -u origin main
if errorlevel 1 (
  echo.
  echo GitHub push failed. Make sure the repository is empty/private and GitHub authentication is available.
  pause
  exit /b 1
)
echo.
echo SUCCESS: Project pushed to GitHub.
echo Now connect this repository in Codemagic.
pause
