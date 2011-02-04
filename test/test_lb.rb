require 'test/unit'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'readline'
$:.shift

class TC_RbReadlineLineBufferSetGet < Test::Unit::TestCase
  def test_line_buffer_set_get
    RbReadline.rl_initialize
    assert_equal '', Readline.line_buffer
    RbReadline.rl_line_buffer = 'foo'
    # Readline.line_buffer is same as RbReadline.rl_buffer
    assert_equal 'foo', Readline.line_buffer 
  end
end
