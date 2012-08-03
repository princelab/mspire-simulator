#spectra_spec.rb

require 'mspire'
require 'ms/sim_spectra'
require 'ms/sim_peptide'

describe MS::Sim_Spectra do
  before(:all) do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY",1)
    peptides<<MS::Peptide.new("PRINCE",2)
    peptides<<MS::Peptide.new("PEPTIDE",3)
    one_d = false
    opts = {:sampling_rate => 1.0, :run_time => 5000.0,
            :dropout_percentage => 0, :noise_density => 20,
            :jagA => 10.34, :jagC => 0.00712, :jagB => 0.12,
            :wobA => 0.001071, :wobB => -0.5430, :mu => 25.0}
    @spectra = MS::Sim_Spectra.new(peptides,opts,one_d)
    @features = @spectra.features
  end
  
  it "Creates spectra for a ms run given an array of peptide objects, a sampling rate and a run time, " do
    @spectra.should be_a(MS::Sim_Spectra)
  end
  
  it "#data Returns a hash that has retention times as keys and arrays as values such that [[mzs],[intensitys]]" do 
    @spectra.data.should be_a(Hash)
  end
  
  it "#max_mz Returns the maximum of all the m/z values" do
    (485..487).should cover(@spectra.max_mz)
  end
  
  it "#spectra Returns a hash with all data including noise if turned on" do 
    @spectra.spectra.should be_a(Hash)
  end
  
  it "#features Returns complete features" do
    @spectra.features
    @spectra.features.should have(3).peptides
  end
  
#FEATURES---------------------------------------------------------------
  
  it "Each feature should have a sequence" do 
    seqs = ["ANDY","PRINCE","PEPTIDE"]
    @features.each_with_index do |fe,i|
      fe.sequence.should == seqs[i]
    end
  end
  
  it "Each feature should have a mass" do 
    masses = [481,730,799]
    @spectra.features.each_with_index do |fe,i|
      fe.mass.round.should == masses[i]
    end
  end
  
  it "Each feature should have a charge" do 
    charges = [1,2,3]
    @spectra.features.each_with_index do |fe,i|
      fe.charge.should == charges[i]
    end
  end
  
  it "Each feature should have a monoisotopic m/z" do 
    mono_mzs = [481,365,266]
    @spectra.features.each_with_index do |fe,i|
      fe.mono_mz.round.should == mono_mzs[i]
    end
  end
  
  it "Each feature should have a theoretical spectrum" do 
    andy_spec = [[481, 482, 483, 484, 485, 486],
                 [100, 24, 5, 1, 0, 0]]
    prince_spec = [[365, 366, 366, 367, 367, 368, 368, 369],
                 [100, 37, 13, 3, 1, 0, 0, 0]]
    peptide_spec = [[266, 267, 267, 267, 268, 268, 268],
                 [100, 41, 11, 2, 0, 0, 0]]
    specs = [andy_spec,prince_spec,peptide_spec]
    
    @spectra.features.each_with_index do |fe,i|
      test = [fe.core_mzs.map{|mz| mz.round},fe.core_ints.map{|int| int.round}]
      test.should == specs[i]
    end
  end
  
  it "Each feature should have a predicted retention time and intensity" do 
      p_rts = [(2079..2082),(1774..1777),(1400..1402)]
      p_ints = [2.325,2.927,3.559]
    @spectra.features.each_with_index do |fe,i|
      p_rts[i].should cover(fe.p_rt)
      fe.p_int.should == p_ints[i]
    end
  end
  
  it "Each feature should have amino acid counts" do 
    counts = [[1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0.0],
              [0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0.0],
              [0, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 0.0]]
    @spectra.features.each_with_index do |fe,i|
      fe.aa_counts.should == counts[i]
    end
  end
  
end
