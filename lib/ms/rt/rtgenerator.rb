
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
        peps = Array.new
        peps<<pep
        avg_rt = @r_time.find {|i| i >= peps[0].rt}
        peps.delete_at(0)
        
        #multiply peptides
	
	if avg_rt == nil
	  raise "\n\n\tNone predicted in time range: try increasing run time (see final run time above)\n\n."
	end
	
        @r_time.each do |t|
          # Only need to go from predicted rt to ~500
          if t >= (avg_rt-RThelper.RandomFloat(50.0,100.0)) and peps.length < 501
            peps<<MS::Peptide.new(pep.sequence,t)
          end
        end
        
        new_peptides<<[peps,avg_rt]
      end
      new_peptides.delete_if{|pep_group| pep_group[1] == 1}
      Progress.progress("Generating peptides:",100,Time.now-@start)
      puts ""
      
      return new_peptides
      
    end
    
  end
end
