
require 'ms/rt/rtgenerator'
require 'ms/sim_feature'

module MS
  class Spectra
    def initialize(peptides,sampling_rate, run_time)
      @data
      #RTS and multiply
      r_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        r_times<<spec_time
        spec_time = spec_time + (1/sampling_rate)
      end
      
      pre_features = MS::Rtgenerator.generateRT(peptides,r_times)
      
      #Features
      @data = MS::Sim_Feature.new(pre_features,r_times).data
      #create_spectrum(@data)

    end
    
    attr_reader :data
    attr_writer :data
    
  end
end
