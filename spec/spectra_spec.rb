#spectra_spec.rb

require 'mspire'
require 'ms/spectra/spectra'
require 'ms/peptide'

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
end
