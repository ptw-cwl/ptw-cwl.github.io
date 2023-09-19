rem 作者: ptw-cwl
rem 个人网站: ptw-cwl.com
rem 如有侵权，请联系删除。

@echo off
chcp 65001 > nul
setlocal

rem 删除当前文件夹中的所有 .bak 文件
rem /s：递归地搜索子文件夹。
rem /q：不显示删除确认提示，静默模式。
del *.bak /s /q

rem 暂停以便查看输出
pause

endlocal