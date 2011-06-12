require 'test/unit'
require 'rbconfig'

def RbConfig.ruby
  File.join(RbConfig::CONFIG['bindir'],  
            RbConfig::CONFIG['RUBY_INSTALL_NAME'] + 
            RbConfig::CONFIG['EXEEXT'])
end unless defined? RbConfig.ruby

class TestRequireOrder < Test::Unit::TestCase
  def test_basic
    dir = File.dirname(__FILE__)
    output = `#{RbConfig.ruby} -I .. #{dir}/require-order.rb 2>&1`
    assert(output.empty?, 
           "Running require-order should not produce any warnings, got:
#{output}")
  end
end
