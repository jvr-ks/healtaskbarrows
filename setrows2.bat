@rem setrows2.bat

@set rows=2

@echo off

cd %~dp0

net session >nul 2>&1
if NOT %ERRORLEVEL% == 0 goto noadmin

call healtaskbarrows.exe rows=%rows% noshutdown
goto end

:noadmin
echo Error, please run the script as an administrator!
echo.
pause
goto end


:end






