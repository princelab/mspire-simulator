
require 'time'
require 'distribution'
require 'ms/sim_peptide'
require 'mspire/isotope/distribution'
require 'ms/rt/rt_helper'

module MS
  class Sim_Feature 
    def initialize(peptides,sampling_rate,r_time)
      
      @start = Time.now
      @features = []
      @data = {}
      @sampling_rate = sampling_rate
      @r_time = r_time
      
      
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
	    mz = fe.mzs[j][i]
	    int = fe.ints[j][i]
	    if int > 0.1
	      rt_mzs<<mz
	      rt_ints<<int
	    end
	  end
	  
	  if rt_mzs.include?(nil) or rt_mzs.empty?; else
	    if @data.key?(rt)
	      mzs = @data[rt][0]
	      ints = @data[rt][1]
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
      
      #--------------Length----------------------------
      ints_factor = RThelper.RandomFloat(0.1,1.0)
      #puts "ints_factor: #{ints_factor}, avg: #{avg}"
      #------------------------------------------------
      
      pep.core_mzs.each do |mzmu|

	fin_mzs = []
	fin_ints = []
	max_y = RThelper.gaussian(mzmu,mzmu,0.05) 
	
	relative_abundances_int = relative_ints[index]
	
	x = 0.0
	
	pep.rts.each_with_index do |rt,i|

	  #-------------Tailing-------------------------
	  shape = 0.30*x + 6.65
	  fin_ints << (RThelper.gaussianI(rt,avg,shape,relative_abundances_int)) * ints_factor
	  #---------------------------------------------
	  
	  
	  #-------------mz wobble-----------------------
	  y = fin_ints[i]
	  if y > 0.5
	    wobble_int = 0.001086*y**(-0.5561)
	  else
	    wobble_int = 0.001
	  end
	  wobble_mz = Distribution::Normal.rng(mzmu,(wobble_int/2.0)).call
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
	  
	 
	  x += 1

	end
	
	pep.ints<<fin_ints
	pep.mzs<<fin_mzs
	
	index = index+1
	neutron = neutron+1.009
      end
      #  Filter for low intensities
      return pep
    end
  end
end
