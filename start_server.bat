rem 作者: ptw-cwl
rem 个人网站: ptw-cwl.com
rem 如有侵权，请联系删除。

rem 这是一个特殊的命令，它告诉批处理解释器在执行脚本时不要显示批处理命令本身。
@echo off

rem 在批处理文件开头添加指定编码的命令。 utf-8
chcp 65001 > nul

rem 这是一个用于创建局部环境的命令。它使得在脚本中设置的变量只在脚本执行期间有效，并且不会影响到批处理脚本外的环境。
setlocal

echo "开始运行"
call rake
echo "运行完毕"

rem 添加一个 pause 命令可以使 cmd 窗口在执行完命令后不会立即关闭 点击任意键会关闭
pause

rem 结束局部环境并清除变量
rem endlocal


