#spectra_spec.rb

require 'mspire'
require 'ms/sim_spectra'
require 'ms/sim_peptide'

describe MS::Sim_Spectra do

  it "Creates spectra for a ms run given an array of peptide objects, a sampling rate and a run time, " do
    peptides = []
    peptides<<MS::Peptide.new("ANDY",1)
    peptides<<MS::Peptide.new("PRINCE",2)
    peptides<<MS::Peptide.new("PEPTIDE",3)
    sampling_rate = 1.0
    run_time = 5000.0
    spectra = MS::Sim_Spectra.new(peptides,sampling_rate, run_time)
    spectra.should be_a(MS::Sim_Spectra)
  end
  
  it "#data Returns a hash that has retention times as keys and arrays as values such that [[mzs],[intensitys]]" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY",1)
    peptides<<MS::Peptide.new("PRINCE",2)
    peptides<<MS::Peptide.new("PEPTIDE",3)
    sampling_rate = 1.0
    run_time = 5000.0
    spectra = MS::Sim_Spectra.new(peptides,sampling_rate, run_time)
    spectra.should be_a(MS::Sim_Spectra)
    spectra.data.should be_a(Hash)
  end
  
end
