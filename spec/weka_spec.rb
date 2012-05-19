#weka_spec.rb

require 'mspire'
require 'ms/sim_peptide'
require 'ms/rt/weka'

describe MS::Weka do 
  
  it "Uses weka model to predict retention times" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY",1)
    peptides<<MS::Peptide.new("PRINCE",2)
    peptides<<MS::Peptide.new("PEPTIDE",3)
    
    predicted = MS::Weka.predict_rts(peptides)
    predicted[0].p_rt.should_not == 0
  end

end
