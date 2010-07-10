require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the beanstreamy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the beanstreamy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Beanstreamy'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "beanstreamy"
    gemspec.summary = "A Beanstream utility library for Rails and ActiveMerchant"
    gemspec.description = "Adds activemerchant gateway support for hash validation, querying transactions, and submitting payment via hosted forms"
    gemspec.email = "jeff@stage2.ca"
    gemspec.homepage = "http://github.com/jdsiegel/beanstreamy"
    gemspec.authors = ["Jeff Siegel"]
    gemspec.add_dependency('activemerchant', '>= 1.5.1')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

