@echo off
set bin_path=D:\\modelism\\win32pe
call %bin_path%/vsim   -do "do {tb_display7_simulate.do}" -l simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
