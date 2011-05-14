# This file is the unit test that comes with MRI 1.8 located in
# test/readline/test_readline.rb

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rb-readline'
require 'readline'
$:.shift

if defined?(Readline) && !/EditLine/n.match(Readline::VERSION)

require "test/unit"
require "tempfile"

class TestReadline < Test::Unit::TestCase
  def test_readline
    puts "Skipping SAFE level testing..."
    return
    stdin = Tempfile.new("test_readline_stdin")
    stdout = Tempfile.new("test_readline_stdout")
    begin
      stdin.write("hello\n")
      stdin.close
      stdout.close
      line = replace_stdio(stdin.path, stdout.path) {
        Readline.readline("> ", true)
      }
      assert_equal("hello", line)
      assert_equal(true, line.tainted?)
      stdout.open
      assert_equal("> ", stdout.read(2))
      assert_equal(1, Readline::HISTORY.length)
      assert_equal("hello", Readline::HISTORY[0])
      assert_raises(SecurityError) do
        Thread.start {
          $SAFE = 1
          replace_stdio(stdin.path, stdout.path) do
            Readline.readline("> ".taint)
          end
        }.join
      end
      assert_raises(SecurityError) do
        Thread.start {
          $SAFE = 4
          replace_stdio(stdin.path, stdout.path) { Readline.readline("> ") }
        }.join
      end
    ensure
      stdin.close(true)
      stdout.close(true)
    end
  end

  def test_completion_append_character
    begin
      Readline.completion_append_character = "x"
      assert_equal("x", Readline.completion_append_character)
      Readline.completion_append_character = "xyz"
      assert_equal("x", Readline.completion_append_character)
      Readline.completion_append_character = nil
      assert_equal(nil, Readline.completion_append_character)
      Readline.completion_append_character = ""
      assert_equal(nil, Readline.completion_append_character)
    rescue NotImplementedError
    end
  end

  private

  def replace_stdio(stdin_path, stdout_path)
    open(stdin_path, "r"){|stdin|
      open(stdout_path, "w"){|stdout|
        orig_stdin = STDIN.dup
        orig_stdout = STDOUT.dup
        STDIN.reopen(stdin)
        STDOUT.reopen(stdout)
        begin
          yield
        ensure
          STDIN.reopen(orig_stdin)
          STDOUT.reopen(orig_stdout)
          orig_stdin.close
          orig_stdout.close
        end
      }
    }
  end
end

end
