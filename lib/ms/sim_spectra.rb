$LOAD_PATH << './lib'
require 'ms/rt/rt_helper'
require 'ms/noise'
require 'ms/rt/rtgenerator'
require 'ms/sim_feature'

module MS
  class Sim_Spectra
    def initialize(peptides,opts,one_d = false)
      @opts = opts
      @data
      @max_mz
      sampling_rate = opts[:sampling_rate]
      run_time = opts[:run_time]
      drop_percentage = opts[:dropout_percentage]
      #RTS
      var = 0.1/(sampling_rate*2)
      @@r_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        @@r_times<<spec_time+RThelper.RandomFloat(-var,var)
        spec_time = spec_time + (1/sampling_rate)
      end
      @@r_times = MS::Noise.spec_drops(drop_percentage)

      pre_features = MS::Rtgenerator.generateRT(peptides,one_d)

      #Features
      features_o = MS::Sim_Feature.new(pre_features,opts,one_d)
      @features = features_o.features
      @data = features_o.data
      @max_mz = features_o.max_mz
      @spectra = @data.clone

      @noise = nil

    end

    def noiseify
      @noise = MS::Noise.noiseify(@opts,@max_mz)

      @@r_times.each do |k|
        s_v = @data[k]
        n_v = @noise[k]
        if s_v != nil
	  spec = [s_v[0]+n_v[0],s_v[1]+n_v[1]]
	  spec.ms_level = s_v.ms_level
	  spec.ms2 = s_v.ms2
          @spectra[k] = spec
        else
          spec = [n_v[0],n_v[1]]
	  spec.ms_level = 1
	  spec.ms2 = nil
          @spectra[k] = spec
        end
      end

      return @noise
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
