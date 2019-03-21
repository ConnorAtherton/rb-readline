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
        # normal entry
        str = String.new
        loop do # read the prompt in
          t = m.read(1)
          str << t
          break if t == " "
        end
        usr_saw << str
        m.puts "pty hello!"
        sleep 0.2
        usr_saw << m.gets # rawified pty hello

        # now use the up arrow and home key, saving output after each
        str = String.new
        loop do # read the prompt in
          t = m.read(1)
          str << t
          break if t == " "
        end
        usr_saw << str
        m.print "\e[A"
        sleep 0.2 #sleeps are to avoid long sequences being cut in half with readpartial
        usr_saw << m.readpartial(100) # original

        m.print "up"
        sleep 0.2
        usr_saw << m.readpartial(100) # up

        m.print "\e[H"
        sleep 0.1
        usr_saw << m.readpartial(100) # move to start

        "and: ".each_char do |ch|
          m.print ch
          sleep 0.1
          usr_saw << m.readpartial(100) # apty..., npty..., etc
        end

        m.puts ""
        sleep 0.2
        usr_saw << m.gets # rawified pty hello

        # search with success
        str = String.new
        loop do # read the prompt in
          t = m.read(1)
          str << t
          break if t == " "
        end
        usr_saw << str

        m.print "\C-r" # reverse search
        sleep 0.2
        usr_saw << m.readpartial(100) # prompt

        m.print "d"
        sleep 0.2
        usr_saw << m.readpartial(100) # find

        m.print "\e[D" # left
        sleep 0.2
        usr_saw << m.readpartial(200) # accept suggestion

        m.puts ""
        sleep 0.2
        usr_saw << m.gets # rawified pty hello

        # search with excape
        str = String.new
        loop do # read the prompt in
          t = m.read(1)
          str << t
          break if t == " "
        end
        usr_saw << str

        m.print "\C-r" # reverse search
        sleep 0.2
        usr_saw << m.readpartial(100) # prompt

        m.print "\e" # escape
        sleep 0.2
        usr_saw << m.readpartial(100) # esc

        m.print "d"
        sleep 0.2
        usr_saw << m.readpartial(100) # just d

        m.puts ""
        sleep 0.2
        usr_saw << m.gets # rawified pty hello
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
