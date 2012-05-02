
require 'nokogiri'
require 'progress'
require 'mspire/mzml' 

class Mzml_Wrapper

  def initialize(spectra)
  #spectra is a Hash rt=>[[mzs],[ints]]
    @start = Time.now
  
    @mzml = Mspire::Mzml.new do |mzml|
      mzml.id = 'ms1'
      mzml.cvs = Mspire::Mzml::CV::DEFAULT_CVS
      mzml.file_description = Mspire::Mzml::FileDescription.new  do |fd|
	fd.file_content = Mspire::Mzml::FileContent.new
	fd.source_files << Mspire::Mzml::SourceFile.new
      end
      default_instrument_config = Mspire::Mzml::InstrumentConfiguration.new("IC",[], params: ['MS:1000031'])
      mzml.instrument_configurations << default_instrument_config
      software = Mspire::Mzml::Software.new
      mzml.software_list << software
      default_data_processing = Mspire::Mzml::DataProcessing.new("did_nothing")
      mzml.data_processing_list << default_data_processing
      mzml.run = Mspire::Mzml::Run.new("simulated_run", default_instrument_config) do |run|
	spectrum_list = Mspire::Mzml::SpectrumList.new(default_data_processing)
	
	count = 0.0
	spectra.each do |rt,data|
	  Progress.progress("Converting to mzml:",(((count/spectra.size)*100).to_i))
	
	  spc = Mspire::Mzml::Spectrum.new('scan=1', params: ['MS:1000127', ['MS:1000511', 1]]) do |spec|
	    spec.data_arrays = data
	    spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
	      scan = Mspire::Mzml::Scan.new do |scan|
		scan.describe! 'MS:1000016', rt, 'UO:0000010'
	      end
	      sl << scan
	    end
	  end
	  spectrum_list.push(spc)
	  count += 1
	end
	Progress.progress("Converting to mzml:",100,Time.now-@start)
	puts ''
	
	run.spectrum_list = spectrum_list
      end
    end
    
    return @mzml
  end
  
  def to_xml(file)
    return @mzml.to_xml(file)
  end

end

