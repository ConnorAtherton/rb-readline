require 'test/unit'
require 'rbreadline'

class TC_RbReadline < Test::Unit::TestCase
   def test_versions
      assert_equal('5.2', RbReadline::RL_LIBRARY_VERSION)
      assert_equal(0x0502, RbReadline::RL_READLINE_VERSION)
   end

   def test_rl_delete_text
     RbReadline.rl_initialize
     assert_nothing_raised do
       RbReadline.rl_delete_text(0, 0)
     end
   end
end
