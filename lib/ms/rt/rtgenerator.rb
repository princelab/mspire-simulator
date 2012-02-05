
require 'ms/feature/feature'
require 'ms/peptide'
require 'ms/rt/rt_helper'
#require 'ms/rt/dtree'
require 'ms/plot/mgl_plot'

module MS
	#The name of this class should change - to much going on in here. 
	#Need to compartmentalize.
	class Rtgenerator
		def initialize
			@dec_tree = nil
			@index = 0
		end
		
		def generateRT(peptides, samplingRate, runTime)
		
			#@dec_tree = DTree::Create.new.createDT # - James is working on something better 
			features = Hash.new
			mzs = Array.new
			rts = Array.new
			ints = Array.new
			groups = Array.new
			arrays = [mzs,rts,ints,groups]
			@time = Array.new
			r = samplingRate*runTime
			t = 1/samplingRate
			for i in (1..r)
				@time<<t
				t = t + (1/samplingRate)
			end
			@rts = Array.new
			peptides.each do |pep,ind|
				peps = Array.new
				
				for i in (1..(@time.length))
					peps<<MS::Peptide.new(pep.sequence,pep.mass,pep.charge,0,ind)
				end
	
				isotopes = MS::Feature::Feature.new.calcPercent(pep.sequence)
				isos = Array.new
				avg = getRTs(peps)
				
				peps.uniq! {|p| p.rt}
				
				for i in (1..(isotopes.length))
					newpeps = Array.new
					peps.each do |pe|
						newpeps<<MS::Peptide.new(pe.sequence,pe.mass,pe.charge,pe.rt,ind)
					end
					isos<<newpeps
				end
				
				feature = getInts(isos,isotopes,avg)

				feature.each do |fin|
					fin.each do |newpep|
						mzs.push(newpep.mz)
						rts.push(newpep.rt)
						ints.push(newpep.int)
						groups.push(newpep.group)
					end
				end
				features[feature] = @index
				@index = @index+1
			end
			p @rts.uniq # to see what the decision tree is outputting
			return features,arrays
		end
		
		# Gets retention times from the 'decisiontree' this will probably
		# change.
		#
		def getRTs(peps)
		    
		    avg = 0.0
			rtmu = rand(80)+5
			peps.each do |pep|
=begin
				a = pep.sequence.count('A')
				r = pep.sequence.count('R')
				n = pep.sequence.count('N')
				d = pep.sequence.count('D')
				b = pep.sequence.count('B')
				c = pep.sequence.count('C')
				e = pep.sequence.count('E')
				q = pep.sequence.count('Q')
				z = pep.sequence.count('Z')
				g = pep.sequence.count('G')
				h = pep.sequence.count('H')
				i = pep.sequence.count('I')
				l = pep.sequence.count('L')
				k = pep.sequence.count('K')
				m = pep.sequence.count('M')
				f = pep.sequence.count('F')
				p = pep.sequence.count('P')
				s = pep.sequence.count('S')
				t = pep.sequence.count('T')
				w = pep.sequence.count('W')
				y = pep.sequence.count('Y')
				v = pep.sequence.count('V')
				b = [pep.mz,pep.charge,a,r,n,d,b,c,e,q,z,g,h,i,l,k,m,f,p,s,t,w,y,v]
				b = b + [@dec_tree.predict(b)[0]]
				pep.mz = b[0] #needs to be distributed <|>
				@rts<<b[24]
				pep.rt = b[24]
=end
				spreadRTs(pep,rtmu)
				if(pep.rt == nil)
					pep.rt = 1
				end
				avg = avg+pep.rt
			end
			avg = avg/(peps.length)
			return avg
		end
		
		# Spreading peaks by a normal density function.
		# This may not be the correct thing to do.
		#
		def spreadRTs(pep,mu)
			pep.rt = RThelper.randn(mu,5)
			pep.rt = @time.find {|i| i >= pep.rt}
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


