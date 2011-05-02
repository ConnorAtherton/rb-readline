require 'test/unit'
require 'rbconfig'

# Path name of Ruby interpreter we were invoked with.
def ruby_path
  File.join(%w(bindir RUBY_INSTALL_NAME).map{|k| RbConfig::CONFIG[k]})
end

# The null_lb.rb test has to be run inside a fresh Ruby instance. 
class TC_RbReadlineLineBufferDriver < Test::Unit::TestCase
  def test_driver
    test_file = File.join(File.dirname(__FILE__), 'null_lb.rb')
    system(ruby_path, test_file)
    assert_equal 0, $?.exitstatus
  end
end
