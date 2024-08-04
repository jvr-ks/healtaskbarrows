# HealTaskbarRows  
Windows 10 only  
  
#### Latest changes  

Version (&gt;=)| Change
------------ | -------------
0.015 | bugfixes, A32 version removed
0.014 | bugfixes
  
#### Status  
**Usable**  
(Reliability is not 100%, so after a reboot the taskbar sometimes (~10%) still has the wrong number of rows.)  
  
Warning: Do not combine the call to "htrsservice*.exe" and your backup-script into a batch-file running with  
admin-rights. The files in your backup-target-directory may be owned by admin then!  
  
Only start "htrsservice*.exe" if you want to use it immediately,  
because a background program running with admin rights is a security risk!  
  
#### Description  
The purpose of "healtaskbarrows.exe" is to correct the size of the taskbar, if it is incorrect after a reboot.  
  
If you have this problem:  
"The taskbar has a row less after reboot",  
then read on!  
  
Only usable, if you have administrator-rights (not are THE Administrator)!  
  
"healtaskbarrows.exe" executes a **shutdown** of your Windows 10.  
  
But beforehand it reads from the registry:  
````
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3] 
```` 
and increments the number of taskbar rows, then writes back to the registry.  
  
On the next boot Windows reduces the number of taskbar-rows by one (a bug),  
but because it was incremented before the last shutdown, everything should be fine then,  
but sometimes the number of taskbar rows is still one less.  
Running "setrowsN.bat" doesn't correct the bug then, taskbar rows are still N-1,  
but running "setrows(N+1).bat" corrects it then.  
("setrowsN.bat" calls "healtaskbarrows.exe rows=N noshutdown".)  
("healtaskbarrows.exe rows=N noshutdown" sets the registry value to N and executes  
"taskkill /IM explorer.exe /F & explorer.exe", i.e. kills explorer.exe and restarts it.)  

**healtaskbarrows.exe must be run as an administrator, it requests admin-rights therefor!**  
(Only admins can write to the registry).  

Another way is to use "healtaskbarrows.exe" not to shutdown, but to set the taskbar rows to a distinct value.  
Take a look at the files "setrows1.bat" ... "setrows5.bat"  
  
There are two different versions of the app: 
* The first one "healtaskbarrows*.exe" uses a direct-call,  
i.e. create a desktop-entry to click on to shutdown Windows. 
HealTaskbarRows has no gui-window.  
The configuration is done via the configuration-file "healtaskbarrows.ini".  
The configuration-file is not required, but automatically created.
I use this batch files to start the app:  
  
Please wait a few seconds after the app was executed before opening the taskbar.  
Sometimes I have to start "setrows7.bat" and additionally "setrows6.bat" afterwards to get the correct size (6 rows)!  
  
* The second one "htrsservice*.exe" runs as a service listening for commands to execute ("Rest-API").  
This is usefull to make a "Rest-API"-call from a batch-file running as **a normal user**.  
(Use the included "htrshutdown.exe" inside the batch-file).  
In contrast to the direct-call, no UAC-request confirmation is required then,    
but the confirmation is required upon startup of the HealTaskbarRows as a service.  
  
Prefered way is to make an link in the autostart folder or use my [Startdelayed project](https://github.com/jvr-ks/Startdelayed).  
"htrsservice*.exe" has no gui-window.  
The configuration is done via the configuration-file "htrsservice.ini".  
The configuration-file is not required, but automatically created.
  
#### Known drawbacks / bugs  
If your taskbar (should have N-rows) sometimes still has one row less after booting,  
it helps calling "setrowsN+1.bat".  
(Script-files "setrows2.bat" ... "setrows5.bat").  
It is usefull to have additional "setrowsN.bat" and "setrowsN+1.bat" icons on the desktop.  
Example:  
My taskbar has 4 rows.  
I use "healtaskbarrows.exe" to shutdown.  
Occasionally the taskbar has only 3 rows after rebooting.  
Then I click on "setrows5.bat". The taskbar has 4 rows now or it has 5 rows sometimes.  
In the later case I initiate a normal Windows restart, the taskbar has 4 rows afterwards.  
  
Addendum:  
My taskbar has 5 rows now.  
Today it had only 4 rows after booting.  
Running "setrows5.bat" doesn't help,  
but running "setrows6.bat" and then (after a few seconds!) "setrows5.bat" fixed it!  
  
Today the taskbar suddenly had only 4 rows after booting (using HealTaskbarRows). 
Running "setrows6.bat" I got 6 rows,    
but running "setrows5.bat" then, I got 4 rows only.  
Running "setrows4.bat" then, I got 3 rows only.  
  
So I could not set the taskbar to 5 rows using HealTaskbarRows!  
Had to manually set the correct number of rows!   
  
Running "setrows6.bat" I got 6 rows again.  
Running "setrows5.bat" I got 5 rows!  
  
#### Download  
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
is not recommended!  
**Directory must be writable by the app!** 
  
Download from Github:  

"healtaskbarrows.exe" (increment taskbar-rows and shutdown):  
[64 bit](https://github.com/jvr-ks/healtaskbarrows/raw/main/healtaskbarrows.exe) or [32 bit](https://github.com/jvr-ks/healtaskbarrows/raw/main/healtaskbarrows32.exe) or 
 
  
"htrsservice.exe" (start service):  
[64 bit](https://github.com/jvr-ks/healtaskbarrows/raw/main/htrsservice.exe) or [32 bit](https://github.com/jvr-ks/healtaskbarrows/raw/main/htrsservice32.exe) or [32 bit ANSI]  
  
"htrshutdown.exe" \(using curl to send http://localhost:65506/htr?shutdown=8 to the running service):    
[64 bit](https://github.com/jvr-ks/healtaskbarrows/raw/main/htrshutdown.exe) or 
[32 bit ](https://github.com/jvr-ks/healtaskbarrows/raw/main/htrshutdown32.exe) or 
  
    
**It is allways a goot idea to have a complete backup of your data!**  

#### Configuration of "healtaskbarrows.exe"  
"healtaskbarrows.exe" is configurated by the configuration-file "healtaskbarrows.ini" and / or by the command-line parameters (take precedence).   
  
##### Configuration-file "healtaskbarrows.ini":
Has only one section "\[config]":   
* noshutdown=\[0,1] (default: 0)  
* * 0 -&gt; shutdown  
* * 1 -&gt; noshutdown  
* rows=\[0, 1 ,2 .. N] (default: 0)   
* * 0 -&gt; automatic increment by one  
* * 1 ... N -&gt; set value to 1 ... N  

* shutdownmode=NUMBER (default: 8)   
* * NUMBER -&gt; 8  : Shutdown and power off (normal shutdown, gives apps some time to save their data)  
* * NUMBER -&gt; 10 : As 10, but reboots afterwards  
* * NUMBER -&gt; 12 : Shutdown forced and power off (dangerous, kills any running app!)  
* * NUMBER -&gt; 12 : As 12, but reboots afterwards 
  
##### Command-line parameters "healtaskbarrows.exe":
Parameter | Effect  
------------ | -------------  
noshutdown | shutdown inhibited (default: -)  
shutdownmode=NUMBER  | NUMBER -&gt;  look above  (default: 8)  
rows=VALUE | set tastbar-rows to VALUE and shutdown Windows or restart taskbar, if "noshutdown" parameter is set too.  

Example:  
````
healtaskbarrows.exe setrows=4 noshutdown  
````
Sets tastbar-rows to 4 and restarts explorer,  
**it takes several seconds until the taskbar is restarted, please be patient!**    
  
setrows1.bat, ... , setrows4.bat batchfiles are in the repo. 
 
#### Configuration of "htrsservice.exe"  
"htrsservice.exe" is configurated by the configuration-file "htrsservice.ini" and / or by the command-line parameters (take precedence). 

##### Configuration-file "htrsservice.ini":
Has only one section "\[config]": 
* htrRestPort=PORT (default: 65506)  
  
##### Command-line parameters "htrsservice.exe":
Parameter | Effect  
------------ | -------------  
htrRestPort=PORT | "Rest-API" port (port &gt; 1000), preferred value is 65506.  
  
##### "Rest-API"-calls "htrsservice.exe":  
URL-path is "htr".  
  
Parameter | Effect  
------------ | -------------  
shutdown=Shutdownmode-NUMBER | shuts down, NUMBER see below 
rows=VALUE | set tastbar-rows to VALUE  
removeservice=true | unload htrsservice  
showversion=true  | print version info

A combination (sum) of the following numbers:  
  
Shutdownmode-NUMBER | Effect   
------------ | -------------  
0 | Logoff  
1 | Shutdown  
2 | Reboot  
4 | Force  
8 | Power down  
  
Add the required values together.
[Autohotkey shutdown command](https://www.autohotkey.com/docs/commands/Shutdown.htm)  
  
There a multible ways to access the "Rest-API".   
  
With "curl" (Windows 10):  
* curl http://localhost:65506/htr?showversion=true 
* curl http://localhost:65506/htr?shutdown=8  
* curl http://localhost:65506/htr?rows=5  
* curl http://localhost:65506/htr?removeservice=true 
  
  
With a browser, open:  
* shutdown and power off  
[http://localhost:65506/htr?shutdown=8](http://localhost:65506/htr?shutdown=8)  
* set taskbar rows to 4  
[http://localhost:65506/htr?rows=4](http://localhost:65506/htr?rows=4)  

##### Helper "htrshutdown.exe":
The included file **"htrshutdown.exe"** just executes:  
"curl http://localhost:65506/htr?shutdown=8"   
    
#### Registry details  
````
Windows Registry Editor Version 5.00  
  
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3]
"Settings"=hex:30,00,00,00,fe,ff,ff,ff,03,00,00,00,03,00,00,00,f8,00,00,00,49,\
  01,00,00,00,00,00,00,27,07,00,00,00,0f,00,00,70,08,00,00,fe,00,00,00,04,00,\
  00,00                                                                **
````  
Taskbar number of rows value in this example regitry-value is: 04  
    
#### License: MIT  
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Copyright (c) 2022 J. v. Roos


##### Virusscan at Virustotal 
[Virusscan at Virustotal, healtaskbarrows.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/6ec90603ee8b170387a532eabce28d698b92e05aff3f4ec39361e55ad3f28694/detection/u-6ec90603ee8b170387a532eabce28d698b92e05aff3f4ec39361e55ad3f28694-1722769870
)  
[Virusscan at Virustotal, healtaskbarrows32.exe 32bit-exe, Check here](https://www.virustotal.com/gui/url/2e672f9636e7bb207a88571cc87285c18b4f0eae477da18f9a1857cb52f1da6a/detection/u-2e672f9636e7bb207a88571cc87285c18b4f0eae477da18f9a1857cb52f1da6a-1722769871
)  
Use [CTRL] + Click to open in a new window! 
