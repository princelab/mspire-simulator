
require 'ms/feature/feature'
require 'decisiontree'
require 'ms/peptide'
#require 'ms/fin'
require 'csv'
module MS
	class Rtgenerator
		def initialize
			@dec_tree = nil
			@index = 0
		end
		
		def generateRT(peptides)
		
			f = open("/dev/tty")
		
			createDT
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
		
		def createDT
			attributes = ['mz', 'charge', 'intensity','A','R','N','D','B','C','E','Q','Z','G','H','I','L','K','M','F','P','S','T','W','Y','V']
			training = []
				CSV.foreach("testFastaFiles/testsmall.csv") do |row|
				start = Time.now
				row << row[0].count("A")#A1
				row << row[0].count("R")#R2
				row << row[0].count("N")#N3
				row << row[0].count("D")#D4
				row << row[0].count("B")#B5
				row << row[0].count("C")#C6
				row << row[0].count("E")#E7
				row << row[0].count("Q")#Q8
				row << row[0].count("Z")#Z9
				row << row[0].count("G")#G10
				row << row[0].count("H")#H11
				row << row[0].count("I")#I12
				row << row[0].count("L")#L13
				row << row[0].count("K")#K14
				row << row[0].count("M")#M15
				row << row[0].count("F")#F16
				row << row[0].count("P")#P17
				row << row[0].count("S")#S18
				row << row[0].count("T")#T19
				row << row[0].count("W")#W20
				row << row[0].count("Y")#Y21
				row << row[0].count("V")#V22
				row.delete_at(0)
				row[0] = row[0].to_f
				row[1] = row[1].to_f
				row[2] = row[2].to_f
				row[3] = row[3].to_f
				row << row[3]
				row.delete_at(3)
				#puts "took #{Time.now-start} secs"
				training << row
				#p row
				end	

			#puts training.inspect

			# Instantiate the tree, and train it based on the data (set default to '1')
			@dec_tree = DecisionTree::ID3Tree.new(attributes, training.to_a, 1, :continuous)
			@dec_tree.train
			#'A','R','N','D','B','C','E','Q','Z','G','H','I','L','K','M','F','P','S','T','W','Y','V'
			test = [844.43613,2,33963000,4,1,0,1,0,0,2,1,0,1,0,2,1,0,0,1,1,1,0,0,0,0]
			 
			generatedrt = @dec_tree.predict(test)
			puts "Predicted: #{generatedrt} ... True decision: #{test.last}"
			puts "Actual: 60.007"
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
				#puts pep.int
				pep.rt = b[25]
				spreadRTs(pep,rtmu)
				avg = avg+pep.rt
			end
			avg = avg/(peps.length)
			return avg
		end
		
		def spreadRTs(pep,mu)
			x = (rand(mu+15)+(mu-30))
			pep.rt = Foo.randn(mu,5)
			#pep.rt = Foo.emg(10,50,mu,30,pep.rt)
			#pep.rt = rand(30)+10
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
					p.int = Foo.emg(percent_int,avg,0.25,0.4,p.rt) #Exponentially modified gaussian
					p.mz = p.mz+index
				end
				index = index+1
			end
			return fins
		end
	end
end

#C++ code:
require 'ffi-inliner'
module Foo
   extend Inliner
   inline do |builder|
     builder.use_compiler Inliner::Compilers::GPlusPlus
     builder.c_raw <<-code
       #include <iostream>
       #include <string>
       #include <cstdlib>
       #include <cmath>
       using namespace std;
       code
       builder.map 'char *' => 'string'
       builder.c <<-code
       #include <cstdlib>
       #include <math.h>
       #define PI 3.14159
          float randn( float m, float s){                                      
			  float x1, x2, w, y1;   
			  static float y2;   
			  static int use_last   = 0;   
			  static float rand_max = (float)( RAND_MAX);   
			   
			  if ( use_last)            /* use value from previous call */   
			  {   
				y1 = y2;   
				use_last = 0;   
			  }   
			  else   
			  {   
				do    
				{   
			//      x1 = 2.0 * ranf() - 1.0;   
			//      x2 = 2.0 * ranf() - 1.0;   
				  x1 = 2.0 * (float)( rand()) / rand_max - 1.0;   
				  x2 = 2.0 * (float)( rand()) / rand_max - 1.0;   
				  w = x1 * x1 + x2 * x2;   
				} while ( w >= 1.0);   
			   
				w  = sqrt( (-2.0 * log( w) ) / w );   
				y1 = x1 * w;   
				y2 = x2 * w;   
				use_last = 1;   
			  }   
			   
			  return ( m + y1 * s);   
			}
			
	   code
       builder.c <<-code
			
		float gaussian(float rt, float mu, float sd, float intRand){
			return ((1/(sqrt(2*(PI)*(pow(sd,2)))))*(exp(-((pow((rt-mu),2))/(pow((2*sd),2))))))*intRand;
		} 
       code
       builder.c <<-code
       
         float emg(float a,float b,float c,float d,float x){
			float one, two, three, four;
			one = (a*c*(sqrt(2*PI)))/(2*d);
			two = (((b-x)/d)*((pow(c,2))/(pow((2*d),2))));
			three = (d/abs(d));
			four = ((b-x)/(sqrt(2*c)))+(c/(sqrt(2*d)));
			
			return one*exp(two)*(three-erf(four));
         }
       code
  end
end
