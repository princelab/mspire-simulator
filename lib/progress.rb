
class Progress
  # ANSI escape code to clear line from cursor to end of line
  # "\e" is an alternative to "\033"
  # cf. http://en.wikipedia.org/wiki/ANSI_escape_code
  def initialize(message, time = nil)
    @message = message
    @time = time ? time : Time.now
    @reset = "\r\e[0K"
  end
  def progress(num, message_addition = "")
    message = @message+message_addition
    # reset lines
    print "#{@reset} #{message}" + "#{num}%".rjust(60-message.length)
    $stdout.flush
  end
  def finish!(message_addition = "")
    time = (Time.now - @time)/1000.0
    message = @message + message_addition
    str = "#{@reset} #{message}" + "100%".rjust(60-message.length)
    print  str + "Took: #{"%.2f" % time} sec.".rjust(100-str.length)
    $stdout.flush
  end
  alias :update :progress
end
