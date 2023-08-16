# frozen_string_literal: true

# source "http://rubygems.org"
source 'https://gems.ruby-china.com'


gem "jekyll"

group :jekyll_plugins do
  gem 'jekyll-sitemap'
  gem 'jekyll-feed'
  gem 'jekyll-seo-tag'
end

install_if -> { RUBY_PLATFORM =~ /mingw|mswin|java/ } do
  gem 'tzinfo', '~> 1.2'
  gem 'tzinfo-data'
end

gem 'wdm', '>= 0.1.0' if Gem.win_platform?

gem 'rake'
