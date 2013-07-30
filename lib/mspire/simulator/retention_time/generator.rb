
require 'time'
require 'progress'
require 'mspire/sim_feature'
require 'mspire/rt/weka'
require 'mspire/sim_peptide'
require 'mspire/rt/rt_helper'

module Mspire
  module Rtgenerator

    module_function
    def generateRT(one_d,db)
      prog = Mspire::Utilities::Progress.new("Generating retention times:")
      @r_times = Sim_Spectra.r_times

      # Gets retention times from the weka model
      Mspire::Weka.predict_rts(db)
      Mspire::Weka.predict_ints(db)


      #-----------------------------------------------------------------
      num = 0
      
      max_rt = 4*(@r_times.max/5)
      r_end = max_rt + (@r_times.max/5)/2
      r_start = @r_times.max/5
      peps = db.execute "SELECT Id,p_rt,abu,seq FROM peptides"
      total = peps.size
      step = total/100.0
      peps.each do |pep|
        ind = pep.delete_at(0)
        init_p_rt = pep[0]
        abu = pep[1]
        seq = pep[2]
        pep_p_rt = nil
        pep_p_rt_i = nil
        if ind > step * (num + 1)
          num = (((ind+1)/total.to_f)*100).to_i
          prog.update(num)
        end


        #Fit retention times into scan times
        p_rt = init_p_rt * 10**-2
        percent_time = p_rt 
        sx = RThelper.gaussian(percent_time,0.5,0.45,1.0) * Math.sqrt(abu) #need to figure out what these values should be
	

        if p_rt > 1
          pep_p_rt = @r_times.find {|i| i >= r_end}
          pep_p_rt_i = @r_times.index(pep_p_rt)
        else
          pep_p_rt = @r_times.find {|i| i >= (p_rt * max_rt)}
          pep_p_rt_i = @r_times.index(pep_p_rt)
        end
        
        a = nil
        b = nil

        if pep_p_rt == nil
          puts "\n\n\t#{seq} TIME-> #{p_rt*max_rt} :: Peptide not predicted in time range: try increasing run time\n\n."
        else

          #Give peptide retention times
          head_length = nil
          tail_length = nil
          if one_d
            head_length = 300.0
            tail_length = 701
          else
            head_length = 100.0 * sx
            tail_length = 300 * sx
          end

          a = @r_times.find {|i| i >= (pep_p_rt-head_length)}
          b = @r_times.find {|i| i >= (pep_p_rt+tail_length)}
          a = @r_times.index(a)
          b = @r_times.index(b)

          if a == nil
            a = @r_times[0]
          end

          if b == nil
            b = @r_times[@r_times.length-1]
          end

        end
        db.execute "UPDATE peptides SET p_rt=#{pep_p_rt},p_rt_index=#{pep_p_rt_i},sx=#{sx},rt_a=#{a},rt_b=#{b} WHERE Id='#{ind}'"
      end
      #-----------------------------------------------------------------
      prog.finish!
    end    
  end
end
