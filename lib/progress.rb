
module Progress
  module_function
  # TODO Ryan: update this to handle a single message instantiation and then updates in the progress... Then it won't have to rewrite the message as often, nor process things as often
  def progress(message, num, time = '')
    # move cursor to beginning of line
    cr = "\r"           

    # ANSI escape code to clear line from cursor to end of line
    # "\e" is an alternative to "\033"
    # cf. http://en.wikipedia.org/wiki/ANSI_escape_code
    clear = "\e[0K"     

    # reset lines
    reset = cr + clear
    if time == ''
      print "#{reset} #{message}" + "#{num}%".rjust(60-message.length)
      $stdout.flush
    else
      str = "#{reset} #{message}" + "#{num}%".rjust(60-message.length)
      print  str + "Took: #{"%.2f" % time} sec.".rjust(100-str.length)
      $stdout.flush
    end
  end
end
