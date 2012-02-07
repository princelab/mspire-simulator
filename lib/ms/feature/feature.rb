require 'msplat'
require 'ms/peptide'
require 'ms/feature/isotope'
require 'ms/rt/rt_helper'

module MS
	module Feature
		class Feature 
			def initialize(peptide_groups)
				#predict isotopes/relative abundance
				#add noise (wobble)
				
				@features = []
				@data = {}
				peptide_groups.each do |peptides|
					relative_abundances = calcPercent(peptides[0][0].sequence)
					avg_rt = peptides[1]
					waves = []
					
					relative_abundances.length.times do
						newpeps = []
						peptides[0].each do |peptide|
							newpeps<<MS::Peptide.new(peptide.sequence,peptide.rt)
						end
						waves<<newpeps
					end
					
					feature = getInts(waves,relative_abundances,avg_rt)
					@features<<feature
				end
				@features = @features.flatten.group_by{|pep| pep.rt}
				@features.each do |rt, peps|
					mzs = []
					ints = []
					peps.each do |pep|
						mzs<<pep.mz
						ints<<pep.int
					end
					@data[rt] = [mzs,ints]
				end
			end
			
			attr_reader :data
			attr_writer :data
			
			# Counts the number of each atom in the peptide sequence.
			#
			def countAtoms(seq)
				o = 0
				n = 0
				c = 0
				h = 0
				s = 0
				p = 0
				se = 0
				seq.each_char do |aa|
					o = o + MS::Feature::AA::ATOM_COUNTS[aa][:o]
					n = n + MS::Feature::AA::ATOM_COUNTS[aa][:n]
					c = c + MS::Feature::AA::ATOM_COUNTS[aa][:c]
					h = h + MS::Feature::AA::ATOM_COUNTS[aa][:h]
					s = s + MS::Feature::AA::ATOM_COUNTS[aa][:s]
					p = p + MS::Feature::AA::ATOM_COUNTS[aa][:p]
					se = se + MS::Feature::AA::ATOM_COUNTS[aa][:se]
				end
				return o,n,c,h,s,p,se
			end
			
			# Calculates the relative intensities of the isotopic 
			# envelope.
			#
			def calcPercent(seq)
				#isotope.rb from Dr. Prince
				atoms = countAtoms(seq)
				
				var = ""
				var<<"O"
				var<<atoms[0].to_s
				var<<"N"
				var<<atoms[1].to_s
				var<<"C"
				var<<atoms[2].to_s
				var<<"H"
				var<<atoms[3].to_s
				var<<"S"
				var<<atoms[4].to_s
				var<<"P"
				var<<atoms[5].to_s
				var<<"SE"
				var<<atoms[6].to_s
	
				percents = Isotope.dist(var)
				#puts percents
				return percents
			end
			
			# Intensities are shaped in the rt direction by the Exponentially
			# modified gaussian. They are also shaped in the m/z direction 
			# by a simple gaussian curve (see 'factor' below). 
			#
			def getInts(fins, percents, avg)
				intRand = (fins[0][0].charge)*10**2
				stddev = rand+2
			
				index = 0
				neutron = 0
				fins.each do |fin|
					mzmu = fin[0].mz + neutron + 0.5
					max_y = RThelper.gaussian(mzmu,mzmu,0.05) 
					
					#percent_int = intRand*percents[index]
					percent_int = percents[index]
					fin.each do |p|
						p.mz = RThelper.randn(mzmu,0.04)
						
						fraction = RThelper.gaussian(p.mz,mzmu,0.05)
						factor = fraction/max_y
								
						#Exponentially modified gaussian * gaussian
						p.int = (RThelper.emg(percent_int,avg,0.25,0.4,p.rt)) * factor
						#p.int = p.int * Mgl_Plot.RandomFloat(0.80,1.0)#Jagged-ness
					end
					index = index+1
					neutron = neutron+1.009
				end
				return fins
			end
		end
	end
end
