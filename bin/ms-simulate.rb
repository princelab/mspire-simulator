#!/usr/bin/env ruby

require 'time'
require 'progress'
require 'nokogiri'
require 'mspire/digester'
require 'mspire'
require 'ms/sim_peptide'
require 'ms/rt/rtgenerator'
require 'ms/sim_spectra'
require 'ms/noise'
require 'ms/mzml_wrapper'
require 'trollop'
require 'ms/tr_file_writer'
require 'ms/isoelectric_calc'

module MSsimulate

@start = Time.now
opts = Trollop::options do
version "ms-simulate 0.0.1a (c) 2012 Brigham Young University"
  banner <<-EOS
  
  *********************************************************************
   Description: Simulates ms runs given protein fasta files. Outputs
   a mzML file.
   
   
  Usage:
       ms-simulate [options] <filenames>+
       
  where [options] are:
  EOS
  opt :digestor, "Digestion Enzyme; one of: \n\t\targ_c,\n \t\tasp_n,\n \t\tasp_n_ambic,\n \t\tchymotrypsin,\n \t\tcnbr,\n \t\tlys_c,\n \t\tlys_c_p,\n \t\tpepsin_a,\n\t\ttryp_cnbr,\n \t\ttryp_chymo,\n \t\ttrypsin_p,\n \t\tv8_de,\n \t\tv8_e,\n \t\ttrypsin,\n \t\tv8_e_trypsin,\n\t\tv8_de_trypsin", :default => "trypsin" 
  opt :sampling_rate, "How many scans per second", :default => 1.0 
  opt :run_time, "Run time in seconds", :default => 1000.0 
  opt :noise, "Noise on or off", :default => "true"
  opt :contaminate, "Contamination on or off", :default => "true"
  opt :noise_density, "Determines the density of white noise", :default => 10
  opt :pH, "The pH that the sample is in - for determining charge", :default => 2.6
  opt :out_file, "Name of the output file", :default => "test.mzml"
  opt :contaminants, "Fasta file containing contaminant sequences", :default => "testFiles/contam/hum_keratin.fasta"
  opt :dropout_percentage, "Defines the percentage of random dropouts in the run. 0.0 <= percentage < 1.0", :default => 0.12
  opt :shuffle, "Option shuffles the scans to simulate 1d data", :default => "false"
  opt :one_d, "Turns on one dimension simulation; run_time is automatically set to 300.0", :default => "false"
  opt :truth, "Determines truth file type; false gives no truth file; one of: xml or csv", :default => "false"
end

Trollop::die :sampling_rate, "must be greater than 0" if opts[:sampling_rate] <= 0
Trollop::die :run_time, "must be non-negative" if opts[:run_time] < 0
Trollop::die "must supply a .fasta protien sequence file" if ARGV.empty?
Trollop::die :dropout_percentage, "must be between greater than or equal to 0.0 or less than 1.0" if opts[:dropout_percentage] < 0.0 or opts[:dropout_percentage] >= 1.0

#*************************Main******************************************

  digestor = opts[:digestor]
  sampling_rate = opts[:sampling_rate].to_f
  run_time = opts[:run_time].to_f
  noise = opts[:noise]
  contaminate = opts[:contaminate]
  density = opts[:noise_density]
  pH = opts[:pH].to_f
  out_file = opts[:out_file]
  contaminants = opts[:contaminants]
  drop_percentage = opts[:dropout_percentage]
  shuffle = opts[:shuffle]
  one_d = opts[:one_d]
  if one_d == "true"
    one_d = true
    run_time = 300.0
  else
    one_d = false
  end
  truth = opts[:truth]

  peptides = []

  if contaminate == 'true'
    ARGV<<contaminants
  end

  ARGV.each do |file|
    start = Time.now
    inFile = File.open(file,"r")
    seq = ""
    inFile.each_line do |sequence| 
      if sequence =~ />/ or sequence == "\n"
      else
        seq = seq<<sequence.chomp!
      end
    end
    inFile.close
    
    trypsin = Mspire::Digester[digestor]
    digested = trypsin.digest(seq)

    digested.each_with_index do |peptide_seq,i|
      Progress.progress("Creating peptides '#{file}':",((i/digested.size.to_f)*100).to_i)
      
      charge_ratio = charge_at_pH(identify_potential_charges(peptide_seq), pH)
      charge_f = charge_ratio.floor
      charge_c = charge_ratio.ceil
      
      peptide_f = MS::Peptide.new(peptide_seq, charge_f)
      peptide_c = MS::Peptide.new(peptide_seq, charge_c)
      
      ratio = charge_ratio % 1
      inverse = 1 - ratio
      
      peptide_c.c_ratio = ratio
      peptide_f.c_ratio = inverse

      peptides<<peptide_f
      peptides<<peptide_c
    end
    Progress.progress("Creating peptides '#{file}':",100,Time.now-start)
    puts ''
  end

  peptides.uniq!
  spectra = MS::Sim_Spectra.new(peptides,sampling_rate, run_time, drop_percentage,out_file,density,one_d)
  data = spectra.data
  
  if noise == "true"
    noise = spectra.noise
  end
  
  
  #------------------------Truth Files----------------------------------
  if truth != "false"
    if truth == "xml"
      MS::Txml_file_writer.new(spectra.features,spectra.spectra,out_file)
    elsif truth == "csv"
      MS::Tcsv_file_writer.new(data,noise,spectra.features,out_file)
    end
  end
  #---------------------------------------------------------------------
  
  data = spectra.spectra
  
  mzml = Mzml_Wrapper.new(data)
  
  puts "Writing to file..."
  mzml.to_xml(out_file)
  puts "Done."

end
