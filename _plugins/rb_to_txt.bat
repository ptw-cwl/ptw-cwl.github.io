rem 作者: ptw-cwl
rem 个人网站: ptw-cwl.com
rem 如有侵权，请联系删除。

@echo off

chcp 65001 > nul

setlocal

echo "开始运行"
call ruby ../assets/scripts/rb_to_txt.rb
echo "运行完毕"

pause

rem endlocal