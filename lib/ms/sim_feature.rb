
require 'time'
require 'distribution'
require 'ms/sim_peptide'
require 'mspire/isotope/distribution'
require 'ms/rt/rt_helper'

module MS
  class Sim_Feature 
    def initialize(peptides,r_times)
      
      @start = Time.now
      @features = []
      @data = {}
      @max_int = 0.0
      r_times.each{|t| @data[t] = nil}
      
      
      #------------------Each_Peptide_=>_Feature----------------------
      peptides.each_with_index do |pep,ind|
	Progress.progress("Generating features:",(((ind+1)/peptides.size.to_f)*100).to_i)	
	
	feature = getInts(pep)

	@features<<feature
      end
      Progress.progress("Generating features:",100,Time.now-@start)
      puts ""
      @start = Time.now
      #---------------------------------------------------------------
      
      
      
      #-----------------Transform_to_spectra_data_for_mzml------------
      # rt => [[mzs],[ints]]
      @features.each_with_index do |fe,k|
	Progress.progress("Populating structure for mzml:",((k/@features.size.to_f)*100).to_i)
	
	fe.rts.each_with_index do |rt,i|
	  rt_mzs = []
	  rt_ints = []
	  
	  fe.core_mzs.size.times do |j| 
	    mz,int = [ fe.mzs[j][i], fe.ints[j][i] ]
	    if int > 0.1
	      rt_mzs<<mz
	      #Normalizing Intensities
	      rt_ints<<((int/@max_int)*100.0)
	    end
	  end
	  
	  if rt_mzs.include?(nil) or rt_mzs.empty?; else
	    if @data.key?(rt) and @data[rt] != nil
	      mzs,ints = @data[rt]
	      @data[rt][0] = mzs + rt_mzs
	      @data[rt][1] = ints + rt_ints
	    else
	      @data[rt] = [rt_mzs, rt_ints]
	    end
	  end
	end
      end
      Progress.progress("Populating structure for mzml:",100,Time.now-@start)
      puts ""
      
      #---------------------------------------------------------------
      
    end
    
    attr_reader :data
    attr_writer :data
    
    # Intensities are shaped in the rt direction by a gaussian with 
    # a dynamic standard deviation.
    # They are also shaped in the m/z direction 
    # by a simple gaussian curve (see 'factor' below). 
    #
    def getInts(pep)
      
      relative_ints = pep.core_ints
      avg = pep.p_rt
      
      index = 0
      neutron = 0
      
      #--------------Intensity----------------------------
      ints_factor = RThelper.gaussian(pep.charge,2,0.25)
      #------------------------------------------------
      
      pep.core_mzs.each do |mzmu|

	fin_mzs = []
	fin_ints = []
	max_y = RThelper.gaussian(mzmu,mzmu,0.05) 
	
	relative_abundances_int = relative_ints[index]
  
	
	pep.rts.each_with_index do |rt,i|

	  #-------------Tailing-------------------------
	  shape = 0.30*i + 6.65
	  fin_ints << (RThelper.gaussianI(rt,avg,shape,relative_abundances_int)) * ints_factor
	  #---------------------------------------------
	  
	  
	  #-------------mz wobble-----------------------
	  y = fin_ints[i]
	  if y > 0.5
	    wobble_int = 0.001071*y**(-0.5430)
	  else
	    wobble_int = 0.001
	  end
	  wobble_mz = Distribution::Normal.rng(mzmu,(wobble_int*4.5)).call
	  if wobble_mz < 0
	    wobble_mz = 0.01
	  end

	  fin_mzs<<wobble_mz
	  #---------------------------------------------
	  
	  
	  #-------------M/Z Peak shape------------------
	  fraction = RThelper.gaussian(fin_mzs[i],mzmu,0.05)
	  factor = fraction/max_y
	  fin_ints[i] = fin_ints[i] * factor
	  #---------------------------------------------
	  
	  
	  #-------------Jagged-ness---------------------
	  sd = 0.1418 * fin_ints[i]
	  diff = (Distribution::Normal.rng(0,sd).call)
	  fin_ints[i] = fin_ints[i] + diff
	  #---------------------------------------------
    
	  
	  #Keep max_intensity for normalization
	  if fin_ints[i] > @max_int
	    @max_int = fin_ints[i]
	  end

	end
	
	pep.ints<<fin_ints
	pep.mzs<<fin_mzs
	
	index += 1
	neutron += 1.00866491600
      end
      return pep
    end
  end
end
