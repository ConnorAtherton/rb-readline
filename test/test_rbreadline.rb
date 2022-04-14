require 'minitest/autorun'
require 'rbreadline'
require 'pty'
require 'timeout'

class TestRbReadline < Minitest::Test
  def test_versions
    assert_equal('5.2', RbReadline::RL_LIBRARY_VERSION)
    assert_equal(0x0502, RbReadline::RL_READLINE_VERSION)
  end

  def test_rl_adjust_point
    encoding_name = RbReadline.instance_variable_get(:@encoding_name)
    RbReadline.instance_variable_set(:@encoding_name, Encoding.find('UTF-8'))

    assert_equal(0, RbReadline._rl_adjust_point("a".force_encoding('ASCII-8BIT'), 0))
    assert_equal(0, RbReadline._rl_adjust_point("a".force_encoding('ASCII-8BIT'), 1))
    assert_equal(0, RbReadline._rl_adjust_point(("a" * 40).force_encoding('ASCII-8BIT'), 0))
    assert_equal(0, RbReadline._rl_adjust_point(("a" * 40).force_encoding('ASCII-8BIT'), 40))
    assert_equal(2, RbReadline._rl_adjust_point(("\u3042" * 10).force_encoding('ASCII-8BIT'), 1))
    assert_equal(1, RbReadline._rl_adjust_point(("\u3042" * 15).force_encoding('ASCII-8BIT'), 38))
  ensure
    RbReadline.instance_variable_set(:@encoding_name, encoding_name)
  end if defined?(Encoding)

  # Tests inside a pty/pts system
  # The test does one basic input, one using escape sequences, one using
  # reverse search, and one that exits reverse search
  def test_pts
    usr_saw = [] # save all output to here from the user thread
    Timeout::timeout(10) do # timeout in case read hangs
      m, s = PTY.open # generate a new pty/pts pair

      f = Thread.new do # the user thread to manage the master of the pair (pty)
        first = true
        sequences = [ # comma-seperated key sequences
          "pty hello!\n", #normal entry
          "\e[A,up,\e[H,a,n,d,:, ,\n", # up arrow, "up", home key, "and: "
          "\C-r,d,\e[D,\n", # ^R (reverse search), d, left arrow (accept), enter
          "\C-r,\e,d,\n", # ^R, escape key, d, enter
        ]
        sequences.each do |seqcsv|
          # normal entry
          str = String.new
          # read the prompt in
          loop do
            t = m.read(1)
            str << t
            break if t == " "
          end
          if first # remove startup sequences from some terms
            first = false
            str = str[(str.rindex("pts> ") || 0)..-1] #trim startup sequence
          end
          usr_saw << str
          # send output after prompt for each key sequence
          seqcsv.split(",").each do |chars|
            m.print chars
            sleep 0.1
            usr_saw << (chars.end_with?("\n") ? m.gets : m.readpartial(200))
          end
        end
      end

      # assign the readline io to the slave of the pair (pts)
      RbReadline.rl_instream = s
      RbReadline.rl_outstream = s

      # normal entry
      read = RbReadline.readline('pts> ')
      assert_equal("pty hello!", read)
      RbReadline.add_history(read)

      # up arrow
      read = RbReadline.readline('2pts2> ')
      assert_equal("and: pty hello!up", read)

      # search
      RbReadline.add_history("don quixote")
      read = RbReadline.readline('3pts% ')
      assert_equal("don quixote", read)

      # search escape
      RbReadline.add_history("don quixote")
      read = RbReadline.readline('4pts$ ')
      assert_equal("d", read)
    end
    sleep 1 # wait for user thread to exit
    prompt_rights = "\e[C" * "2pts2> ".length # the right arrow to move past the prompt

    # validate the user saw everything we expected
    assert_equal(["pts> ", "pty hello!\r\r\n",
    "2pts2> ", "pty hello!" , # up arrow
      "up", #"up"
      "\r#{prompt_rights}", # home key
      "apty hello!up\r#{prompt_rights}#{"\e[C"*1}", #a
      "npty hello!up\r#{prompt_rights}#{"\e[C"*2}", #n
      "dpty hello!up\r#{prompt_rights}#{"\e[C"*3}", #d
      ":pty hello!up#{"\b" * 12}", #:
      " pty hello!up#{"\b" * 12}", #" "
      "\r\r\n",
    "3pts% ",  #prompt
      "\r(reverse-i-search)`': ",  #ctrl-R
      "\b\b\bd': don quixote#{"\b" * "don quixote".length}", #d
      "\r#{"\e[P" * 17}3pts%\e[C",  #accept
      "\r\r\n",
    "4pts$ ", #prompt
      "\r(reverse-i-search)`': ",  #ctrl-R
      "\r4pts$ \e[K", # esc
      "d",
      "\r\r\n"], usr_saw) # output should not see anything else
  end
end
