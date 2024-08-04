; htrsservice.ahk
/*
 *********************************************************************************
 * 
 * htrsservice.ahk
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
#Persistent

; https://github.com/zhamlin/AHKhttp
#include, Lib\AHKhttp.ahk

; http://www.autohotkey.com/forum/viewtopic.php?p=355775
#include, Lib\AHKsock.ahk

appName := "htrsservice"
appnameLower := "htrsservice" 
extension := ".exe"
appVersion := "0.016"
configfile := A_ScriptDir . "\htrsservice.ini"
htrRestPortDefault := 65506
htrRestPort := 0
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

  if (!A_IsAdmin){
    if (!RegExMatch(full_command_line, " /restart(?!\S)")){
      try
      {
        Run *RunAs %A_ScriptFullPath% /restart %allparams%
      }
      exitApp
    }
    MsgBox, Error`, could not get admin-rights`, exiting %appName% due to this error!
    exit()
  }

} else {
  if (!A_IsAdmin){
    MsgBox, Script must be run as an admin!
    exit()
  }
}

createConfig()

createMime()

readIni()

; commandline parameters take precedence over config-file, if they are there!
Loop % A_Args.Length()
{
  if(InStr(A_Args[A_index],"htrRestPort")){
    RegExMatch(A_Args[A_index],"O)htrRestPort\=(\d+)",Match)
    if (Match.Count() > 0){
      htrRestPort:= 0 + Match.Value[1]
      if (htrRestPort < 1001)
        htrRestPort := htrRestPortDefault
    }
  }
}

; server
paths := {}
paths["/htr"] := Func("htrRest")

if (htrRestPort > 1000){
  serverHttp := new HttpServer()
  serverHttp.LoadMimes(A_ScriptDir . "/mime.types")
  serverHttp.SetPaths(paths)
  serverHttp.Serve(htrRestPort)
  tipTop("HealTaskbarRows server started, listening on port " . htrRestPort . "!", n := 1, t := 3000)
}

return
;---------------------------------- readIni ----------------------------------
readIni(){
  global configfile
  global htrRestPortDefault
  global htrRestPort
  
  if (FileExist(configfile)){
    IniRead, htrRestPort, %configfile%, config, htrRestPort, %htrRestPortDefault%
    if (htrRestPort < 1001)
      htrRestPort := htrRestPortDefault
  }

  return
}
;---------------------------------- htrRest ----------------------------------
; request examples -> 
; curl http://localhost:65506/htr?shutdown=9
; curl http://localhost:65506/htr?rows=4

htrRest(ByRef req, ByRef res) {
  global rows
  global appVersion

  shutdownmodeRest := ""
  rowsRest := ""

  shutdownmodeRest := req.queries["shutdown"]
  rowsRest := req.queries["rows"]
  stop := req.queries["removeservice"]
  showversion := req.queries["showversion"]
  
  if (shutdownmodeRest != ""){
    res.SetBodyText("Shutdown: " . shutdownmodeRest)
    res.status := 200
    
    settingOrg := readFromReg()
    if (settingOrg == ""){
      MsgBox,48,Server-error occured,Something went wrong reading value %setting% from the registry!`n`nClosing app due to this error!
      exit()
    }
    
    settingLen := StrLen(settingOrg)
    settingHead := SubStr(settingOrg,1,settingLen - 8)
    settingValue := SubStr(settingOrg,settingLen - 7, 2)
    settingTail := SubStr(settingOrg,settingLen - 5)
    
    settingInc := Format("{1:02X}", 0x01 + settingValue)
    
    settingNew := settingHead . settingInc . settingTail

    res.SetBodyText("Setting rows to: " . settingValue . " and perform action number: " . shutdownmodeRest)
    res.status := 200
    
    writeToRegAndAction(settingNew, false, shutdownmodeRest)
  }

  if (rowsRest != ""){ 
    res.SetBodyText("Rows: " . rowsRest)
    res.status := 200
  
    settingOrg := readFromReg()
    if (settingOrg == ""){
      MsgBox,48,Server-error occured,Something went wrong reading value %setting% from the registry!`n`nClosing app due to this error!
      exit()
    }

    settingLen := StrLen(settingOrg)
    settingHead := SubStr(settingOrg,1,settingLen - 8)
    settingValue := SubStr(settingOrg,settingLen - 7, 2)
    settingTail := SubStr(settingOrg,settingLen - 5)

    settingInc := Format("{1:02X}", rowsRest)

    settingNew := settingHead . settingInc . settingTail
    
    res.SetBodyText("Setting rows to: " . settingValue)
    res.status := 200
    
    writeToRegAndAction(settingNew, true)
  }
  
  if (showversion != ""){ 
    res.SetBodyText("Running htrservice-version is: " . appVersion)
    res.status := 200
  }
  
  if (stop != ""){ 
    res.SetBodyText("Removing the htrservice, by by ... ")
    res.status := 200
    settimer, exit, -5000
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
     ; give service some time ... 
     sleep,12000
     Shutdown, %shutdownmodeL%
     exit()
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
  global htrRestPortDefault
  
  if (!FileExist(configfile)){
    FileAppend,
    (LTrim
      [config]
      htrRestPort=%htrRestPortDefault%
    ), %configfile%, UTF-8-RAW
  }
  
  return
}
;-------------------------------- createMime --------------------------------
createMime(){
  
  if (!FileExist("mime.types")){
    FileAppend,
    (LTrim
    text/html                             html htm shtml
    text/css                              css
    text/xml                              xml
    image/gif                             gif
    image/jpeg                            jpeg jpg
    application/x-javascript              js
    application/atom+xml                  atom
    application/rss+xml                   rss

    text/mathml                           mml
    text/plain                            txt
    text/vnd.sun.j2me.app-descriptor      jad
    text/vnd.wap.wml                      wml
    text/x-component                      htc

    image/png                             png
    image/tiff                            tif tiff
    image/vnd.wap.wbmp                    wbmp
    image/x-icon                          ico
    image/x-jng                           jng
    image/x-ms-bmp                        bmp
    image/svg+xml                         svg svgz
    image/webp                            webp

    application/java-archive              jar war ear
    application/mac-binhex40              hqx
    application/msword                    doc
    application/pdf                       pdf
    application/postscript                ps eps ai
    application/rtf                       rtf
    application/vnd.ms-excel              xls
    application/vnd.ms-powerpoint         ppt
    application/vnd.wap.wmlc              wmlc
    application/vnd.google-earth.kml+xml  kml
    application/vnd.google-earth.kmz      kmz
    application/x-7z-compressed           7z
    application/x-cocoa                   cco
    application/x-java-archive-diff       jardiff
    application/x-java-jnlp-file          jnlp
    application/x-makeself                run
    application/x-perl                    pl pm
    application/x-pilot                   prc pdb
    application/x-rar-compressed          rar
    application/x-redhat-package-manager  rpm
    application/x-sea                     sea
    application/x-shockwave-flash         swf
    application/x-stuffit                 sit
    application/x-tcl                     tcl tk
    application/x-x509-ca-cert            der pem crt
    application/x-xpinstall               xpi
    application/xhtml+xml                 xhtml
    application/zip                       zip

    application/octet-stream              bin exe dll
    application/octet-stream              deb
    application/octet-stream              dmg
    application/octet-stream              eot
    application/octet-stream              iso img
    application/octet-stream              msi msp msm

    audio/midi                            mid midi kar
    audio/mpeg                            mp3
    audio/ogg                             ogg
    audio/x-m4a                           m4a
    audio/x-realaudio                     ra

    video/3gpp                            3gpp 3gp
    video/mp4                             mp4
    video/mpeg                            mpeg mpg
    video/quicktime                       mov
    video/webm                            webm
    video/x-flv                           flv
    video/x-m4v                           m4v
    video/x-mng                           mng
    video/x-ms-asf                        asx asf
    video/x-ms-wmv                        wmv
    video/x-msvideo                       avi
    ), mime.types, UTF-8-RAW
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
;---------------------------------- getSid ----------------------------------
getSid(){
  r := "not found!"
  Loop, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, 2
  if (A_LoopRegType = "ProfileImagePath" && StrLen(A_LoopRegName) > 20){
    r := A_LoopRegName
  }
  
  return r
}

;----------------------------------- exit -----------------------------------
exit(){

  exitApp

  return 
}
;----------------------------------------------------------------------------
















