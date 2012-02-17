
require 'time'
require 'ms/feature/feature'
require 'ms/peptide'
require 'ms/rt/rt_helper'

module MS
  class Rtgenerator
    
    def generateRT(peptides, r_time,run_time)
      @start = Time.now
      #@dec_tree = DTree::Create.new.createDT # - James is working on something better 
      new_peptides = []
      @r_time = r_time
      @run_time = run_time
      
      peptides.delete_if{|pep| pep.charge == 0}
    
      peptides.each_with_index do |pep,ind|
        Progress.progress("Generating peptides:",(((ind+1)/peptides.size.to_f)*100).to_i)
        peps = Array.new
        
        #multiply peptides
        @r_time.length.times do
          peps<<MS::Peptide.new(pep.sequence)
        end
  
        #predict rts and spread them by a normal density func.
        avg_rt = getRTs(peps)
        
        #eliminate redundant rts in pep
        peps.uniq!{|pep| pep.rt}
        
        new_peptides<<[peps,avg_rt]
      end
      Progress.progress("Generating peptides:",100,Time.now-@start)
      puts ""
      return new_peptides
    end
    
    # Gets retention times from the 'decisiontree' this will probably
    # change.
    #
    def getRTs(peps)
        
        avg_rt = 0.0
      rtmu = rand(@run_time-5)+5
    
      peps.each do |pep|

        spreadRTs(pep,rtmu)
        if(pep.rt == nil)
          pep.rt = 1
        end
        avg_rt = avg_rt+pep.rt
      end
      avg_rt = avg_rt/(peps.length)
      return peps.sort_by {|pep| pep.rt}[0].rt
    end
    
    # Spreading peaks by a normal density function.
    # This may not be the correct thing to do.
    #
    def spreadRTs(pep,mu)
      pep.rt = RThelper.randn(mu,20)
      pep.rt = @r_time.find {|i| i >= pep.rt}
    end
  end
end
