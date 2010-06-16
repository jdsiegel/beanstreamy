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
    gemspec.summary = "A Beanstream utility library for Rails"
    gemspec.description = "Currently provides a helper method for rendering forms that will submit to the beanstream hosted payment gateway"
    gemspec.email = "jeff@stage2.ca"
    gemspec.homepage = "http://github.com/jdsiegel/beanstreamy"
    gemspec.authors = ["Jeff Siegel"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

