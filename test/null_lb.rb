require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rbreadline')

class TC_RbReadlineLineBuffer < Test::Unit::TestCase
   def test_rl_delete_text
     assert_nothing_raised do
       lb = RbReadline.rl_line_buffer
       assert_equal(nil, lb)
     end
   end
end
