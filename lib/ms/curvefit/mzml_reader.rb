require 'mspire'
require 'mspire/mzml'

class Mzml_reader
  def self.get_data(file)
    mzs_out = []
    rts_out = []
    ints_out = []
    io = File.open(file)
    mzml = Mspire::Mzml.new(io)

    mzml.each do |spec|
      next unless spec.ms_level == 1
      ints = spec.intensities
      mzs = spec.mzs
      rt = spec.retention_time

      if ints.empty?;else
        ints.each_with_index do |i,j|
          mzs_out<<mzs[j]
          rts_out<<rt
          ints_out<<i
        end
      end
    end
    return mzs_out,rts_out,ints_out
  end
end
