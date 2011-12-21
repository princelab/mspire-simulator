
require 'ms/feature/feature'
require 'ms/peptide'
require 'ms/rt/rt_helper'
require 'ms/rt/dtree'

module MS
	class Rtgenerator
		def initialize
			@dec_tree = nil
			@index = 0
		end
		
		def generateRT(peptides)
		
			f = open("/dev/tty")
		
			@dec_tree = DTree::Create.new.createDT
			features = Hash.new
			mzs = Array.new
			rts = Array.new
			ints = Array.new
			groups = Array.new
			arrays = [mzs,rts,ints,groups]
			
			peptides.each do |pep,ind|
				peps = Array.new
				
				for i in (1..((pep.charge*5)+rand(5)))
					peps<<MS::Peptide.new(pep.sequence,pep.mass,pep.charge,0,ind)
				end
				
				isotopes = MS::Feature::Feature.new.calcPercent(pep.sequence)
				isos = Array.new
				avg = getRTs(peps)
				
				for i in (1..(isotopes.length))
					newpeps = Array.new
					peps.each do |pe|
						newpeps<<MS::Peptide.new(pe.sequence,pe.mass,pe.charge,(pe.rt+rand),ind)
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
			
			return features,arrays
		end
		
		def getRTs(peps)
		    
		    avg = 0.0
			rtmu = rand(80)+5
			peps.each do |pep|
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
				b = [pep.mz,pep.charge,rand(52457000)+149860,a,r,n,d,b,c,e,q,z,g,h,i,l,k,m,f,p,s,t,w,y,v]
				b = b + [@dec_tree.predict(b)[0]]
				pep.mz = b[0] #needs to be distributed <|>
				pep.rt = b[25]
				spreadRTs(pep,rtmu)
				avg = avg+pep.rt
			end
			avg = avg/(peps.length)
			return avg
		end
		
		def spreadRTs(pep,mu)
			x = (rand(mu+15)+(mu-30))
			pep.rt = RThelper.randn(mu,5)
		end
		
		def getInts(fins, percents, avg)
			intRand = (fins[0].length)*10**6.1
			stddev = rand+2
		
			index = 0
			fins.each do |fin|
				percent_int = intRand*percents[index]
				c = 0
				fin.each do |p|
					c = c+1
					p.int = RThelper.emg(percent_int,avg,0.25,0.4,p.rt) #Exponentially modified gaussian
					p.mz = p.mz+index
				end
				index = index+1
			end
			return fins
		end
		
	end
end


