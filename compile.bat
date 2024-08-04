@rem compile.bat

@echo off

cd %~dp0

set appname=healtaskbarrows
call :sub

set appname=htrsservice
call :sub

set appname=htrshutdown
call :sub

set appname=htrreboot
call :sub

set appname=healtaskbarrows

goto :end


:sub
echo compile %appname%
set autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
set autohotkeyCompilerPath=C:\Program Files\AutoHotkey\Compiler\

call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"
exit /B 

:end  
