
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
	scan_number = 1
	spectra.each do |rt,data|
	  Progress.progress("Converting to mzml & merging overlaps:",(((count/spectra.size)*100).to_i))
	  
	  data = merge(data)
  
	  spc = Mspire::Mzml::Spectrum.new("scan=#{scan_number}", params: ['MS:1000127', ['MS:1000511', 1]]) do |spec|
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
	  scan_number += 1
	end
	Progress.progress("Converting to mzml & merging overlaps:",100,Time.now-@start)
	puts ''
	
	run.spectrum_list = spectrum_list
      end
    end
    
    return @mzml
  end
  
  def w_avg(values,weights)
    a = []
    values.each_with_index{|v,i| a<<v*weights[i]}
    a = a.inject(:+)
    b = weights.inject(:+)
    return a/b
  end
  
  def member(m,mz,range)
    if m == mz
      return false
    elsif range.member?(m)
      return true
    else
      return false
    end
  end
  
  def merge(data)
    overlaps = []
    big_groups = []
    mzs = data[0].clone
    ints = data[1].clone
    
    mzs.clone.each do |mz|
      a = (mz-0.0001)
      b = (mz+0.0001)
      range = (a..b)
      group = mzs.find_all{|m| member(m,mz,range)}
      
      if !group.empty?
	group<<mz
	group.map!{|m| mzs.index(m)}
	if group.size > 2
	  big_groups<<group
	else
	  overlaps<<group
	end
      end
    end
    
    overlaps.map!{|a| a.sort}.uniq!
    #bigger groups than two
    if !big_groups.empty?
      big_groups.sort_by{|b| b.size}.each do |b|
	overlaps.clone.each do |a|
	  if a & b != []
	    overlaps.delete(a)
	  end
	end
	overlaps<<b
      end
    end
    #end
    
    if !overlaps.empty?
      overlaps.each do |ol|
	new_int = 0
	new_mz = 0
	n_mzs = []
	n_ints = []
	nils = []
	ol.each{|i| new_int += ints[i]; n_mzs<<mzs[i]; n_ints<<ints[i]; nils<<i}
	new_mz = w_avg(n_mzs,n_ints)
	ints<<new_int
	mzs<<new_mz
	nils.each{|i| ints[i] = nil; mzs[i] = nil}
      end
    end
    return [mzs.compact,ints.compact]
  end
  
  def to_xml(file)
    return @mzml.to_xml(file)
  end

end

