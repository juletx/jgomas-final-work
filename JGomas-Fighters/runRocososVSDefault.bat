@cd /D %~dp0
@cd jgomas/bin/mas
start  jgomas_manager.bat
@timeout 5
start  jgomas_launcher-RocososVSDefault.bat > RocososVSDefault.txt
@cd ../render/w32
@timeout 5
@run_jgomasrender