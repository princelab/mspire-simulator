
require 'ms/rt/rtgenerator'
require 'ms/sim_feature'
require 'ms/noise'

module MS
  class Sim_Spectra
    def initialize(peptides,sampling_rate, run_time, drop_percentage,file_name,density,one_d)
      @data
      @max_mz
      #RTS
      @r_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        @r_times<<spec_time+RThelper.RandomFloat(-0.5,0.5)
        spec_time = spec_time + (1/sampling_rate)
      end
      @r_times = MS::Noise.spec_drops(@r_times,drop_percentage)
      
      pre_features = MS::Rtgenerator.generateRT(peptides,@r_times,one_d)
      
      #Features
      features_o = MS::Sim_Feature.new(pre_features,@r_times,one_d)
      @features = features_o.features
      @data = features_o.data
      @max_mz = @data.max_by{|key,val| if val != nil;val[0].max;else;0;end}[1][0].max
      @spectra = @data
      
      @noise = nil
      
    end
    
    def noise
      @noise = MS::Noise.noiseify(@r_times,density,@max_mz)
      
      @r_times.each do |k|
	s_v = @data[k]
	n_v = @noise[k]
	if s_v != nil
	  @spectra[k] = [s_v[0]+n_v[0],s_v[1]+n_v[1]]
	else
	  @spectra[k] = [n_v[0],n_v[1]]
	end
      end
    end
    
    attr_reader :data, :r_times, :max_mz, :spectra, :noise, :features
    attr_writer :data, :r_times, :max_mz, :spectra, :noise, :features
    
  end
end

#charge ratio: take both charge states, determine pH effective
#more small peaks from lesser charge states

#one_d
#fit to other labs data - different machine
