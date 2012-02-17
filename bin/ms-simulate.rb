#!/usr/bin/env ruby

#ruby -I lib ./bin/ms-simulate.rb testFastaFiles/p53.fasta

require 'time'
require 'progress'
require 'nokogiri'
require 'ms/digester'
require 'msplat'
require 'ms/feature/aa'
require 'ms/peptide'
require 'ms/rt/rtgenerator'
require 'ms/spectra/spectra'
require 'ms/mzml/mzml'
require 'trollop'

@start = Time.now
opts = Trollop::options do
version "ms-simulate 0.0.1a (c) 2012 Brigham Young University"
  banner <<-EOS
  
  *********************************************************************
   Description: Simulates ms runs given protien fasta files. Outputs
   a mzML file.
  Usage:
       ms-simulate [options] <filenames>+
       
  where [options] are:
  EOS
  opt :digestor, "Digestion Enzyme; one of: \n\t\targ_c,\n \t\tasp_n,\n \t\tasp_n_ambic,\n \t\tchymotrypsin,\n \t\tcnbr,\n \t\tlys_c,\n \t\tlys_c_p,\n \t\tpepsin_a,\n\t\ttryp_cnbr,\n \t\ttryp_chymo,\n \t\ttrypsin_p,\n \t\tv8_de,\n \t\tv8_e,\n \t\ttrypsin,\n \t\tv8_e_trypsin,\n\t\tv8_de_trypsin", :default => "trypsin" 
  opt :sampling_rate, "How many scans per second", :default => 3.0 
  opt :run_time, "Run time in seconds", :default => 300.0 
end

Trollop::die :sampling_rate, "must be greater than 0" if opts[:sampling_rate] <= 0
Trollop::die :run_time, "must be non-negative" if opts[:run_time] < 0
Trollop::die "must supply a .fasta protien sequence file" if ARGV.empty?

#*************************Main******************************************

  digestor = opts[:digestor]
  sampling_rate = opts[:sampling_rate]
  run_time = opts[:run_time]

  @peptides = []

  ARGV.each do |file|
    Progress.progress("Reading file(s):",(((ARGV.index(file)+1)/ARGV.size.to_f)*100).to_i)
    inFile = File.open(file,"r")
    seq = ""
    inFile.each_line do |sequence| 
      if sequence =~ />/
      else
        seq = seq<<sequence.chomp!
      end
    end
    inFile.close
    trypsin = MS::Digester[digestor]
    digested = trypsin.digest(seq)

    digested.each do |peptide_seq|
      peptide = MS::Peptide.new(peptide_seq)
      @peptides<<peptide
    end
  end
  Progress.progress("Reading file(s):",100,Time.now-@start)
  puts ''

  #filter peptides ??? - in a later version
  @peptides.uniq!
  spectra = MS::Spectra.new(@peptides,sampling_rate, run_time)
  
  mzml = Mzml.new(spectra.data)
  
  puts "Writing to file..."
  File.open('test.mzml', 'w') do |output|
    output.write(mzml.get_builder.to_xml)
  end
  puts "Done."
