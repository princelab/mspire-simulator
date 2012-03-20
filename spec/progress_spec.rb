#progress_spec.rb

require 'progress'
require 'time'

describe Progress, "#progress" do
  it "Prints out a given message and percentage, refreshing the current line with each call." do
    101.times do |i|
      Progress.progress("Message:",i)
      sleep 0.01
    end
  end
  
  it "Also can take a final time to show how long a process took." do 
    start = Time.now
    101.times do |i|
      Progress.progress("Message:",i)
      sleep 0.01
    end
    Progress.progress("Message:",100,Time.now - start)
  end
end 
