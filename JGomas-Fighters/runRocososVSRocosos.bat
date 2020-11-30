@cd /D %~dp0
@cd jgomas/bin/mas
start /B jgomas_manager.bat
@timeout 5
start jgomas_launcher-RocososVSRocosos.bat 
@cd ../render/w32
@timeout 5
@run_jgomasrender