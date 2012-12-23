
require 'nokogiri'
require 'progress'
require 'mspire/mzml' 

class Mzml_Wrapper

  def initialize(db,sampling_rate)
    #spectra is a Hash rt=>[[mzs],[ints]]
    ms2_count = 0
    count = 0.0
    scan_number = 1
    specs = []
    prog = Progress.new("Converting to mzml:")
    num = 0
    spectra = db.execute "SELECT * FROM spectra"
    total = spectra.size
    spectra_g = spectra.group_by{|spec| spec[2]} #rt
    step = total/100
    spec_id = nil
    spectra_g.sort.map do |rt,data|
      if count > step * (num + 1)
        num = (((count/total)*100).to_i)
        prog.update(num)
      end
      data_t = data.transpose
      mzs = data_t[3]
      ints = data_t[4]

      ms2s = []
      data.each do |cent| 
        if cent[6] == 1
          ms2s<<cent
        end
      end

      spc = Mspire::Mzml::Spectrum.new("scan=#{scan_number}") do |spec|
        spec.describe_many!(['MS:1000127', ['MS:1000511', 1]]) 
        spec.data_arrays = [
          Mspire::Mzml::DataArray.new(mzs).describe!('MS:1000514'),  
          Mspire::Mzml::DataArray.new(ints).describe!('MS:1000515')   
        ]
        spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
          scan = Mspire::Mzml::Scan.new do |scan|
            scan.describe! 'MS:1000016', rt, 'UO:0000010'
          end
          sl << scan
        end
      end
      specs<<spc
      if !ms2s.empty?
        #[rt,[mzs],[ints]]
        ms2s.each do |cent|
          pep = db.execute "SELECT seq,charge FROM peptides WHERE Id=#{cent[1]}"
          seq = pep[0][0]
          charge = pep[0][1]
          ms2_mzs = MS::Fragmenter.new.fragment(seq)
          ms2_ints = Array.new(ms2_mzs.size,500.to_f)
          rt = cent[2] + RThelper.RandomFloat(0.01,sampling_rate - 0.1)

          ms2_count += 1
          scan_number += 1
          spc2 = Mspire::Mzml::Spectrum.new("scan=#{scan_number}") do |spec|
            spec.describe_many!(['MS:1000127', ['MS:1000511', 2]]) 
            spec.data_arrays = [
              Mspire::Mzml::DataArray.new(ms2_mzs).describe!('MS:1000514'),  
              Mspire::Mzml::DataArray.new(ms2_ints).describe!('MS:1000515')   
            ]
            spec.scan_list = Mspire::Mzml::ScanList.new do |sl|
              scan = Mspire::Mzml::Scan.new do |scan|
                scan.describe! 'MS:1000016', rt, 'UO:0000010'
              end
              sl << scan
            end
            precursor = Mspire::Mzml::Precursor.new( spc.id )
            si = Mspire::Mzml::SelectedIon.new
            # the selected ion m/z:
            si.describe! "MS:1000744", cent[3] #pre_mz
            # the selected ion charge state
            si.describe! "MS:1000041", charge #pre_charge
            # the selected ion intensity
            si.describe! "MS:1000042", cent[4] #pre_int
            precursor.selected_ions = [si]
            spec.precursors = [precursor]
          end
          specs<<spc2
        end
      end
      count += 1
      scan_number += 1
    end



    @mzml = Mspire::Mzml.new do |mzml|
      mzml.id = 'ms1_and_ms2'
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
    puts "ms2 written = #{ms2_count}"
    return @mzml
  end

  def to_xml(file)
    return @mzml.to_xml(file)
  end

end

