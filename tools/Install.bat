@echo off

:: Elevate to admin and also stay in the correct directory (https://stackoverflow.com/a/52517718)
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

if exist "%cd%\packages.config" (
    choco install packages.config -y

    go install github.com/google/yamlfmt/cmd/yamlfmt@latest
)

if exist "%cd%\requirements.txt" (
    pip install --upgrade -q -r requirements.txt
)
