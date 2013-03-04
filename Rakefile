require 'rubygems/package_task'
require 'rake/testtask'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rbreadline'

spec = eval(File.open('rb-readline.gemspec').read, nil, 'rb-readline.gemspec')
spec.files = FileList["{examples,lib,test}/**/*.rb",
  "README.rdoc", "LICENSE", "CHANGES", "Rakefile", "setup.rb"]

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
end

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

desc "Install the gem locally"
task :install => :gem do
  Dir.chdir(File.dirname(__FILE__)) do
    sh %{gem install --local pkg/#{spec.name}-#{spec.version}}
  end
end

desc "The default is to test everything."
task :default => :test
