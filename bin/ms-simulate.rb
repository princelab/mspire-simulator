#!/usr/bin/env ruby

#ruby -I lib ./bin/ms-simulate.rb testFastaFiles/p53.fasta
#TODO - NOISE:
#	1. m/z variance
#	2. Intensity variance
#		a. Dropout
#	3. Grass
#	Beyond:
#	-Scan Dropout
#	-RT variance
#	-RT warp
#	-m/z warp
#	-contaminants

require 'nokogiri'
require 'ms/digester'
require 'msplat'
require 'ms/feature/aa'
require 'ms/peptide'
require 'ms/rt/rtgenerator'
require 'ms/spectra/spectra'
require 'ms/mzml/mzml'

if(ARGV.length == 0)
	puts "" 
	puts "ms-simulate"
	puts "Description: Simulates ms runs given the fasta files. Outputs"
	puts " a 3d plot(optional) and a mzML file"
	puts ""
	puts "Usage: \n\tms-simulate [option] <fasta files>"
	puts "Options: \n\t-p  ->  show 3d plot"
	puts "\t-d <enzyme>  ->  digestors:  "
	puts "\t\targ_c,\n \t\tasp_n,\n \t\tasp_n_ambic,\n \t\tchymotrypsin,\n \t\tcnbr,\n \t\tlys_c,\n \t\tlys_c_p,\n \t\tpepsin_a,\n" 
    puts "\t\ttryp_cnbr,\n \t\ttryp_chymo,\n \t\ttrypsin_p,\n \t\tv8_de,\n \t\tv8_e,\n \t\ttrypsin,\n \t\tv8_e_trypsin,\n"
    puts "\t\tv8_de_trypsin"
	puts ""
	puts "fasta files:         \n\tfiles must be in fasta format"
	puts ""
	puts "Output:              \n\ttest.mzML"
	puts ""
	puts ""
else
	
	pl = false
	if ARGV.find {|p| p == '-p'}
		p = ARGV.find {|p| p == '-p'}
		ARGV.delete('-p')
		pl = true
	end
	
	if ARGV.find {|d| d == '-d'}
		index = ARGV.find_index {|d| d == '-d'}
		@digestor = ARGV[index+1]
		ARGV.delete_at(index)
		ARGV.delete_at(index)
	end

	ARGV.each do |file|
		inFile = File.open(file,"r")
		seq = ""
		inFile.each_line do |sequence| 
			if sequence =~ />/
			else
				seq = seq<<sequence.chomp!
			end
		end
		inFile.close
		trypsin = MS::Digester[@digestor]
		digested = trypsin.digest(seq)

		@peptides = []
		digested.each do |peptide_seq|
			peptide = MS::Peptide.new(peptide_seq)
			@peptides<<peptide
		end
	end
	#filter peptides ??? - in a later version
	#need to include in options
	sampling_rate = 3.0
	run_time = 300
	spectra = MS::Spectra.new(@peptides,sampling_rate, run_time)
	
	mzml = Mzml.new(spectra.data)
	
	File.open('test.mzml', 'w') do |output|
		output.write(mzml.get_builder.to_xml)
	end
	system("cp test.mzml /home/anoyce/Dropbox/")
end
