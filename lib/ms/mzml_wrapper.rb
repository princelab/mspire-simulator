
require 'nokogiri'
require 'progress'
require 'mspire/mzml' 

class Mzml_Wrapper

  def initialize(spectra)
    #spectra is a Hash rt=>[[mzs],[ints]]

    count = 0.0
    scan_number = 1
    specs = []
    prog = Progress.new("Converting to mzml:")
    num = 0
    total = spectra.size
    step = total/100
    spec_id = nil
    spectra.each do |rt,data|
      if count > step * (num + 1)
	num = (((count/total)*100).to_i)
	prog.update(num)
      end
      
      ms_level = data.ms_level # method added to array class
      
      if ms_level == 1
	spc = Mspire::Mzml::Spectrum.new("scan=#{scan_number}") do |spec|
	  spec.describe_many!(['MS:1000127', ['MS:1000511', 1]]) 
	  spec.data_arrays = [
	    Mspire::Mzml::DataArray.new(data[0]).describe!('MS:1000514'),  
	    Mspire::Mzml::DataArray.new(data[1]).describe!('MS:1000515')   
	  ]
	  spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
	    scan = Mspire::Mzml::Scan.new do |scan|
	      scan.describe! 'MS:1000016', rt, 'UO:0000010'
	    end
	    sl << scan
	  end
	end
      elsif ms_level == 2
	spc = Mspire::Mzml::Spectrum.new("scan=#{scan_number}") do |spec|
	  spec.describe_many!(['MS:1000127', ['MS:1000511', 2]]) 
	  spec.data_arrays = [
	    Mspire::Mzml::DataArray.new(data[0]).describe!('MS:1000514'),  
	    Mspire::Mzml::DataArray.new(data[1]).describe!('MS:1000515')   
	  ]
	  spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
	    scan = Mspire::Mzml::Scan.new do |scan|
	      scan.describe! 'MS:1000016', rt, 'UO:0000010'
	    end
	    sl << scan
	  end
	  precursor = Mspire::Mzml::Precursor.new( spec_id )
	  si = Mspire::Mzml::SelectedIon.new
	  # the selected ion m/z:
	  si.describe! "MS:1000744", data.pre_mz
	  # the selected ion charge state
	  si.describe! "MS:1000041", data.pre_charge
	  # the selected ion intensity
	  si.describe! "MS:1000042", data.pre_int
	  precursor.selected_ions = [si]
	  spec.precursors = [precursor]
	end
      end
      spec_id = spc.id #store id for possible ms2 spectra next
      count += 1
      scan_number += 1
      specs<<spc
    end



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
        spectrum_list = Mspire::Mzml::SpectrumList.new(default_data_processing, specs)
        run.spectrum_list = spectrum_list
      end
    end
    prog.finish!
    return @mzml
  end

  def to_xml(file)
    return @mzml.to_xml(file)
  end

end

