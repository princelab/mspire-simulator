#feature_spec.rb

require 'mspire'
require 'progress'
require 'ms/sim_peptide'
require 'ms/sim_feature'

describe MS::Sim_Feature do 

  it "Simulates features or isotopic patterns given peptides with retention times, the average retention time, the sampling rate and the run time" do
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 5000.0
    avg_rt = 0
    
    peptides.each_with_index do |pep,i|
      pep.p_rt = i
    end
    
    
    features = MS::Sim_Feature.new(peptides,run_time)
    features.should be_a(MS::Sim_Feature)
  end
  
  
  it "#data Returns a hash {retention time => [[m/zs] ,[intensities]]}" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 5000.0
    avg_rt = 0
    
    peptides.each_with_index do |pep,i|
      pep.p_rt = i
    end
    
    
    features = MS::Sim_Feature.new(peptides,run_time)
    features.data.should be_a(Hash)
  end
  
end