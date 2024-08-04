; healtaskbarrows.ahk
/*
 *********************************************************************************
 * 
 * healtaskbarrows.ahk
 * 
 * use UTF-8 (no BOM)
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2022 jvr.de. All rights reserved.
 *
 *
 *********************************************************************************
*/

/*
 *********************************************************************************
 * 
 * MIT License
 * 
 * 
 * Copyright (c) 2022 jvr.de. All rights reserved.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sub-license, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANT-ABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
*/

#NoEnv
#Warn
#SingleInstance force

appName := "HealTaskbarRows"
appnameLower := "healtaskbarrows" 
extension := ".exe"
appVersion := "0.016"
configfile := A_ScriptDir . "\healtaskbarrows.ini"
noshutdown := false
shutdownmode := 8
setrows := false
rows := 1

; force admin rights
if (A_IsCompiled){
  allparams := ""
  for keyGL, valueGL in A_Args {
    allparams .= valueGL . " "
  }
  full_command_line := DllCall("GetCommandLine", "str")

  if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
    try
    {
      Run *RunAs %A_ScriptFullPath% /restart %allparams%
    }
    ExitApp
  }
} else {
  if (!A_IsAdmin){
    MsgBox, Script must be run as an admin!
    exitApp
  }
}

createConfig()

readIni()

; commandline parameters take precedence over config-file, if they are there!
Loop % A_Args.Length()
{
  if(InStr(A_Args[A_index],"noshutdown")){
    noshutdown := true
  }
  
  if(InStr(A_Args[A_index],"rows")){
    RegExMatch(A_Args[A_index],"O)rows\=(\d+)",Match)
    if (Match.Count() > 0){
      setrows := true
      rows:= 0 + Match.Value[1]
    }
  }
  
  if(InStr(A_Args[A_index],"shutdownmode")){
    RegExMatch(A_Args[A_index],"O)shutdownmode\=(\d+)",Match)
    if (Match.Count() > 0){
       shutdownmode:= 0 + Match.Value[1]
    }
  }
}

directExecute()
exitApp

;------------------------------ directExecute ------------------------------
directExecute(){
  global noshutdown
  global shutdownmode
  global rows
  global setrows
  
  settingOrg := readFromReg()
   
  if (settingOrg == ""){
    MsgBox,48,Error occured,Something went wrong reading value %setting% from the registry!`n`nClosing app due to this error!
    exitApp
  }

  settingLen := StrLen(settingOrg)
  settingHead := SubStr(settingOrg,1,settingLen - 8)
  settingValue := SubStr(settingOrg,settingLen - 7, 2)
  settingTail := SubStr(settingOrg,settingLen - 5)
  settingInc := Format("{1:02X}", 0x01 + settingValue)

  if (setrows)
    settingInc := Format("{1:02X}", rows)

  settingNew := settingHead . settingInc . settingTail

  writeToRegAndAction(settingNew, noshutdown, shutdownmode)
  
  return
}
;---------------------------------- readIni ----------------------------------
readIni(){
  global configfile
  global noshutdown
  global rows
  global shutdownmode
  
  if (FileExist(configfile)){
    IniRead, noshutdown, %configfile%, config, noshutdown ,0
    IniRead, rows, %configfile%, config, rows ,0
    IniRead, shutdownmode, %configfile%, config, shutdownmode ,8
  }
  
  return
}

;-------------------------------- readFromReg --------------------------------
readFromReg(){
  RegRead, regContent, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 , Settings
 
  return regContent
}
;----------------------------- writeToRegAndAction -----------------------------
writeToRegAndAction(setting, noshutdownL := false, shutdownmodeL := 8){
  
  if (setting != ""){
    RegWrite, REG_BINARY, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3, Settings, %setting%
  }
  
  if (ErrorLevel){
    MsgBox,48,Error occured,Something went wrong writing value %setting% to the registry!
  } else {
    if (noshutdownL){
      run *RunAs %A_Comspec% /c taskkill /IM explorer.exe /F & explorer.exe
    } else {
     ; give Windows some time ...
     sleep,3000
     Shutdown, %shutdownmodeL%
     exitApp
    }
  }

  return
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;------------------------------- createConfig -------------------------------
createConfig(){
  global configfile
  
  if (!FileExist(configfile)){
    FileAppend,
    (LTrim
      [config]
      noshutdown=0
      rows=0
      shutdownmode=8
    ), %configfile%, UTF-8-RAW
  }
  
  return
}
;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1, t := 3000){

  s := StrReplace(msg,"^",",")
  
  toolX := Floor(A_ScreenWidth / 2)
  toolY := 2

  CoordMode,ToolTip,Screen
  ToolTip,%s%, toolX, toolY, n
  
  WinGetPos, X,Y,W,H, ahk_class tooltips_class32

  toolX := (A_ScreenWidth / 2) - W / 2
  
  ToolTip,%s%, toolX, toolY, n
  
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopClose,%tvalue%
  }
  
  return
}
;-------------------------------- tipTopClose --------------------------------
tipTopClose(){
  
  Loop, 20
  {
    ToolTip,,,,%A_Index%
  }
  
  return
}
;----------------------------------------------------------------------------
















