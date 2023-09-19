#作者: ptw-cwl
#个人网站: ptw-cwl.com
#如有侵权，请联系删除。

require_relative 'module'

puts '开始转换'

task :default do
  run('convert')
end

task :convert do
  convert_file_extension('./','.rb','.txt')
end


# 检查是否是直接运行的脚本
if File.basename($0) == File.basename(__FILE__)
  # 如果是直接运行的脚本，执行默认任务
  run('default')
end