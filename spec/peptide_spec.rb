#peptide_spec.rb

require 'mspire'
require 'ms/sim_peptide'

describe MS::Peptide do
  it "Creates a peptide object given a amino acid sequence" do 
    pep = MS::Peptide.new("HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR")
    pep.should be_a(MS::Peptide)
    pep.sequence.should == "HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR"
    pep.mz.should == 1286.2009040485332
  end
  
  it "Can also be initialized with retention time and intensity can be set." do
    rt = 10.0
    pep = MS::Peptide.new("HSVVVPYEPPEVGSDCTTIHYNYMCNSSCMGGMNR",rt)
    pep.rt.should == 10.0
    pep.int = 100.1
    pep.int.should == 100.1
  end
end
