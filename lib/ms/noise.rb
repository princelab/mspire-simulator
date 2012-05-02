
require 'progress'
require 'ms/rt/rt_helper'

module MS
  module Noise
    module_function
    def noiseify(spectra,density,drop_percentage)
    # spectra is {rt => [[mzs],[ints]]}
      @start = Time.now
      spectra.each_key{|k| if spectra[k] == nil; spectra[k] = [[0.001],[0.001]]; end}
      spectra = Hash[ spectra.map {|k,v| [k+RThelper.RandomFloat(-0.5,0.5), v] } ]
      max_mz = spectra.max_by{|key,val| val[0].max}[1][0].max
      
      count = 0.0
      spectra.each_value do |data|
      
	Progress.progress("Adding noise:",(((count/spectra.size)*100).to_i))
      
	mzs,ints = data
	
	density.times do
	  rmz = RThelper.RandomFloat(0.0,max_mz)
	  rint = RThelper.RandomFloat(0.01,1.0)
	  
	  mzs<<rmz
	  ints<<rint
	end
	count += 1
      end
      
      #Dropouts
      r_times = spectra.keys
      l = r_times.length
      drops = []
      num_drops = drop_percentage * l
      num_drops.to_i.times do 
	drops<<r_times[rand(l+1)]
      end
      
      spectra.delete_if{|k,v| drops.include?(k)}
      Progress.progress("Adding noise:",100,Time.now-@start)
      puts ''
      
      return spectra
    end
  end
end
