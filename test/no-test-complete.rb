require 'test/unit'
$:.unshift File.dirname(__FILE__) + '/../lib'
p $:
require 'rb-readline'
$:.shift


Readline.completion_proc=Proc.new{|args| ['']}

class TC_Complete < Test::Unit::TestCase
   def test_basic
     RbReadline.instance_variable_set('@rl_line_buffer', 'foo')
     p Readline.line_buffer
     p RbReadline.rl_insert_completions(false, "\t")
     p Readline.line_buffer
     assert true
   end
end
