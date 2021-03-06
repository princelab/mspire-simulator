require 'mspire/simulator/noise'
require 'mspire/simulator/feature'
require 'mspire/simulator/retention_time/generator'
require 'mspire/simulator/retention_time/helper'

module Mspire
  module Simulator
    class Spectra
      def initialize(opts,one_d = false,db)
        @opts = opts
        @max_mz
        sampling_rate = opts[:sampling_rate]
        run_time = opts[:run_time]
        drop_percentage = opts[:dropout_percentage]
        #RTS
        var = 0.1/(sampling_rate*2)
        @@r_times = []
        num_of_spec = sampling_rate*run_time
        spec_time = 1/sampling_rate
        num_of_spec.to_i.times do |k|
          @@r_times << spec_time + Mspire::Simulator::RetentionTime::Helper.RandomFloat(-var,var)
          spec_time = spec_time + (1/sampling_rate)
        end
        @@r_times = Mspire::Simulator::Noise.spec_drops(drop_percentage)

        Mspire::Simulator::RetentionTime::Generator.generateRT(one_d,db, @opts)

        #Features
        @features_o = Mspire::Simulator::Feature.new(@opts,one_d,db)
        @max_mz = @features_o.max_mz

      end

      def noiseify(db)
        @noise = Mspire::Simulator::Noise.noiseify(@opts,@max_mz)
        cent_id = @features_o.cent_id + 1
        @noise.each do |key,val|
          mzs = val[0]
          ints = val[1]
          mzs.each_with_index do |mz,index|
            db.execute "INSERT INTO spectra VALUES(#{cent_id},NULL,#{key},#{mz},#{ints[index]},NULL,-1)"
            cent_id += 1
          end
        end
      end

      def self.r_times
        @@r_times
      end

      attr_reader :max_mz
      attr_writer :max_mz

    end
  end
end
