require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MSsimulate" do
  it "Gathers parameters from the cmd line and runs the simulator; If no params are -h a help message is displayed" do
    output = `ruby -I lib bin/ms-simulate.rb -h`
    output.should =~ /where/
  end
end
