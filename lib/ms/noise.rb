
require 'progress'
require 'ms/rt/rt_helper'

module MS
  module Noise
    module_function
    def noiseify(r_times,density,max_mz)
    # spectra is {rt => [[mzs],[ints]]}
      @start = Time.now
      @noise = {}
      
      count = 0.0
      r_times.each do |rt|
      
	Progress.progress("Adding noise:",(((count/r_times.size)*100).to_i))
      
	nmzs = []
	nints = []
	
	density.times do
	  rmz = RThelper.RandomFloat(0.0,max_mz)
	  rint = RThelper.RandomFloat(0.01,1.0)
	  
	  nmzs<<rmz
	  nints<<rint
	end
	@noise[rt] = [nmzs,nints]
	count += 1
      end
      
      Progress.progress("Adding noise:",100,Time.now-@start)
      puts ''
      
      return @noise
    end
    
    
    def spec_drops(r_times,drop_percentage)
      l = r_times.length
      num_drops = drop_percentage * l
      num_drops.to_i.times do 
	r_times.delete_at(rand(l+1))
      end

      return r_times
    end
    
  end
end
