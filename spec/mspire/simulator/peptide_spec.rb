require 'spec_helper'

require 'mspire'
require 'mspire/simulator/peptide'

describe Mspire::Simulator::Peptide do
  # the interface has dramatically changed
  xit "creates a peptide object given an amino acid sequence and charge state" do 
    pep = Mspire::Simulator::Peptide.new("HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR",2)
    pep.should be_a(Mspire::Simulator::Peptide)
    pep.sequence.should == "HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR"
    pep.mono_mz.should == 1939.3147555802952
    #Contains the core theoretical spectrum
    pep.core_mzs[0].round.should == 1938
    pep.core_ints[0].round.should == 42
  end
end
