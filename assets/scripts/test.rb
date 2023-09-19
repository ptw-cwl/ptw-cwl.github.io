#作者: ptw-cwl
#个人网站: ptw-cwl.com
#如有侵权，请联系删除。

require_relative 'module'

puts '开始测试'

task :default do
  run('test')
end

task :test do
  run('process_csv')
end

task :process_csv do
# 指定顶级目录
top_directory = 'assets/websites'

# 调用递归函数，从顶级目录开始读取 .csv 文件
read_csv_files(top_directory)
end

require 'csv'
require 'fileutils'

# 定义递归函数，读取指定目录下的所有 .csv 文件
def read_csv_files(directory)
  Dir.foreach(directory) do |item|
    next if item == '.' || item == '..' # 跳过 . 和 .. 目录

    item_path = File.join(directory, item)

    if File.directory?(item_path)
      # 如果是目录，递归调用 read_csv_files 函数
      puts "正在读取目录：#{item_path}"
      read_csv_files(item_path)
    elsif item.downcase.end_with?('.csv')
      # 如果是 .csv 文件，执行读取操作
      puts "正在读取文件：#{item_path}"
      read_web_site_csv(item_path)
    end
  end
end

def read_web_site_csv(csv_file_path, generate_file_suffix = '.md')

  parts = File.basename(csv_file_path, File.extname(csv_file_path)).split("-")
  sort = parts[0]
  file_name = parts[1]

# 使用 File.dirname 获取当前文件的目录
current_directory = File.dirname(csv_file_path)
parent_directory_name = File.basename(current_directory)
permalink = File.join("website/#{current_directory.split("assets/websites/")[1]}", file_name)
  posts = process_csv_data(csv_file_path,parent_directory_name, permalink,sort)

  # 构建输出文件路径，使用与 CSV 文件相同的名称但是扩展名为 .md（默认）
  output_file_path = File.join("_websites/#{current_directory.split("assets/websites/")[1]}", file_name + generate_file_suffix)

  # 获取输出文件的目录
  output_directory = File.dirname(output_file_path)

  # 检查输出目录是否存在，如果不存在则创建
  unless Dir.exist?(output_directory)
    FileUtils.mkdir_p(output_directory)
    puts "创建目录：#{output_directory}"
  end

  # 检查文件是否存在，如果存在则删除
  if File.exist?(output_file_path)
    File.delete(output_file_path)
    puts "删除文件：#{output_file_path}"
  end

  # 将数据结构写入文本文件
  File.write(output_file_path, posts.join("\n"))

  puts "数据已写入文件：#{output_file_path}"
end

def process_csv_data(csv_file_path,parent_directory_name,permalink, sort)

  posts = []
  # 构建 YAML 数据
  posts << "---"
  posts << "sort: #{sort}"
  if parent_directory_name != "websites"
  posts << "isPresentSubcategory: true"
  posts << "name: #{parent_directory_name}"
  end
  posts << "permalink:  \"#{permalink}\""
  posts << "websites:"

  CSV.foreach(csv_file_path, headers: true, encoding: 'ISO-8859-1:utf-8') do |row|
    # 检查是否存在有效的 name 和 url
    if row['name'].to_s.strip != '' && row['url'].to_s.strip != ''
      posts << "    - name: #{row['name']}"
      posts << "      url: #{row['url']}"
      posts << "      description: #{row['description']}"
      if row['isHide'].to_i == 1
        posts << "      isHide: true"
      end

      if row['notes'].to_s.strip != ''
        posts << "      notes: #{row['notes']}"
      end
    end
  end
  posts << "---"
  posts << "作者: ptw-cwl"
  posts << "个人网站: ptw-cwl.com"
  posts << "如有侵权，请联系删除。"

  return posts
end




# 检查是否是直接运行的脚本
if File.basename($0) == File.basename(__FILE__)
  # 如果是直接运行的脚本，执行默认任务
  run('default')
end