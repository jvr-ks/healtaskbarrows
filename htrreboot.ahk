; htrreboot.ahk

#NoEnv
#Warn
#SingleInstance force

run %A_Comspec% /c curl http://localhost:65506/htr?shutdown=2

exitApp


 