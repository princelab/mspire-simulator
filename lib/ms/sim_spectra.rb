
require 'ms/rt/rtgenerator'
require 'ms/sim_feature'
require 'ms/noise'

module MS
  class Sim_Spectra
    def initialize(peptides,sampling_rate, run_time, drop_percentage = 0.12,density = 10.0,one_d = false)
      @density = density
      @data
      @max_mz
      #RTS
      @@r_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        @@r_times<<spec_time#+RThelper.RandomFloat(-0.5,0.5)
        spec_time = spec_time + (1/sampling_rate)
      end
      @@r_times = MS::Noise.spec_drops(drop_percentage)
      
      pre_features = MS::Rtgenerator.generateRT(peptides,one_d)
      
      #Features
      features_o = MS::Sim_Feature.new(pre_features,one_d)
      @features = features_o.features
      @data = features_o.data
      @max_mz = @data.max_by{|key,val| if val != nil;val[0].max;else;0;end}[1][0].max
      @spectra = @data
      
      @noise = nil
      
    end
    
    def noiseify
      @noise = MS::Noise.noiseify(@density,@max_mz)
      
      @@r_times.each do |k|
	s_v = @data[k]
	n_v = @noise[k]
	if s_v != nil
	  @spectra[k] = [s_v[0]+n_v[0],s_v[1]+n_v[1]]
	else
	  @spectra[k] = [n_v[0],n_v[1]]
	end
      end
    end
    
    def self.r_times
      @@r_times
    end
    
    attr_reader :data, :max_mz, :spectra, :noise, :features
    attr_writer :data, :max_mz, :spectra, :noise, :features
    
  end
end

#charge ratio: take both charge states, determine pH effective
#more small peaks from lesser charge states

#one_d
#fit to other labs data - different machine
