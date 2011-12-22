#!/usr/bin/env ruby

#ruby -I lib ./bin/ms-simulate.rb testFastaFiles/p53.fasta

require 'ms/digester'
require 'msplat'
require 'ms/feature/aa'
require 'ms/peptide'
require 'ms/plot/plot'
require 'ms/rt/rtgenerator'
require 'ms/mzml/writer'

if(ARGV.length == 0)
	puts "" 
	puts "ms-simulate"
	puts "Description: Simulates ms runs given the fasta files. Outputs"
	puts " a 3d plot and a mzML file"
	puts ""
	puts "Usage: \n\tms-simulate <fasta files>"
	puts ""
	puts ""
	puts "fasta files:         \n\tfiles must be in fasta format"
	puts ""
	puts "Output:              \n\tscatter.svg and simulate.mzML"
	puts ""
	puts ""
else
	
	peptides = Hash.new

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
		trypsin = MS::Digester[:trypsin]
		digested = trypsin.digest(seq)
		
		count = 0
		digested.each do |peptide|
			count = count + 1
			mass = 0
			charge = 0
			peptide.each_char do |aa| #simple charge state calculation (see http://www.springerlink.com/content/a5172138jj778192/fulltext.pdf)
				mass = mass + MS::Mass::AA::MONO[aa]
				h = 'H'
				k = 'K'
				r = 'R'
				if aa == h||k||r
					charge = charge + 1
				end
			end
			p = MS::Peptide.new(peptide,mass,charge)
			peptides[p] = count
		end
	end
	features = MS::Rtgenerator.new.generateRT(peptides)
	puts features[0].length
	#MS::Mzml::Writer.new.to_file(fins[0],fins[1][1])
	MS::Plot.new.plot(features)
end
