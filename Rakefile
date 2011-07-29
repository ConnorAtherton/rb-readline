require 'rubygems/package_task'
require 'rake/testtask'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rbreadline'

spec = Gem::Specification.new do |s|
  # basic information
  s.name        = "rb-readline"
  s.version     = RbReadline::RB_READLINE_VERSION
  s.platform    = Gem::Platform::RUBY

  # description and details
  s.summary     = 'Pure-Ruby Readline Implementation'
  s.description = "The readline library provides a pure Ruby implementation of the GNU readline C library, as well as the Readline extension that ships as part of the standard library."

  # requirements
  s.required_ruby_version = ">= 1.8.6"
  s.required_rubygems_version = ">= 1.3.5"

  # development dependencies
  s.add_development_dependency 'rake'

  # components, files and paths
  s.files = FileList["{examples,lib,test}/**/*.rb",
                      "README", "LICENSE", "CHANGES", "Rakefile", "setup.rb"]

  s.require_path = 'lib'

  # documentation
  s.rdoc_options << '--main'  << 'README' << '--title' << 'Rb-Readline - Documentation'

  s.extra_rdoc_files = %w(README LICENSE CHANGES)

  # project information
  s.homepage          = 'http://github.com/luislavena/rb-readline'
  s.licenses          = ['BSD']

  # author and contributors
  s.authors     = ['Park Heesob', 'Daniel Berger', 'Luis Lavena', 'Mark Somerville']
  s.email       = ['phasis@gmail.com', 'djberg96@gmail.com', 'luislavena@gmail.com', 'mark@scottishclimbs.com']
end

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
