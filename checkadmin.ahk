; checkadmin.ahk
#NoENV
#Warn

if (A_IsAdmin){
  tipTop("Script runs as an admin!")
} else {
 tipTop("Script does NOT run as an admin!")
}

sleep, 4500

tooltip

exitApp

;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1, t := 4000){

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

  
  














