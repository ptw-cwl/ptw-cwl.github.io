# 保存为 process_csv.rb

# 指定要处理的 CSV 文件路径作为参数
csv_files = Dir['assets/websites/*.csv']

csv_files.each do |csv_file|
  puts "Processing CSV file: #{csv_file}"
  skip_header = true

  File.open(csv_file, "r:UTF-8") do |file|
    file.each_line do |line|
      # 去除每行末尾的换行符
      line.chomp!

      if skip_header
        skip_header = false
      else
        # 使用逗号分隔每一行的值
        values = line.split(',')

        # 输出每列的值
        puts values[0]
        puts values[1]
        puts values[2]
        puts values[3]
        puts values[4]
        puts
      end
    end
  end
end
