
module Progress
  module_function
  # ANSI escape code to clear line from cursor to end of line
  # "\e" is an alternative to "\033"
  # cf. http://en.wikipedia.org/wiki/ANSI_escape_code
  @reset = "\r\e[OK"
  def initialize(message, time = nil)
    @message = message
    @time = time ? time : Time.now
  end
  def progress(num, message_addition = nil)
    # move cursor to beginning of line
    message = @message+message_addition
    # reset lines
    print "#{@reset} #{message}" + "#{num}%".rjust(60-message.length)
    $stdout.flush
  end
  def finish!(message_addition = nil)
    time = Time.now - @time
    message = @message + message_addition
    str = "#{@reset} #{message}" + "#{num}%".rjust(60-message.length)
    print  str + "Took: #{"%.2f" % time/1000.0} sec.".rjust(100-str.length)
    $stdout.flush
    @message, @time = nil, nil
  end
  alias :progress, :update
end
