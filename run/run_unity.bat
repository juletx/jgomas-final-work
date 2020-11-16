@cd /D %~dp0
@cd ../jgomas/bin/mas
start /B jgomas_manager.bat
@timeout 5
start /B jgomas_launcher.bat
@cd ../../../JGOMAS_Unity_Windows
@timeout 5
start /B JGomas_w64.exe