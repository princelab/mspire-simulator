
require 'msplat'
require 'ms/peptide'
require 'ms/feature/isotope'
#require 'ms/fin'
module MS
	module Feature
		class Feature 
			def initialize()
				
			end
			
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
				return percents
			end
		end
	end
end
