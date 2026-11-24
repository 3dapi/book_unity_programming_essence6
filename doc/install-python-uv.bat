@echo off
setlocal EnableExtensions

REM ============================================================
REM  Unity MCP prerequisites: Python (3.10 or newer) and uv
REM
REM   Step 1. Check whether a suitable Python is already installed
REM   Step 2. If not, install Python into the folder you choose
REM   Step 3. Install uv into the folder you choose (skipped if present)
REM
REM  Run as administrator  -> installs for ALL users (system PATH)
REM  Run as normal user    -> installs for the CURRENT user (user PATH)
REM ============================================================

REM --- Change this line to use another Python version ---
set "PY_VER=3.12.10"
set "PY_URL=https://www.python.org/ftp/python/%PY_VER%/python-%PY_VER%-amd64.exe"

set "ALLUSERS=0"
net session >nul 2>&1
if %errorlevel%==0 set "ALLUSERS=1"

set "DEF_PY=%LOCALAPPDATA%\Programs\Python\Python312"
set "DEF_UV=%LOCALAPPDATA%\Programs\uv"
set "SCOPE_TEXT=CURRENT USER only"
set "PATH_SCOPE=User"
if "%ALLUSERS%"=="1" set "DEF_PY=%ProgramW6432%\Python312"
if "%ALLUSERS%"=="1" set "DEF_UV=%ProgramW6432%\uv"
if "%ALLUSERS%"=="1" set "SCOPE_TEXT=ALL USERS"
if "%ALLUSERS%"=="1" set "PATH_SCOPE=Machine"

echo ==============================================
echo  Unity MCP prerequisites: Python and uv
echo  Install scope: %SCOPE_TEXT%
echo ==============================================
echo.

REM ------------------------------------------------------------
REM  Step 1. Check Python
REM ------------------------------------------------------------
echo [Step 1/3] Checking Python (3.10 or newer is required)...
python -c "import sys; sys.exit(0 if sys.version_info[:2]>=(3,10) else 1)" >nul 2>nul
if %errorlevel%==0 goto :python_ready

python --version >nul 2>nul
if %errorlevel%==0 goto :python_old
echo No usable Python was found.
goto :python_install

:python_old
echo A Python older than 3.10 was found. A new Python will be installed.
goto :python_install

:python_ready
for /f "delims=" %%V in ('python --version 2^>^&1') do echo Found: %%V
for /f "delims=" %%P in ('where python 2^>nul') do (
  echo Location: %%P
  goto :step3
)
goto :step3

REM ------------------------------------------------------------
REM  Step 2. Install Python into the chosen folder
REM ------------------------------------------------------------
:python_install
echo.
echo [Step 2/3] Installing Python %PY_VER%
set "PY_DIR=%DEF_PY%"
set /p "PY_DIR=Python install folder [%DEF_PY%]: "
set "PY_DIR=%PY_DIR:"=%"
if "%PY_DIR:~-1%"=="\" set "PY_DIR=%PY_DIR:~0,-1%"

if exist "%PY_DIR%\python.exe" goto :python_exists

set "PY_EXE=%TEMP%\python-%PY_VER%-amd64.exe"
echo Downloading %PY_URL%
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing -Uri '%PY_URL%' -OutFile '%PY_EXE%'"
if not exist "%PY_EXE%" goto :fail_download

echo Installing to "%PY_DIR%" ... please wait.
start "" /wait "%PY_EXE%" /quiet InstallAllUsers=%ALLUSERS% PrependPath=1 TargetDir="%PY_DIR%"
if not exist "%PY_DIR%\python.exe" goto :fail_python
del "%PY_EXE%" >nul 2>nul
echo Python installed at: %PY_DIR%
goto :step3

:python_exists
echo "%PY_DIR%\python.exe" already exists. Python install skipped.
echo If "python" is still not found, add "%PY_DIR%" to PATH.
goto :step3

REM ------------------------------------------------------------
REM  Step 3. Install uv into the chosen folder
REM ------------------------------------------------------------
:step3
echo.
echo [Step 3/3] Checking uv...
uv --version >nul 2>nul
if %errorlevel%==0 goto :uv_ready

set "UV_DIR=%DEF_UV%"
set /p "UV_DIR=uv install folder [%DEF_UV%]: "
set "UV_DIR=%UV_DIR:"=%"
if "%UV_DIR:~-1%"=="\" set "UV_DIR=%UV_DIR:~0,-1%"

if exist "%UV_DIR%\uv.exe" goto :uv_exists

set "UV_INSTALL_DIR=%UV_DIR%"
set "UV_NO_MODIFY_PATH=1"
echo Installing uv to "%UV_DIR%" ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
if not exist "%UV_DIR%\uv.exe" goto :fail_uv
echo uv installed at: %UV_DIR%
goto :uv_path

:uv_exists
echo "%UV_DIR%\uv.exe" already exists. uv install skipped.

:uv_path
echo Adding "%UV_DIR%" to the %PATH_SCOPE% PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d='%UV_DIR%'; $s='%PATH_SCOPE%'; $p=[Environment]::GetEnvironmentVariable('Path',$s); if (-not $p) { $p='' }; if (($p -split ';') -notcontains $d) { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $d), $s); Write-Host 'PATH updated.' } else { Write-Host 'Already in PATH.' }"
goto :done

:uv_ready
for /f "delims=" %%V in ('uv --version 2^>^&1') do echo Found: %%V
for /f "delims=" %%P in ('where uv 2^>nul') do (
  echo Location: %%P
  goto :done
)
goto :done

REM ------------------------------------------------------------
:fail_download
echo.
echo [ERROR] Could not download the Python installer.
echo Check the internet connection and try again.
goto :fail_end

:fail_python
echo.
echo [ERROR] Python was not installed to "%PY_DIR%".
echo If the folder is under Program Files, run this file as administrator.
goto :fail_end

:fail_uv
echo.
echo [ERROR] uv was not installed to "%UV_DIR%".
echo If the folder is under Program Files, run this file as administrator.
goto :fail_end

:fail_end
echo.
pause
exit /b 1

:done
echo.
echo ==============================================
echo  Finished.
echo  1. Close this window.
echo  2. Open a NEW Command Prompt and run:
echo       python --version
echo       uv --version
echo  3. Restart Unity and the Claude desktop app.
echo ==============================================
echo.
pause
endlocal
