
require 'progress'
require 'ms/rt/rt_helper'

module MS
  module Noise
    module_function
    def noiseify(spectra,density)
      @start = Time.now
      max_mz = spectra.max_by{|key,val| val[0].max}[1][0][0]
      
      count = 0.0
      spectra.each_value do |data|
      
	Progress.progress("Adding noise:",(((count/spectra.size)*100).to_i))
      
	mzs = data[0]
	ints = data[1]
	
	density.times do
	  rmz = RThelper.RandomFloat(0.0,max_mz)
	  rint = RThelper.RandomFloat(0.1,2.0)
	  
	  mzs<<rmz
	  ints<<rint
	end
	count += 1
      end
      Progress.progress("Adding noise:",100,Time.now-@start)
      puts ''
      
      return spectra
    end
    
    def contaminate(spectra)
      
      #TODO: add precalculated contamination
      
      return spectra
    end
  end
end
