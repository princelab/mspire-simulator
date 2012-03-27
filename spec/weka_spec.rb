#weka_spec.rb

require 'mspire'
require 'ms/sim_peptide'
require 'ms/rt/weka'

describe MS::Weka do 
  
  it "Uses weka model to predict retention times" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    
    predicted = MS::Weka.predict_rts(peptides)
    predicted[0].p_rt.should_not == 0
  end

end
