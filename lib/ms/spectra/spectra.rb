
require 'ms/rt/rtgenerator'
require 'ms/feature/feature'

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
      
      pre_features = MS::Rtgenerator.new.generateRT(peptides,r_times,run_time)
      #pre_features = [peptide_groups]
      #Features
      @data = MS::Feature::Feature.new(pre_features).data
      #create_spectrum(@data)
    end
    
    attr_reader :data
    attr_writer :data
    
  end
end
