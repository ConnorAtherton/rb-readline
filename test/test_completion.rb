require "test/unit"
require "fileutils"
require 'timeout'
require "readline"

class TestCompletion < Test::Unit::TestCase
  include RbReadline

  def filename_quoting_function(filename, mtype, quote_char)
    @rl_filename_quote_characters.each_char do |c|
      filename.gsub!(c, "\\#{c}")
    end
    filename
  end

  def setup
    FileUtils.mkdir_p "completer_test_dir/a b"
    @rl_completion_word_break_hook, @rl_char_is_quoted_p = nil
    @rl_basic_quote_characters, @rl_special_prefixes = nil
    @rl_completer_word_break_characters = Readline.basic_word_break_characters
    @rl_completer_quote_characters = "\\"
    @rl_filename_quote_characters = " "
    @rl_byte_oriented = true
    @rl_filename_quoting_desired = true
    @rl_filename_completion_desired = true

    @rl_filename_quoting_function = :filename_quoting_function
  end

  def teardown
    FileUtils.rm_r "completer_test_dir"
  end

  def set_line_buffer(text)
    @rl_line_buffer = text
    @rl_point = @rl_line_buffer.size
    @rl_line_buffer << 0.chr
  end

  def test__find_completion_word_doesnt_hang_on_completer_quote_character
    set_line_buffer "completer_test_dir/a\\ b"

    assert_nothing_raised do
      Timeout::timeout(3) do
        assert_equal([ "\000", true, "\000" ], _rl_find_completion_word)
      end
    end
  end

  def test__find_completion_word_without_quote_characters
    set_line_buffer "completer_test_dir/a"
    assert_equal([ "\000", false, "\000" ], _rl_find_completion_word)
  end

  def test_make_quoted_replacement_calls_filename_quoting_function
    match = RbReadline::SINGLE_MATCH

    assert_equal "dir/with\\ space", make_quoted_replacement("dir/with space", RbReadline::SINGLE_MATCH, 0.chr)
  end
end
