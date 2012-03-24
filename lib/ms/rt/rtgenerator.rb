
require 'time'
require 'progress'
require 'ms/sim_feature'
require 'ms/rt/weka'
require 'ms/sim_peptide'
require 'ms/rt/rt_helper'

module MS
  module Rtgenerator
    
    module_function
    def generateRT(peptides, r_time,run_time)
      
      @start = Time.now
      new_peptides = []
      @r_time = r_time
      @run_time = run_time
      
      peptides.delete_if{|pep| pep.charge == 0}
      
      # Gets retention times from the weka model
      peptides = MS::Weka.predict_rts(peptides)
    
      peptides.each_with_index do |pep,ind|
        Progress.progress("Generating peptides:",(((ind+1)/peptides.size.to_f)*100).to_i)

        pep.p_rt = @r_time.find {|i| i >= pep.p_rt}
        
        #multiply peptides
	
        if pep.p_rt == nil
          raise "\n\n\t#{pep} :: Peptide not predicted in time range: try increasing run time\n\n."
        end
	
        @r_time.each do |t|
          # Only need to go from predicted rt to ~500
          if t >= (pep.p_rt-RThelper.RandomFloat(50.0,100.0)) and pep.rts.length < 501
            pep.rts<<t
          end
        end
        
      end
  
      Progress.progress("Generating peptides:",100,Time.now-@start)
      puts ""
      
      return peptides
      
    end
    
  end
end
