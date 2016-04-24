# coding: utf-8
# A Simple Interactive Ruby Environment

require 'pp'

if ARGV[0] == 'local'
  require_relative '../lib/readline'
else
  require 'readline'
end

class SIRE
  #Set up the interactive session.
  def initialize
    @_done = false
  end

  #Quit the interactive session.
  def q
    @_done = true
    puts
    "Quit command."
  end

  #Test spawning a process. This breaks the readline gem.
  #For example try $run "ls"
  def run(command)
    IO.popen(command, "r+") do |io|
      io.close_write
      return io.read.split
    end
  end

  #Execute a single line.
  def exec_line(line)
    result = eval line
    pp result unless line.length == 0

  rescue Interrupt => e
    puts "\nExecution Interrupted!"
    puts "\n#{e.class} detected: #{e}\n"
    puts e.backtrace
    puts "\n"

  rescue Exception => e
    puts "\n#{e.class} detected: #{e}\n"
    puts e.backtrace
    puts
  end

  #Run the interactive session.
  def run_sire
    puts
    puts "Welcome to a Simple Interactive Ruby Environment"
    puts
    puts "rb-readline version = #{RbReadline::RB_READLINE_VERSION}"
    puts
    puts "Use the command 'q' to quit."
    puts "To see the console handle issue try: run 'ls'"
    puts
    puts

    until @_done
      exec_line(Readline.readline("SIRE>", true))
    end

    puts "\n\n"
  end

end

if __FILE__ == $0
  SIRE.new.run_sire
end
