:: Expected arguments:
:: %1 = python_src
:: %2 = dest_dir

SETLOCAL
SET PYTHON_SRC=%1
SET DEST=%2

IF NOT DEFINED KOKORO_BUILD_ID (set KOKORO_BUILD_ID=dev)

cd %PYTHON_SRC%
rmdir /s/q %DEST% 2>NUL
md %DEST%
IF %ERRORLEVEL% NEQ 0 goto :end

:: Deletes Android.bp or it will be packaged.
DEL Lib\Android.bp
IF %ERRORLEVEL% NEQ 0 goto :end

ECHO ## Building python...
CALL PCbuild\build.bat -c Release -p x64
IF %ERRORLEVEL% NEQ 0 goto :end

ECHO ## Packaging python...
CALL PCBuild\amd64\python.exe PC\layout --zip %DEST%\python3-windows-%KOKORO_BUILD_ID%.zip --include-dev
IF %ERRORLEVEL% NEQ 0 goto :end

:: Packages all downloaded externals in externals
:: (Log the location of 7z.exe to show that Cygwin's 7z.exe isn't used.)
ECHO ## Packaging externals...
where 7z
7z a %DEST%\python3-externals-%KOKORO_BUILD_ID%.zip .\externals
IF %ERRORLEVEL% NEQ 0 goto :end

:end
exit /b %ERRORLEVEL%
