require 'test/unit'
require 'fileutils'
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib/"
require 'readline'

class TC_FILENAME_COMPLETION_PROC < Test::Unit::TestCase

  SEP = File::SEPARATOR
  COMP_TEST_DIR = "comp_test#{SEP}"
  SUB_DIR = "#{COMP_TEST_DIR}a_sub_dir#{SEP}"
  SUB_SUB_DIR = "#{SUB_DIR}another_sub_dir#{SEP}"
  DIR_WITH_SPACES = "#{COMP_TEST_DIR}dir with spaces#{SEP}"
  SUB_DIR_WITH_SPACES = "#{DIR_WITH_SPACES}sub_dir with spaces#{SEP}"

  # This creates:
  #
  #   comp_test/
  #     abc
  #     aaa
  #     a_sub_dir/
  #       abc
  #       aaa
  #       another_sub_dir/
  #         aaa
  #     dir with spaces/
  #       filename with spaces
  #       sub dir with spaces/
  #         another filename with spaces
  def setup
    FileUtils.mkdir_p("#{SUB_SUB_DIR}")
    FileUtils.mkdir_p("#{SUB_DIR_WITH_SPACES}")
    @comp_test_dir = Dir.new COMP_TEST_DIR
    @sub_dir = Dir.new SUB_DIR
    @sub_sub_dir = Dir.new SUB_SUB_DIR
    @dir_with_spaces = Dir.new DIR_WITH_SPACES
    @sub_dir_with_spaces = Dir.new SUB_DIR_WITH_SPACES

    FileUtils.touch("#{@comp_test_dir.path}abc")
    FileUtils.touch("#{@comp_test_dir.path}aaa")
    FileUtils.touch("#{@sub_dir.path}abc")
    FileUtils.touch("#{@sub_dir.path}aaa")
    FileUtils.touch("#{@sub_sub_dir.path}aaa")
    FileUtils.touch("#{@dir_with_spaces.path}filename with spaces")
    FileUtils.touch("#{@sub_dir_with_spaces.path}another filename with spaces")

    # The previous Dir.new calls seem to cache the dir entries on Windows.
    @comp_test_dir = Dir.new COMP_TEST_DIR
    @sub_dir = Dir.new SUB_DIR
    @sub_sub_dir = Dir.new SUB_SUB_DIR
    @dir_with_spaces = Dir.new DIR_WITH_SPACES
    @sub_dir_with_spaces = Dir.new SUB_DIR_WITH_SPACES
  end

  def teardown
    FileUtils.rm_r(COMP_TEST_DIR)
  end

  def test_listing_files_in_cwd
    Dir.chdir(COMP_TEST_DIR) do
      entries = Dir.entries(".").select { |e| e[0,1] == "a" }
      assert_equal entries, Readline::FILENAME_COMPLETION_PROC.call("a")
    end
  end

  def test_list_files_in_sub_directories
    entries = @sub_dir.entries.select { |e| e[0,1] == "a" }
    entries.map! { |e| "#{@sub_dir.path}#{e}" }
    assert_equal entries, Readline::FILENAME_COMPLETION_PROC.call("#{@sub_dir.path}a")

    entries = @sub_sub_dir.entries - %w( . .. )
    entries.map! { |e| "#{@sub_sub_dir.path}#{e}" }
    assert_equal entries, Readline::FILENAME_COMPLETION_PROC.call("#{@sub_sub_dir.path}")
  end

  def test_list_files_and_directories_with_spaces
    entries = @comp_test_dir.entries.select { |e| e[0,1] == "d" }
    entries.map! { |e| @comp_test_dir.path + e }
    assert_equal entries, Readline::FILENAME_COMPLETION_PROC.call("#{@comp_test_dir.path}d")

    entries = @dir_with_spaces.entries - %w( . .. )
    entries.map! { |e| @dir_with_spaces.path + e }
    assert_equal entries, Readline::FILENAME_COMPLETION_PROC.call("#{@dir_with_spaces.path}")
  end
end
