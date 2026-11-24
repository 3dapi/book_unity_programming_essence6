@echo off
setlocal
REM ============================================================
REM  Unity MCP prerequisites for ALL USERS (shared lab PCs)
REM  Installs Python 3.12 and uv under "C:\Program Files"
REM  Run: right-click this file > "Run as administrator"
REM ============================================================

net session >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Administrator rights are required.
  echo Right-click this file and choose "Run as administrator".
  echo.
  pause
  exit /b 1
)

where winget >nul 2>nul
if errorlevel 1 (
  echo [ERROR] winget was not found.
  echo Update "App Installer" in the Microsoft Store, then run this file again.
  echo.
  pause
  exit /b 1
)

set "UV_DIR=%ProgramFiles%\uv"

echo [1/3] Installing Python 3.12 for all users...
winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --override "/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1"
echo.

set "PY_FOUND="
for /d %%D in ("%ProgramFiles%\Python3*") do (
  if exist "%%D\python.exe" (
    set "PY_FOUND=%%D"
    echo Python installed at: %%D
  )
)
if not defined PY_FOUND (
  echo [WARN] python.exe was not found under "%ProgramFiles%\Python3*".
  echo        Check the winget output above for errors.
)
echo.

echo [2/3] Installing uv into "%UV_DIR%" ...
set "UV_INSTALL_DIR=%UV_DIR%"
set "UV_NO_MODIFY_PATH=1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
echo.

echo [3/3] Adding "%UV_DIR%" to the system PATH...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d='%UV_DIR%'; $p=[Environment]::GetEnvironmentVariable('Path','Machine'); if (($p -split ';') -notcontains $d) { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $d), 'Machine'); Write-Host 'PATH updated.' } else { Write-Host 'Already in PATH.' }"
echo.

echo ==============================================
echo  Done.
echo  1. Close this window.
echo  2. Open a NEW Command Prompt (as a normal user) and run:
echo       python --version
echo       uv --version
echo  3. Restart Unity and the Claude desktop app.
echo ==============================================
echo.
pause
endlocal
