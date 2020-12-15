@cd /D %~dp0
@cd jgomas/bin/mas
start /B jgomas_manager_ALLIEDvsAXIS.bat
@timeout 5
start /B jgomas_launcher_ALLIEDvsAXIS.bat
@cd ../render/w32
@timeout 5
@run_jgomasrender