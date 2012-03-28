#rtgenerator_spec.rb

require 'mspire'
require 'ms/rt/rtgenerator'

describe MS::Rtgenerator do 
  
  
  it "#generateRT Predicts retention times given peptides, an array of scan times and the total run time" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 5000.0
    
    # making scan times
    scan_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        scan_times<<spec_time
        spec_time = spec_time + (1/sampling_rate)
      end
    
    pre_features = MS::Rtgenerator.generateRT(peptides,scan_times)
    #returns array of peptides
    pre_features.should be_a(Array)
  end
  
  
  
  it "#generateRT Returns an array of peptide objects with predicted retention times" do
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 5000.0
    
    # making scan times
    scan_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        scan_times<<spec_time
        spec_time = spec_time + (1/sampling_rate)
      end
    
    pre_features = MS::Rtgenerator.generateRT(peptides,scan_times)
    #returns array of peptides
    pre_features.should be_a(Array)
    pre_features[0].sequence.should == "PRINCE"
    pre_features[0].p_rt.should == 304.0
    
  end
  
  
  
  it "#generateRT If no retention times were predicted in the run time the program throws an exception." do
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 200.0
    
    # making scan times
    scan_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        scan_times<<spec_time
        spec_time = spec_time + (1/sampling_rate)
      end
    
    begin
      pre_features = MS::Rtgenerator.generateRT(peptides,scan_times)
    rescue
    
       peptides = []
	peptides<<MS::Peptide.new("ANDY")
	peptides<<MS::Peptide.new("PRINCE")
	peptides<<MS::Peptide.new("PEPTIDE")
	sampling_rate = 1.0
	run_time = 5000.0
	
	# making scan times
	scan_times = []
	  num_of_spec = sampling_rate*run_time
	  spec_time = 1/sampling_rate
	  num_of_spec.to_i.times do
	    scan_times<<spec_time
	    spec_time = spec_time + (1/sampling_rate)
	  end
	  
      pre_features = MS::Rtgenerator.generateRT(peptides,scan_times)
      
    end
  end
  
  
  
end
