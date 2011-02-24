require 'test/unit'
require 'fileutils'
$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib/"
require 'readline'

class TC_FILENAME_COMPLETION_PROC < Test::Unit::TestCase

  SEP = RbReadline::DIR_SEPARATOR
  COMP_TEST_DIR = "comp_test#{SEP}"
  SUB_DIR = "#{COMP_TEST_DIR}a_sub_dir#{SEP}"
  SUB_SUB_DIR = "#{SUB_DIR}another_sub_dir#{SEP}"

  def setup
    FileUtils.mkdir_p("#{SUB_SUB_DIR}")
    @comp_test_dir = Dir.new COMP_TEST_DIR
    @sub_dir = Dir.new SUB_DIR
    @sub_sub_dir = Dir.new SUB_SUB_DIR

    FileUtils.touch("#{@comp_test_dir.path}abc")
    FileUtils.touch("#{@comp_test_dir.path}aaa")
    FileUtils.touch("#{@sub_dir.path}abc")
    FileUtils.touch("#{@sub_dir.path}aaa")
    FileUtils.touch("#{@sub_sub_dir.path}aaa")

    # The previous Dir.new calls seem to cache the directory entries on Windows.
    @comp_test_dir = Dir.new COMP_TEST_DIR
    @sub_dir = Dir.new SUB_DIR
    @sub_sub_dir = Dir.new SUB_SUB_DIR
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
    assert_equal entries, Readline::FILENAME_COMPLETION_PROC.call(@sub_sub_dir.path)
  end
end
