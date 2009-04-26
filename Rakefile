require 'rake/packagetask'

$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'readline'

version = Readline::RB_READLINE_VERSION

Rake::PackageTask.new('rb-readline', version) do |pkg|
  pkg.need_zip = true
  pkg.package_files.include("examples/*.rb")
  pkg.package_files.include("lib/*.rb")
  pkg.package_files.include("test/*.rb")
  pkg.package_files.include("README", "LICENSE", "Rakefile", "setup.rb")
end
