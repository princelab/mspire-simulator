
require 'time'
require 'distribution'
require 'ms/sim_peptide'
require 'ms/rt/rt_helper'
require 'ms/tr_file_writer'

module MS
  class Sim_Feature 
    def initialize(peptides,one_d)
      
      @start = Time.now
      @features = []
      @data = {}
      @max_int = 0.0
      @one_d = one_d
      @max_time = Sim_Spectra.r_times.max
      
      
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
	
	fe_ints = fe.ints
	fe_mzs = fe.mzs
	
	fe.rts.each_with_index do |rt,i|
	  rt_mzs = []
	  rt_ints = []
	  
	  fe.core_mzs.size.times do |j| 
	    mz,int = [ fe_mzs[j][i], fe_ints[j][i] ]
	    if int == nil
	      int = 0.0
	    end
	    if int > 0.9
	      rt_mzs<<mz
	      rt_ints<<int
	    end
	  end
	  
	  if rt_mzs.include?(nil) or rt_mzs.empty?; else
	    if @data.key?(rt)
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
    
    attr_reader :data, :features
    attr_writer :data, :features
    
    # Intensities are shaped in the rt direction by a gaussian with 
    # a dynamic standard deviation.
    # They are also shaped in the m/z direction 
    # by a simple gaussian curve (see 'factor' below). 
    #
    def getInts(pep)
      
      predicted_int = (pep.p_int * 10**-1) * 14183000.0
      relative_ints = pep.core_ints#.map{|i| i = i*predicted_int}
      avg = pep.p_rt
      
      index = 0
      
      #--------------Intensity----------------------------
      ints_factor = 1
      #------------------------------------------------
      
      shuff = RThelper.RandomFloat(0.05,1.0)
      pep.core_mzs.each do |mzmu|

	fin_mzs = []
	fin_ints = []
	
	relative_abundances_int = relative_ints[index]

	pep.rts.each_with_index do |rt,i|
	  percent_time = rt/@max_time
	  length_factor = -3.96 * percent_time**2 + 3.96 * percent_time + 0.01
	  length_factor_tail = -7.96 * percent_time**2 + 7.96 * percent_time + 0.01
	  
	
	  if !@one_d
	    #-------------Tailing-------------------------
	    shape = (0.30 * length_factor)*i + (6.65 * length_factor_tail)
	    fin_ints << (RThelper.gaussian(rt,avg,shape,relative_abundances_int)) * ints_factor
	    #---------------------------------------------
	  else
	    #-----------Random 1d data--------------------
	    fin_ints<<(relative_abundances_int * ints_factor) * shuff
	    #---------------------------------------------
	  end

	  #-------------mz wobble-----------------------
	  y = fin_ints[i]
	  if y > 0.5
	    wobble_int = 0.001071*y**(-0.5430)
	  else
	    wobble_int = 0.003
	  end
	  wobble_mz = Distribution::Normal.rng(mzmu,(wobble_int)).call
	  if wobble_mz < 0
	    wobble_mz = 0.01
	  end

	  fin_mzs<<wobble_mz
	  #---------------------------------------------

	  if !@one_d
	    #-------------M/Z Peak shape------------------
	    fraction = RThelper.gaussian(fin_mzs[i],mzmu,0.05,1)
	    factor = fraction/1.0
	    fin_ints[i] = fin_ints[i] * factor
	    #---------------------------------------------
	  end
	  
	  #-------------Jagged-ness---------------------
	  sd = 10.34 * (1-Math.exp(-0.00712 * fin_ints[i])) + 0.12
	  diff = (Distribution::Normal.rng(0,sd).call)
	  fin_ints[i] = fin_ints[i] + diff
	  #---------------------------------------------
  
	  fin_ints[i] = fin_ints[i]*predicted_int

	end
	
	pep.insert_ints(fin_ints)
	pep.insert_mzs(fin_mzs)
	
	index += 1
      end
      return pep
    end
  end
end
