# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'winslow/version'

Gem::Specification.new do |gem|
  gem.platform = Gem::Platform::RUBY
  gem.name = 'winslow'
  gem.version = Winslow::VERSION
  gem.summary = 'Helps create wizards that can span multiple applications.'
  gem.description = 'Helps create wizards that can span multiple applications.'

  gem.required_ruby_version = '>= 1.8.7'

  gem.author = 'Adam Vaughan'
  gem.email = 'ajv@absolute-performance.com'
  gem.homepage = 'http://www.absolute-performance.com'

  gem.files = Dir['VERSION', 'README.md', 'app/**/*', 'lib/**/*']
  gem.require_path = 'lib'

  gem.add_dependency 'rails', '< 4.2'
end
