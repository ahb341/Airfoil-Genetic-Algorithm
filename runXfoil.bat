@echo off
set App=xfoil.exe
set Delay=45
set killer=%temp%\kill.bat
echo > "%killer%" ping localhost -n %Delay% ^> nul
echo>> "%killer%" tasklist ^| find /i "%App%" ^> nul ^&^& taskkill /f /im %App%
start /b "Timeout" "%killer%"
%App%<.\sampleData\GA.run