@echo off
setlocal enabledelayedexpansion

:: Check if CTCACHE_CLANG_TIDY environment variable exists
if not defined CTCACHE_CLANG_TIDY (
    set "CTCACHE_CLANG_TIDY=C:\Program Files\LLVM\bin\clang-tidy.exe"
)

:: Define the path to ctcache-clang-tidy
set "CTCACHE_CLANG_CACHE=%~dp0..\external\ctcache\clang-tidy-cache"

if exist "!CTCACHE_CLANG_CACHE!" (
    python !CTCACHE_CLANG_CACHE! !CTCACHE_CLANG_TIDY! %*
) else (
    echo does not exist
)

endlocal
