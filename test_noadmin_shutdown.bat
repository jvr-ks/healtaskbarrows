@rem __updateLib.bat

@echo off

cd %~dp0

echo ***ATTENTION*** if this batch is not closed it shuts your system down!
echo.
echo "healtaskbarrows.exe" must be running in the background (as a server),
echo and
echo "checkadmin.exe" must be in the current directory (or the Windows path)
echo.
pause

echo calls checkadmin.exe now to test if you are admin or not
call checkadmin.exe
pause
echo.
echo now call curl http://localhost:65506/htr?shutdown=8
call curl http://localhost:65506/htr?shutdown=8

pause 







