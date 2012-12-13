
require 'progress'
require 'ms/rt/rt_helper'

module MS
  module Noise
    module_function
    def noiseify(opts,max_mz)
      # spectra is {rt => [[mzs],[ints]]}
      desity = opts[:noise_density]
      max_int = opts[:noiseMaxInt]
      min_int = opts[:noiseMinInt]
      @noise = {}
      r_times = Sim_Spectra.r_times
      count = 0
      prog = Progress.new("Adding noise:")
      num = 0
      total = r_times.size
      step = total/100.0
      r_times.each do |rt|
        if count > step * (num + 1)
          num = (((count/total)*100.0).to_i)
          prog.update(num)
        end
        nmzs = []
        nints = []
        density.times do
          rmz = RThelper.RandomFloat(0.0,max_mz)
          rint = RThelper.RandomFloat(min_int,max_int)
          nmzs<<rmz
          nints<<rint
        end
        @noise[rt] = [nmzs,nints]
        count += 1
      end
      prog.finish!
      return @noise
    end

    def spec_drops(drop_percentage)
      r_times = Sim_Spectra.r_times
      l = r_times.length
      num_drops = drop_percentage * l
      num_drops.to_i.times do 
        r_times.delete_at(rand(l+1))
      end
      return r_times
    end

  end
end
