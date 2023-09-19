#作者: ptw-cwl
#个人网站: ptw-cwl.com
#如有侵权，请联系删除。

require 'rake'
require 'fileutils'

def run(taskName)
  Rake::Task[taskName].invoke
end

def convert_file_extension(folder_path, old_extension, new_extension)
  puts "开始转换 #{old_extension} 为 #{new_extension}"
  # 获取指定文件夹中所有的文件路径
  file_paths = Dir.glob(File.join(folder_path, "*#{old_extension}"))

  file_paths.each do |file_path|
    # 构建新的文件路径，将旧扩展名替换为新扩展名
    new_file_path = file_path.sub(/#{Regexp.escape(old_extension)}$/, new_extension)

    # 重命名文件，将旧文件路径改为新文件路径
    FileUtils.mv(file_path, new_file_path)

    puts "已将 #{file_path} 更改为 #{new_file_path}"
  end
end