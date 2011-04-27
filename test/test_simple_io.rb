require "test/unit"
require "childprocess"
require "tempfile"
require "readline"

module RbReadline
  class << self
    attr_accessor :_rl_term_mm, :term_has_meta
  end
end

module ChildProcessHelperMethods
  # If the terminal has a meta key, seek past the shell code that enables it.
  def seek_past_meta
    @stdout.rewind
    RbReadline._rl_init_terminal_io ENV["TERM"]
    if RbReadline.term_has_meta
      @stdout.seek(RbReadline._rl_term_mm.size)
    end
  end

  # Enter some text at the terminal.
  def input(text)
    pos = @stdout.pos
    @stdin << text
    sleep 0.2
    @stdout.seek(pos)
  end

  # Setup and run the child process.
  def setup_child_process(prompt)
    @process = ChildProcess.build("ruby", "#{File.dirname(__FILE__)}/bin/basic-readline", prompt)
    @process.duplex = true

    @stdout = Tempfile.new("readline-stdout")
    @stderr = Tempfile.new("readline-stderr")
    @process.io.stdout = @stdout
    @process.io.stderr = @stderr
    @process.start
    sleep 0.2
    @stdin = @process.io.stdin
    seek_past_meta
  end
end

# A simple first pass at some integration testing.
class TestSimpleIO < Test::Unit::TestCase
  include ChildProcessHelperMethods

  def teardown
    @process.stop
  end

  def test_sending_input_and_reading_output
    setup_child_process "> "

    assert_equal @stdout.read, "> "
    input "123\n"
    assert_equal @stdout.readline.chomp, "You typed: 123"
  end
end
