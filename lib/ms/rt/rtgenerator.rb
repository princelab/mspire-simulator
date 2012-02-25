
require 'time'
require 'ms/feature/feature'
require 'ms/rt/weka'
require 'ms/peptide'
require 'ms/rt/rt_helper'

module MS
  class Rtgenerator
    
    def generateRT(peptides, r_time,run_time)
      @start = Time.now
      new_peptides = []
      @r_time = r_time
      @run_time = run_time
      
      peptides.delete_if{|pep| pep.charge == 0}
      
      peptides = MS::Weka.predict_rts(peptides)
    
      peptides.each_with_index do |pep,ind|
        Progress.progress("Generating peptides:",(((ind+1)/peptides.size.to_f)*100).to_i)
        peps = Array.new
        
        #multiply peptides
        @r_time.length.times do
          peps<<MS::Peptide.new(pep.sequence,pep.rt)
        end
  
        #predict rts and spread them by a normal density func.
        avg_rt = getRTs(peps)
        
        #eliminate redundant rts in pep
        peps.uniq!{|pep| pep.rt}
        
        new_peptides<<[peps,avg_rt]
      end
      new_peptides.delete_if{|pep_group| pep_group[1] == 1}
      Progress.progress("Generating peptides:",100,Time.now-@start)
      puts ""
      if new_peptides.empty?
        puts "None predicted in time range: try increasing run time."
        abort
      end
      return new_peptides
    end
    
    # Gets retention times from the weka model
    #
    def getRTs(peps)
        
      avg_rt = 0.0
      rtmu = peps[0].rt
    
      peps.each do |pep|
        spreadRTs(pep,rtmu)
        if(pep.rt == nil)
          pep.rt = 1
        end
        avg_rt = avg_rt+pep.rt
      end
      
      avg_rt = avg_rt/(peps.length)
      return avg_rt
    end
    
    # Spreading peaks by a normal density function.
    # This may not be the correct thing to do.
    #
    def spreadRTs(pep,mu)
      pep.rt = Distribution::Normal.rng(mu,80).call
      pep.rt = @r_time.find {|i| i >= pep.rt}
    end
  end
end
