@echo off

set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

mklink %cd%\..\..\.vscode\settings.json %USERPROFILE%\Code\C++\__Template\.vscode\settings.json

mklink %cd%\..\..\.clang-format %USERPROFILE%\Code\C++\__Template\.clang-format
mklink %cd%\..\..\.cmake-format.yaml %USERPROFILE%\Code\C++\__Template\.cmake-format.yaml
mklink %cd%\..\..\.pre-commit-config.yaml %USERPROFILE%\Code\C++\__Template\.pre-commit-config.yaml
mklink %cd%\..\..\.yamlfmt %USERPROFILE%\Code\C++\__Template\.yamlfmt
