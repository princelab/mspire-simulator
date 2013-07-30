require 'spec_helper'

describe "mspire-simulator commandline" do
  it "Gathers parameters from the cmd line and runs the simulator; If no params are given or --help a help message is displayed" do
    output = `ruby bin/mspire-simulator --help`
    output.should =~ /where/
  end
end
