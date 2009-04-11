# zlib.rb -- GNU Readline module
# Copyright (C) 1997-2001  Shugo Maed
#
# Ruby translation by Park Heesob phasis@gmail.com

module Readline

   require 'rbreadline'
   include RbReadline
   
   @completion_proc = nil
   @completion_case_fold = false

   def readline(prompt, add_history=nil)
      if $stdin.closed?
         raise IOError,"stdin closed"
      end

      RbReadline.rl_instream = $stdin
      RbReadline.rl_outstream = $stdout

      status = 0
      begin
         buff = RbReadline.readline(prompt)
      rescue Exception => e
         buff = nil
         RbReadline.rl_cleanup_after_signal()
         RbReadline.rl_deprep_terminal()
         raise e
      end

      if add_history && buff
         RbReadline.add_history(buff)
      end
      return buff ? buff.dup : nil
   end

   def self.input=(input)
      RbReadline.rl_instream = input
   end

   def self.output=(output)
      RbReadline.rl_outstream = output
   end

   def self.completion_proc=(proc)
      unless defined? proc.call
         raise ArgumentError,"argument must respond to `call'"
      end
      @completion_proc = proc
   end

   def self.completion_proc()
      @completion_proc
   end

   def self.completion_case_fold=(bool)
      @completion_case_fold = bool
   end

   def self.completion_case_fold()
      @completion_case_fold
   end

   def self.readline_attempted_completion_function(text,start,_end)
      proc = @completion_proc
      return nil if proc.nil?

      RbReadline.rl_attempted_completion_over = true

      case_fold = @completion_case_fold
      ary = proc.call(text)
      if ary.class != Array
         ary = Array(ary)
      else
         ary.compact!
      end

      matches = ary.length
      return nil if (matches == 0)
      result = Array.new(matches+2)
      for i in 0 ... matches
         result[i+1] = ary[i].dup
      end
      result[matches+1] = nil

      if(matches==1)
         result[0] = result[1].dup
      else
         i = 1
         low = 100000

         while (i < matches)
            if (case_fold)
               si = 0
               while ((c1 = result[i][si,1].downcase) &&
                  (c2 = result[i + 1][si,1].downcase))
                  break if (c1 != c2)
                  si += 1
               end
            else
               si = 0
               while ((c1 = result[i][si,1]) &&
                  (c2 = result[i + 1][si,1]))
                  break if (c1 != c2)
                  si += 1
               end
            end
            if (low > si)
               low = si
            end
            i+=1
         end
         result[0] = result[1][0,low]
      end

      result
   end

   def self.vi_editing_mode()
      RbReadline.rl_vi_editing_mode(1,0)
      nil
   end

   def self.emacs_editing_mode()
      RbReadline.rl_emacs_editing_mode(1,0)
      nil
   end

   def self.completion_append_character=(char)
      if char.nil?
         RbReadline.rl_completion_append_character = ?\0
      elsif char.length==0
         RbReadline.rl_completion_append_character = ?\0
      else
         RbReadline.rl_completion_append_character = char[0]
      end
   end

   def self.completion_append_character()
      if RbReadline.rl_completion_append_character == ?\0
         nil
      end
      return RbReadline.rl_completion_append_character.chr
   end

   def self.basic_word_break_characters=(str)
      RbReadline.rl_basic_word_break_characters = str.dup
   end

   def self.basic_word_break_characters()
      if RbReadline.rl_basic_word_break_characters.nil?
         nil
      else
         RbReadline.rl_basic_word_break_characters.dup
      end
   end

   def self.completer_word_break_characters=(str)
      RbReadline.rl_completer_word_break_characters = str.dup
   end

   def self.completer_word_break_characters()
      if RbReadline.rl_completer_word_break_characters.nil?
         nil
      else
         RbReadline.rl_completer_word_break_characters.dup
      end
   end

   def self.basic_quote_characters=(str)
      RbReadline.rl_basic_quote_characters = str.dup
   end

   def self.basic_quote_characters()
      if RbReadline.rl_basic_quote_characters.nil?
         nil
      else
         RbReadline.rl_basic_quote_characters.dup
      end
   end

   def self.completer_quote_characters=(str)
      RbReadline.rl_completer_quote_characters = str.dup
   end

   def self.completer_quote_characters()
      if RbReadline.rl_completer_quote_characters.nil?
         nil
      else
         RbReadline.rl_completer_quote_characters.dup
      end
   end

   def self.filename_quote_characters=(str)
      RbReadline.rl_filename_quote_characters = str.dup
   end

   def self.filename_quote_characters()
      if RbReadline.rl_filename_quote_characters.nil?
         nil
      else
         RbReadline.rl_filename_quote_characters.dup
      end
   end

   class History
      extend Enumerable
      def self.to_s
         "HISTORY"
      end

      def self.[](index)
         if index < 0
            index += RbReadline.history_length
         end
         entry = RbReadline.history_get(RbReadline.history_base+index)
         if entry.nil?
            raise IndexError,"invalid index"
         end
         entry.line.dup
      end

      def self.[]=(index,str)
         if index<0
            index += RbReadline.history_length
         end
         entry = RbReadline.replace_history_entry(index,str,nil)
         if entry.nil?
            raise IndexError,"invalid index"
         end
         str
      end

      def self.<<(str)
         RbReadline.add_history(str)
      end

      def self.push(*args)
         args.each do |str|
            RbReadline.add_history(str)
         end
      end

      def rb_remove_history(index)
         entry = RbReadline.remove_history(index)
         if (entry)
            val = entry.line.dup
            entry = nil
            return val
         end
         nil
      end

      def self.pop()
         if RbReadline.history_length>0
            rb_remove_history(RbReadline.history_length-1)
         else
            nil
         end
      end

      def self.shift()
         if RbReadline.history_length>0
            rb_remove_history(0)
         else
            nil
         end
      end

      def self.each()
         for i in 0 ... RbReadline.history_length
            entry = RbReadline.history_get(RbReadline.history_base + i)
            break if entry.nil?
            yield entry.line.dup
         end
         self
      end

      def self.length()
         RbReadline.history_length
      end

      def self.size()
         RbReadline.history_length
      end

      def self.empty?()
         RbReadline.history_length == 0
      end

      def self.delete_at(index)
         if index < 0
            i += RbReadline.history_length
         end
         if index < 0 || index > RbReadline.history_length - 1
            raise IndexError, "invalid index"
         end
         rb_remove_history(index)
      end

   end

   HISTORY = History

   class Fcomp
      def self.call(str)
         matches = RbReadline.rl_completion_matches(str,
         :rl_filename_completion_function)
         if (matches)
            result = []
            i = 0
            while(matches[i])
               result << matches[i].dup
               matches[i] = nil
               i += 1
            end
            matches = nil
            if (result.length >= 2)
               result.shift
            end
         else
            result = nil
         end
         return result
      end
   end

   FILENAME_COMPLETION_PROC = Fcomp

   class Ucomp
      def self.call(str)
         matches = RbReadline.rl_completion_matches(str,
         :rl_username_completion_function)
         if (matches)
            result = []
            i = 0
            while(matches[i])
               result << matches[i].dup
               matches[i] = nil
               i += 1
            end
            matches = nil
            if (result.length >= 2)
               result.shift
            end
         else
            result = nil
         end
         return result
      end
   end

   USERNAME_COMPLETION_PROC = Ucomp

   RbReadline.rl_readline_name = "Ruby"

   RbReadline.using_history()

   VERSION = RbReadline.rl_library_version

   module_function :readline

   RbReadline.rl_attempted_completion_function = :readline_attempted_completion_function

end
