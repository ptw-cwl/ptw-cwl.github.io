@echo off
chcp 65001 > nul
setlocal

echo "开始运行"
call rake process_csv
echo "运行完毕"

pause

rem endlocal
