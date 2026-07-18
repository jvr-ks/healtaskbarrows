@rem setrows1.bat

@set rows=1

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



