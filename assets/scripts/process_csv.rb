#作者: ptw-cwl
#个人网站: ptw-cwl.com
#如有侵权，请联系删除。

require 'csv'

task :default do
  readWebSiteCsv('assets/websites/0-平台.csv')
end

def  readWebSiteCsv(csvFilePath)
# 读取 CSV 文件
CSV.foreach(csvFilePath, headers: true, encoding: 'ISO-8859-1:utf-8') do |row|
  name = row['name']
  url = row['url']
  description = row['description']
  isHide = row['isHide']
  notes = row['notes']

  # 在这里可以使用读取到的数据进行操作
  puts "Name: #{name}"
  puts "URL: #{url}"
  puts "Description: #{description}"
  puts "IsHide: #{isHide}"
  puts "Notes: #{notes}"
  puts "-----------------------------------"
end
end