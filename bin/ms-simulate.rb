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
require 'ms/plot/plot'
require 'ms/rt/rtgenerator'
require 'ms/mzml/mzml'

if(ARGV.length == 0)
	puts "" 
	puts "ms-simulate"
	puts "Description: Simulates ms runs given the fasta files. Outputs"
	puts " a 3d plot(optional) and a mzML file"
	puts ""
	puts "Usage: \n\tms-simulate [option] <fasta files>"
	puts "Options: \n\t-p  ->  show 3d plot"
	puts ""
	puts "fasta files:         \n\tfiles must be in fasta format"
	puts ""
	puts "Output:              \n\ttest.mzML"
	puts ""
	puts ""
else
	
	peptides = Hash.new
	pl = false
	if ARGV.find {|p| p == '-p'}
		p = ARGV.shift
		pl = true
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
				if aa == h or aa == k or aa == r
					charge = charge + 1
				end
			end
			p = MS::Peptide.new(peptide,mass,charge)
			peptides[p] = count
		end
	end
	features = MS::Rtgenerator.new.generateRT(peptides,3.0, 300)

	if pl
		MS::Plot.new.plot(features)
	end
	
	spectra = features[1].transpose
	spectra = spectra.group_by {|x| x[1]}
	newSpectra = Hash.new
	spectra.each  do |key,val|
		val = val.transpose
		val.delete_at(1)
		val.delete_at(2)
		newSpectra[key] = val
	end
	spectra = newSpectra
	spectra.delete_if{|k,v| v[1].inject(:+) <= 0.0}
	#spectra is a Hash rt=>[[mzs],[ints]]
	mzml = Mzml.new(spectra)
	
	File.open('test.mzml', 'w') do |output|
		output.write(mzml.get_builder.to_xml)
	end
end
