
require 'time'
require 'progress'
require 'ms/sim_feature'
require 'ms/rt/weka'
require 'ms/sim_peptide'
require 'ms/rt/rt_helper'

module MS
  module Rtgenerator

    module_function
    def generateRT(peptides, one_d)

      @r_times = Sim_Spectra.r_times

      # Gets retention times from the weka model
      peptides = MS::Weka.predict_rts(peptides)
      MS::Weka.predict_ints(peptides)


      #-----------------------------------------------------------------
      prog = Progress.new("Generating retention times:")
      num = 0
      total = peptides.size
      step = total/100.0
      peptides.each_with_index do |pep,ind|
	if ind > step * (num + 1)
	  num = (((ind+1)/total.to_f)*100).to_i
	  prog.update(num)
	end


        #Fit retention times into scan times
        max_rt = @r_times.max 
        p_rt = pep.p_rt * 10**-2
        if p_rt > 1
          pep.p_rt = @r_times.max
          pep.p_rt_i = @r_times.index(pep.p_rt)
        else
          pep.p_rt = @r_times.find {|i| i >= (p_rt * max_rt)}
          pep.p_rt_i = @r_times.index(pep.p_rt)
        end

        if pep.p_rt == nil
          puts "\n\n\t#{pep} TIME-> #{p_rt*max_rt} :: Peptide not predicted in time range: try increasing run time\n\n."
        else

          #Give peptide retention times
          head_length = nil
          tail_length = nil
          if one_d
            head_length = 300.0
            tail_length = 701
          else
            head_length = 100.0
            tail_length = 300
          end

          a = @r_times.find {|i| i >= (pep.p_rt-head_length)}
          b = @r_times.find {|i| i >= (pep.p_rt+tail_length)}
          a = @r_times.index(a)
          b = @r_times.index(b)

          if a == nil
            a = @r_times[0]
          end

          if b == nil
            b = @r_times[@r_times.length-1]
          end

          pep.set_rts(a,b)

        end
      end
      #-----------------------------------------------------------------
      prog.finish!

      return peptides

    end    
  end
end
