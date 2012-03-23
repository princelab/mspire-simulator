#aa_spec.rb

require 'ms/sim_feature/aa'

describe MS::Feature::AA do 
  
  it "Accessing hydrophobicity value at pH of 2" do
    # A for alanine
    hydro = MS::Feature::AA::HYDROPHOBICTY["A"]
    hydro.should == 47.0
  end
  
  it "Accessing pi value" do 
    pi = MS::Feature::AA::PIHASH["A"]
    pi.should == 6.107
  end
  
end
