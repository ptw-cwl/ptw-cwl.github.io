# frozen_string_literal: true

# 设置默认任务
task :default do 
  Rake::Task['start'].invoke
end


task :start do
  puts '开始清理 Jekyll 缓存'
  system('bundle exec jekyll clean')
  puts '开始安装依赖'
  system('bundle install')
  puts '开始运行服务器'
  system('bundle exec jekyll serve')
end
