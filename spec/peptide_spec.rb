#peptide_spec.rb

require 'mspire'
require 'ms/sim_peptide'

describe MS::Peptide do
  it "Creates a peptide object given an amino acid sequence" do 
    pep = MS::Peptide.new("HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR")
    pep.should be_a(MS::Peptide)
    pep.sequence.should == "HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR"
    pep.mono_mz.should == 4490.98980760639
    #Contains the core theoretical spectrum
    pep.core_mzs[0].round.should == 4489
    pep.core_ints[0].round.should == 8
  end
end
