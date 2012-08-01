#peptide_spec.rb

require 'mspire'
require 'ms/sim_peptide'

describe MS::Peptide do
  it "Creates a peptide object given an amino acid sequence and charge state" do 
    pep = MS::Peptide.new("HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR",2)
    pep.should be_a(MS::Peptide)
    pep.sequence.should == "HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR"
    pep.mono_mz.should == 1939.3147555802952
    #Contains the core theoretical spectrum
    pep.core_mzs[0].round.should == 1938
    pep.core_ints[0].round.should == 42
  end
end
