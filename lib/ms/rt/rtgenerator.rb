
require 'time'
require 'progress'
require 'ms/sim_feature'
require 'ms/rt/weka'
require 'ms/sim_peptide'
require 'ms/rt/rt_helper'

module MS
  module Rtgenerator
    
    module_function
    def generateRT(peptides, r_time)
      
      @start = Time.now
      @r_time = r_time
      
      peptides.delete_if{|pep| pep.charge == 0}
      
      # Gets retention times from the weka model
      peptides = MS::Weka.predict_rts(peptides)
      
      
      #-----------------------------------------------------------------
      peptides.each_with_index do |pep,ind|
        Progress.progress("Generating retention times:",(((ind+1)/peptides.size.to_f)*100).to_i)
	
	#Fit retention times into scan times
	max_rt = @r_time.max 
	p_rt = pep.p_rt
	if p_rt > 1
	  pep.p_rt = @r_time.max
	else
	  pep.p_rt = @r_time.find {|i| i >= (p_rt * max_rt)}
	end
	
        if pep.p_rt == nil
          puts "\n\n\t#{pep} TIME-> #{p_rt*max_rt} :: Peptide not predicted in time range: try increasing run time\n\n."
	else
	
	#Give peptide retention times
	  head_length = 50.0
	  @r_time.each do |t|
	    # Only need to go from predicted rt to ~500
	    if t >= (pep.p_rt-head_length) and pep.rts.length < 501
	      pep.rts<<t
	    end
	  end
	end
      end
      #-----------------------------------------------------------------
      
  
      Progress.progress("Generating retention times:",100,Time.now-@start)
      puts ""
      
      return peptides
      
    end    
  end
end
