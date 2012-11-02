
require 'time'
require 'distribution'
require 'ms/sim_peptide'
require 'ms/rt/rt_helper'
require 'ms/tr_file_writer'

module MS
  class Sim_Feature 
    def initialize(peptides,opts,one_d)
      
      @features = []
      @data = {}
      @max_int = 0.0
      @one_d = one_d
      @max_time = Sim_Spectra.r_times.max
      @opts = opts


      #------------------Each_Peptide_=>_Feature----------------------
      prog = Progress.new("Generating features:")
      num = 0
      total = peptides.size
      step = total/100.0
      peptides.each_with_index do |pep,ind|
	if ind > step * (num + 1)
	  num = (((ind+1)/total.to_f)*100).to_i
	  prog.update(num)
	end

        feature = getInts(pep)

        @features<<feature
      end
      prog.finish!
      #---------------------------------------------------------------



      #-----------------Transform_to_spectra_data_for_mzml------------
      # rt => [[mzs],[ints]]
      prog = Progress.new("Populating structure for mzml:")
      num = 0
      total = @features.size
      step = total/100.0
      @features.each_with_index do |fe,k|
	if k > step * (num + 1)
	  num = ((k/total.to_f)*100).to_i
	  prog.update(num)
	end

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
      prog.finish!

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
      p_int = pep.p_int + RThelper.RandomFloat(-5,2)
      if p_int > 10
        p_int -= 10
      end
      predicted_int = (p_int * 10**-1) * 14183000.0 #TODO * SampleLoad
      relative_ints = pep.core_ints
      avg = pep.p_rt
      
      sampling_rate = @opts[:sampling_rate].to_f
      tail = @opts[:tail].to_f
      front = @opts[:front].to_f
      mu = @opts[:mu].to_f
      
      index = 0
      sx = pep.sx
      sy = sx**-1

      shuff = RThelper.RandomFloat(0.05,1.0)
      pep.core_mzs.each do |mzmu|

        fin_mzs = []
        fin_ints = []
        
        relative_abundances_int = relative_ints[index]
	
	t_index = 1

        pep.rts.each_with_index do |rt,i| 

          if !@one_d
            #-------------Tailing-------------------------
            shape = (tail * (t_index / sx)) + front
            fin_ints << (RThelper.gaussian((t_index / sx) ,mu ,shape,100.0)) * sy
            t_index += 1
            #---------------------------------------------

          else
            #-----------Random 1d data--------------------
            fin_ints<<(relative_abundances_int * ints_factor) * shuff
            #---------------------------------------------
          end

          if fin_ints[i] < 0.01
            fin_ints[i] = RThelper.RandomFloat(0.001,0.4) * sy
          end

=begin
    if !@one_d
      #-------------M/Z Peak shape (Profile?)-------
      fraction = RThelper.gaussian(fin_mzs[i],mzmu,0.05,1)
      factor = fraction/1.0
      fin_ints[i] = fin_ints[i] * factor
      #---------------------------------------------
    end
=end	  

          #-------------Jagged-ness---------------------
          sd = (@opts[:jagA] * (1-Math.exp(-(@opts[:jagC]) * fin_ints[i])) + @opts[:jagB])/2
          diff = (Distribution::Normal.rng(0,sd).call)
          fin_ints[i] = fin_ints[i] + diff
          #---------------------------------------------

          #-------------mz wobble-----------------------
          y = fin_ints[i]
          if y > 0
            wobble_int = @opts[:wobA]*y**(@opts[:wobB])
            wobble_mz = Distribution::Normal.rng(mzmu,wobble_int).call
            if wobble_mz < 0
              wobble_mz = 0.01
            end

            fin_mzs<<wobble_mz
          end
          #---------------------------------------------


          fin_ints[i] = fin_ints[i]*(predicted_int*(relative_abundances_int*10**-2))
        end

        pep.insert_ints(fin_ints)
        pep.insert_mzs(fin_mzs)

        index += 1
      end
      return pep
    end
  end
end
