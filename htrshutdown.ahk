; htrshutdown.ahk

#NoEnv
#Warn
#SingleInstance force

run %A_Comspec% /c curl http://localhost:65506/htr?shutdown=8

exitApp


 