require_relative '../assets/scripts/test'

#在渲染整个网站之前运行
Jekyll::Hooks.register :site, :pre_render do |site|
  Rake::Task['default'].invoke
end