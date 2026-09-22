@echo off
REM ==========================================================================
REM  Update the Evo-M1 Shiny app - Windows one-click launcher.
REM
REM    - DOUBLE-CLICK this file in File Explorer, or run it from a Command
REM      Prompt in this folder:  Update_ShinyApp.bat
REM
REM  It hands off to update_shinyapp.R (build -> push -> deploy). Pass options
REM  straight through, e.g.:  Update_ShinyApp.bat --no-deploy
REM
REM  Needs R installed (https://cran.r-project.org). If Rscript is not found on
REM  your PATH, edit the RSCRIPT line below to your full Rscript.exe path, e.g.
REM  "C:\Program Files\R\R-4.4.1\bin\Rscript.exe".
REM ==========================================================================
setlocal
cd /d "%~dp0"
echo Repo: %cd%

set "RSCRIPT=Rscript"
where %RSCRIPT% >nul 2>nul
if errorlevel 1 (
  echo.
  echo [X] Rscript not found on PATH.
  echo     Install R from https://cran.r-project.org, or edit the RSCRIPT line
  echo     in this .bat to point at your Rscript.exe, then re-run.
  echo.
  pause
  exit /b 1
)

%RSCRIPT% "update_shinyapp.R" %*
set "STATUS=%errorlevel%"

echo.
if "%STATUS%"=="0" (echo [OK] Finished.) else (echo [X] Finished with errors ^(see above^).)
pause
exit /b %STATUS%
