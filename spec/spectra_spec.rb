#spectra_spec.rb

require 'mspire'
require 'ms/spectra'
require 'ms/sim_peptide'

describe MS::Spectra do

  it "Creates spectra for a ms run given an array of peptide objects, a sampling rate and a run time, " do
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 5000.0
    spectra = MS::Spectra.new(peptides,sampling_rate, run_time)
    spectra.should be_a(MS::Spectra)
  end
  
  it "#data Returns a hash that has retention times as keys and arrays as values such that [[mzs],[intensitys]]" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    run_time = 5000.0
    spectra = MS::Spectra.new(peptides,sampling_rate, run_time)
    spectra.should be_a(MS::Spectra)
    spectra.data.should be_a(Hash)
  end
  
  it "If no retention times are predicted spectra trys again by increaseing the run time by 1000" do 
    peptides = []
    peptides<<MS::Peptide.new("ANDY")
    peptides<<MS::Peptide.new("PRINCE")
    peptides<<MS::Peptide.new("PEPTIDE")
    sampling_rate = 1.0
    #not enough run time
    run_time = 200.0
    spectra = MS::Spectra.new(peptides,sampling_rate, run_time)
    spectra.should be_a(MS::Spectra)
    spectra.data.should be_a(Hash)
  end
  
end
