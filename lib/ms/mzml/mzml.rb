
require 'nokogiri'
require 'progress'
require 'ms/mzml' 

class Mzml_Wrapper

  def initialize(spectra)
  #spectra is a Hash rt=>[[mzs],[ints]]
    @start = Time.now
  
    @mzml = MS::Mzml.new do |mzml|
      mzml.id = 'ms1'
      mzml.cvs = MS::Mzml::CV::DEFAULT_CVS
      mzml.file_description = MS::Mzml::FileDescription.new  do |fd|
	fd.file_content = MS::Mzml::FileContent.new
	fd.source_files << MS::Mzml::SourceFile.new
      end
      default_instrument_config = MS::Mzml::InstrumentConfiguration.new("IC",[], params: ['MS:1000031'])
      mzml.instrument_configurations << default_instrument_config
      software = MS::Mzml::Software.new
      mzml.software_list << software
      default_data_processing = MS::Mzml::DataProcessing.new("did_nothing")
      mzml.data_processing_list << default_data_processing
      mzml.run = MS::Mzml::Run.new("simulated_run", default_instrument_config) do |run|
	spectrum_list = MS::Mzml::SpectrumList.new(default_data_processing)
	
	#spectrum_list.push(spec1, spec2)
	count = 0.0
	spectra.each do |rt,data|
	  Progress.progress("Converting to mzml:",(((count/spectra.size)*100).to_i))
	
	  spc = MS::Mzml::Spectrum.new('scan=1', params: ['MS:1000127', ['MS:1000511', 1]]) do |spec|
	    spec.data_arrays = data
	    spec.scan_list = MS::Mzml::ScanList.new do |sl|
	      scan = MS::Mzml::Scan.new do |scan|
		scan.describe! ['MS:1000016', rt, 'UO:0000010']
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

