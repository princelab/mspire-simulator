
require 'nokogiri'
require 'progress'
require 'mspire/mzml' 

class Mzml_Wrapper

  def initialize(db,opts)
    prog = Progress.new("Converting to mzml:")
    #spectra is a Hash rt=>[[mzs],[ints]]
    db.execute "CREATE TABLE IF NOT EXISTS ms2(ms2_id INTEGER PRIMARY KEY,cent_id INTEGER,pep_id INTEGER,rt REAL,mzs TEXT,ints TEXT)" if opts[:ms2] == "true"
    sampling_rate = opts[:sampling_rate]
    noise_max = opts[:noiseMaxInt]
    count = 0.0
    scan_number = 1
    specs = []
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

      #grab top 2 centroids for ms2
      ms2s = []
      if opts[:ms2] == "true"
        top2 = ints.sort[-opts[:ms2s]..-1]
        top2.each do |top|
          if top > noise_max + 1000.0
            cent = data[ints.index(top)]
            ms2s<<cent if cent[1] != nil
          end
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
          if seq.size > 1
            charge = pep[0][1]
            ms2_mzs = MS::Fragmenter.new.fragment(seq)
            ms2_ints = Array.new(ms2_mzs.size,500.to_f)
            rt = cent[2] + RThelper.RandomFloat(0.01,sampling_rate - 0.1)
            db.execute "INSERT INTO ms2(cent_id,pep_id,rt,mzs,ints) VALUES(#{cent[0]},#{cent[1]},#{rt},'#{ms2_mzs}','#{ms2_ints}')"

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
          end
          specs<<spc2 if seq.size > 1
        end
      end
      count += 1
      scan_number += 1
    end



    @mzml = Mspire::Mzml.new do |mzml|
      mzml.id = 'ms1_and_ms2'
      mzml.cvs = Mspire::Mzml::CV::DEFAULT_CVS
      #mzml.cvs<<Mspire::Mzml::CV.new('Options',"#{opts}",'1')
      mzml.file_description = Mspire::Mzml::FileDescription.new  do |fd|
        fd.file_content = Mspire::Mzml::FileContent.new
        fd.file_content.cv_params<<Mspire::UserParam.new("Simulated Options","#{opts}","options")
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

