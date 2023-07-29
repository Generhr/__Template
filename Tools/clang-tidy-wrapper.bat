@echo off

REM Set default path for clang-tidy (if not already set by environment variable)
if "%CTCACHE_CLANG_TIDY%"=="" set "CTCACHE_CLANG_TIDY=C:\Program Files\Microsoft Visual Studio\2022\Preview\VC\Tools\Llvm\x64\bin\clang-tidy.exe"

REM Check if CTCACHE_DISABLE is set and not equal to 0
if "%CTCACHE_DISABLE%" neq "0" (
    "%CTCACHE_CLANG_TIDY%" %CTCACHE_CLANG_TIDY_OPTS% %*
)
else (
    "%~dp0clang-tidy-cache.py" "%CTCACHE_CLANG_TIDY%" %CTCACHE_CLANG_TIDY_OPTS% %*
)
