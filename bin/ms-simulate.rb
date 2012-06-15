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
require 'ms/sim_digester'

module MSsimulate

begin

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
  opt :digestor, "Digestion Enzyme; one of: \n\t\targ_c,\n \t\tasp_n,
                                            \n \t\tasp_n_ambic,
                                            \n \t\tchymotrypsin,\n \t\tcnbr,
                                            \n \t\tlys_c,\n \t\tlys_c_p,
                                            \n \t\tpepsin_a,\n\t\ttryp_cnbr,
                                            \n \t\ttryp_chymo,\n \t\ttrypsin_p,
                                            \n \t\tv8_de,\n \t\tv8_e,
                                            \n \t\ttrypsin,\n \t\tv8_e_trypsin,
                                            \n\t\tv8_de_trypsin",
                                             :default => "trypsin" 
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

  if contaminate == 'true'
    ARGV<<contaminants
  end
  
  #------------------------Digest-----------------------------------------------
  peptides = []
  digester = MS::Sim_Digester.new(digestor,pH)
  ARGV.each do |file|
    peptides<<digester.digest(file)
  end
  peptides.flatten!
  #-----------------------------------------------------------------------------



  #------------------------Create Spectrum--------------------------------------
  spectra = MS::Sim_Spectra.new(peptides, sampling_rate, run_time, drop_percentage, density, one_d)
  data = spectra.data
  
  if noise == 'true'
    noise = spectra.noiseify
  end
  #-----------------------------------------------------------------------------
  
  
  
  #------------------------Truth Files------------------------------------------
  if truth != "false"
    if truth == "xml"
      MS::Txml_file_writer.new(spectra.features,spectra.spectra,out_file)
    elsif truth == "csv"
      MS::Tcsv_file_writer.new(data,noise,spectra.features,out_file)
    end
  end
  #-----------------------------------------------------------------------------
  
  
  
  #-----------------------Clean UP----------------------------------------------
  spectra.features.each{|fe| fe.delete}
  peptides.clear
  #-----------------------------------------------------------------------------
  
  
  
  #-----------------------MZML--------------------------------------------------
  data = spectra.spectra
  mzml = Mzml_Wrapper.new(data)
  puts "Writing to file..."
  mzml.to_xml(out_file)
  puts "Done."
  #-----------------------------------------------------------------------------



rescue Exception => e  #Clean up if exception 
  puts e.message  
  puts e.backtrace 
  if digester != nil
    if File.exists?(digester.digested_file)
      File.delete(digester.digested_file)
    end
  end
  if spectra != nil
  spectra.features.each{|fe| fe.delete}
  end
  if !peptides.empty?
    peptides.each{|pep| pep.delete}
  end
  puts "Exception - Simulation Failed"
  system "ruby /home/anoyce/Dropbox/AlertYou.r 18017938728@tmomail.net Exception - Simulation Failed"
else
  system "ruby /home/anoyce/Dropbox/AlertYou.r 18017938728@tmomail.net Success!"
end
end
