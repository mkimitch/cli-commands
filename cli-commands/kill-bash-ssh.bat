@echo off
taskkill /IM bash.exe /F /T
taskkill /IM mintty.exe /F /T
taskkill /IM git.exe /F /T
taskkill /IM ssh-agent.exe /F /T
taskkill /IM ssh.exe /F /T
taskkill /IM Git for Windows.exe /F /T
echo All instances of Git for Windows processes have been terminated.
pause
