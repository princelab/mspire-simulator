
require 'nokogiri'
require 'progress'
require 'mspire/mzml' 

class Mzml_Wrapper

  def initialize(spectra)
  #spectra is a Hash rt=>[[mzs],[ints]]
    @start = Time.now
  
    
    count = 0.0
    scan_number = 1
    spectra.each do |rt,data|
      Progress.progress("Converting to mzml:",(((count/spectra.size)*100).to_i))

      @spc = Mspire::Mzml::Spectrum.new("scan=#{scan_number}") do |spec|
	spec.describe_many!(['MS:1000127', ['MS:1000511', 1]])
	spec.data_arrays = [
	  Mspire::Mzml::DataArray[1,2,3].describe!('MS:1000514'),  
	  Mspire::Mzml::DataArray[4,5,6].describe!('MS:1000515')   
	]
	spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
	  scan = Mspire::Mzml::Scan.new do |scan|
	    scan.describe! 'MS:1000016', rt, 'UO:0000010'
	  end
	  sl << scan
	end
      end
      count += 1
      scan_number += 1
    end
    Progress.progress("Converting to mzml:",100,Time.now-@start)
    puts ''
  
  
    @mzml = Mspire::Mzml.new do |mzml|
      mzml.id = 'ms1'
      mzml.cvs = Mspire::Mzml::CV::DEFAULT_CVS
      mzml.file_description = Mspire::Mzml::FileDescription.new  do |fd|
	fd.file_content = Mspire::Mzml::FileContent.new
	fd.source_files << Mspire::Mzml::SourceFile.new
      end
      default_instrument_config = Mspire::Mzml::InstrumentConfiguration.new("IC").describe!('MS:1000031')
      mzml.instrument_configurations << default_instrument_config
      software = Mspire::Mzml::Software.new
      mzml.software_list << software
      default_data_processing = Mspire::Mzml::DataProcessing.new("did_nothing")
      mzml.data_processing_list << default_data_processing
      mzml.run = Mspire::Mzml::Run.new("simulated_run", default_instrument_config) do |run|
	spectrum_list = Mspire::Mzml::SpectrumList.new(default_data_processing, @spc)
	run.spectrum_list = spectrum_list
      end
    end
    return @mzml
  end
  
  def to_xml(file)
    return @mzml.to_xml(file)
  end

end

