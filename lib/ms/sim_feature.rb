require 'time'
require 'distribution'
require 'fragmenter'
require 'ms/sim_peptide'
require 'ms/rt/rt_helper'
require 'ms/tr_file_writer'

module MS
  class Sim_Feature 
    def initialize(opts,one_d,db)
      @db = db
      @one_d = one_d
      @opts = opts
      @max_mz = -1


      #------------------Each_Peptide_=>_Feature----------------------
      prog = Progress.new("Generating features:")
      num = 0
      @db.execute "CREATE TABLE IF NOT EXISTS spectra(cent_id INTEGER PRIMARY KEY,pep_id INTEGER,rt REAL,mzs REAL,ints REAL,merge_id INTEGER,ms2_bool INTEGER)"
      @cent_id = 0
      peps = @db.execute "SELECT * FROM peptides"
      total = peps.size
      step = total/100.0
      peps.each do |pep|
        ind = pep[0]
        if ind > step * (num + 1)
          num = (((ind+1)/total.to_f)*100).to_i
          prog.update(num)
        end
        
        getInts(pep)
      end
      prog.finish!
    end

    attr_reader :max_mz, :cent_id
    attr_writer :max_mz, :cent_id

    # Intensities are shaped in the rt direction by a gaussian with 
    # a dynamic standard deviation.
    # They are also shaped in the m/z direction 
    # by a simple gaussian curve (see 'factor' below). 
    #
    def getInts(pep)
      pep_id = pep[0]
      p_int = pep[7] + RThelper.RandomFloat(-5,2)
      if p_int > 10
        p_int -= 10
      end
      predicted_int = (p_int * 10**-1) * 14183000.0 
      low = 0.1*predicted_int
      relative_ints = (@db.execute "SELECT int FROM core_ints_#{pep_id}").flatten#pep.core_ints
      core_mzs = (@db.execute "SELECT mz FROM core_mzs_#{pep_id}").flatten#pep.core_ints
      @db.execute "CREATE TABLE IF NOT EXISTS f_#{pep_id}(rt REAL,mz REAL,int REAL)"
      avg = pep[5] #p_rt

      sampling_rate = @opts[:sampling_rate].to_f
      wobA = Distribution::Normal.rng(@opts[:wobA].to_f,0.0114199604).call #0.0014199604 is the standard deviation from Hek_cells_100904050914 file
      wobB = Distribution::Normal.rng(@opts[:wobB].to_f,0.01740082).call #1.20280082 is the standard deviation from Hek_cells_100904050914 file
      tail = Distribution::Normal.rng(@opts[:tail].to_f,0.018667495).call #0.258667495 is the standard deviation from Hek_cells_100904050914 file
      front = Distribution::Normal.rng(@opts[:front].to_f,0.01466692).call #4.83466692 is the standard deviation from Hek_cells_100904050914 file
      # These number didn't work. May need to get more samples or figure something else out. For now this will give us some
      # meta variance in any case
      mu = @opts[:mu].to_f

      index = 0
      sx = pep[9]
      sy = (sx**-1) * Math.sqrt(pep[8]) #abu

      shuff = RThelper.RandomFloat(0.05,1.0)
      core_mzs.each do |mzmu|

        relative_abundances_int = relative_ints[index]

        t_index = 1

        (Sim_Spectra::r_times[pep[10]..pep[11]]).each_with_index do |rt,i| 
          

          if !@one_d
            #-------------Tailing-------------------------
            shape = (tail * (t_index / sx)) + front
            int = (RThelper.gaussian((t_index / sx) ,mu ,shape,100.0))
            t_index += 1
            #---------------------------------------------

          else
            #-----------Random 1d data--------------------
            int = (relative_abundances_int * ints_factor) * shuff
            #---------------------------------------------
          end

          if int < 0.01
            int = RThelper.RandomFloat(0.001,0.4)
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

          if int > 0.4
          #-------------Jagged-ness---------------------
          sd = (@opts[:jagA] * (1-Math.exp(-(@opts[:jagC]) * int)) + @opts[:jagB])/2
          diff = (Distribution::Normal.rng(0,sd).call)
          int += diff
          #---------------------------------------------
          end

          #-------------mz wobble-----------------------
          wobble_mz = nil
          if int > 0
            wobble_int = wobA*int**wobB
            wobble_mz = Distribution::Normal.rng(mzmu,wobble_int).call
            if wobble_mz < 0
              wobble_mz = 0.01
            end
          end
          #---------------------------------------------


          int = int*(predicted_int*(relative_abundances_int*10**-2)) * sy
          if int > low.abs and wobble_mz > 0
            @db.execute "INSERT INTO spectra VALUES(#{@cent_id},#{pep_id},#{rt},#{wobble_mz},#{int},NULL,0)"
            @cent_id += 1
            if @max_mz < wobble_mz
              @max_mz = wobble_mz
            end
          end
        end
        index += 1
      end
    end
  end
end
