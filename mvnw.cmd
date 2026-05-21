@echo off
where mvn >nul 2>nul
if errorlevel 1 (
  echo Maven was not found on PATH.
  exit /b 1
)
mvn %*
