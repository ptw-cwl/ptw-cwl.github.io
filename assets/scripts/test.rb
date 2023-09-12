require_relative 'module'

puts '开始测试'

task :default do
  run('test')
end

task :test do
  test1('0','1','2')
  test1
end

def test1(content1 = 'test1', content2 = 'test2', content3 = 'test3')
  puts content1
  puts content2
  puts content3
end


