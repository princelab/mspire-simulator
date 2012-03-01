
require 'time'
require 'nokogiri'
require 'base64'
require 'zlib'
require 'ms/mzml/lib/runhelper' 
require 'ms/rt/rt_helper'

class SpectrumList
        
  def initialize(builder, spectra, noise, contaminate)
  
    #now have Hash rt=>[[mzs],[ints]]

    #required
    @count = 0
    @defaultDataProcessingRef = 'Ruby_Simulated' # Note must match one of dataProcessing
    init_xml(builder)
    count = 1
    @range_mz = spectra.max_by{|spec| spec[1][0].max}[1][0].max
    @start = Time.now
    
    
    #----------------Contaminate-----------------------
    #should be in spectra
    if contaminate == "true"
      for i in (1..70)
	Progress.progress("Contaminating:",((i/70.to_f)*100).to_i)
	contaminate(spectra)
      end
      Progress.progress("Contaminating:",100,Time.now-@start)
      puts ""
    end
    #---------------------------------------------------
    
    
    @start = Time.new
    spectra.each do |time,spectrum|
      Progress.progress("Converting data to mzml:",((count/spectra.size.to_f)*100).to_i)
      Spectrum.new(builder,time,spectrum,count,@range_mz,noise)
      count = count + 1
    end
    Progress.progress("Converting data to mzml:",100,Time.now-@start)
    puts ""
    @builder = builder
  
  end
  
  def init_xml(builder)
    b = Nokogiri::XML::Builder.with(builder.doc.at('run')) do |xml|
      xml.spectrumList(:count=>@count, :defaultDataProcessingRef=>@defaultDataProcessingRef)
    end
    return b
  end
  
  def get_builder
    return @builder
  end
  
  def contaminate(spectra)
    x_max = spectra.max[0]
    choice = []
    choice<<RThelper.RandomFloat(0.0,x_max)
    choice<<RThelper.RandomFloat(0.0,x_max)
    x_low = choice.min
    x_high = choice.max
    tmp = spectra.find_all{|i| i[0]<x_high and i[0]>x_low}
    x_cors = []
    tmp.each do |spectrum|
      x_cors<<spectrum[0]
    end
    if tmp.empty? == false
      mu = x_cors.inject(:+)/x_cors.size
      sd = RThelper.RandomFloat(x_low,x_high)/4
      mz = RThelper.RandomFloat(0.0,@range_mz)
      x_cors.each do |x|
        spectra[x][0]<<mz+RThelper.RandomFloat(0.0,2.0)
        int = (RThelper.gaussian(x,mu,sd)) * RThelper.RandomFloat(9.0,12.0)**2
        spectra[x][1]<<int
      end
    end
  end
end

class Spectrum
        
  def initialize(builder,time,spectrum,count,range_mz,noise)
  
    mzs = spectrum[0] 
    ints = spectrum[1] 
    @range_mz = range_mz
    #params
    #scanList
    #precursorList
    #productList
    #-required
    @id = "spectrum=#{count}"
    @defaultArrayLength = mzs.length 
    @index = (count - 1)
    init_xml(builder,mzs,ints,time,noise)
    #@binaryDataArrayList = BinaryDataArrayList.new(builder,spectrum[0],spectrum[2])
    #builder = @binaryDataArrayList.get_builder
    #-optional
    #dataProcessingRef
    #spotId
    #sourceFileRef
  
  end
  
  def init_xml(builder,mzs,ints,time,noise)
  
  
    #------------------------Noise---------------
    #should be in spectra
    if noise == "true"
      add_noise(mzs, ints)
    end
    #--------------------------------------------


    @defaultArrayLength = mzs.length 

    mzs = array_to_mzml_string(mzs)
    ints = array_to_mzml_string(ints)

    b = Nokogiri::XML::Builder.with(builder.doc.at('spectrumList')) do |xml|
      xml.spectrum(:id=>@id, :defaultArrayLength=> @defaultArrayLength, :index=> @index){
        xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000127", :name=>"centroid spectrum", :value=>"")
        xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000525", :name=>"spectrum representation")
        xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000511", :name=>"ms level", :value=>"1")
        xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000294", :name=>"mass spectrum")
        xml.scanList(:count=>1){
          xml.scan{
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000016", :name=>"scan start time", :value=>time, :unitCvRef=>"UO", :unitAccession=>"UO:0000010", :unitName=>"second")
          }
        }
        xml.binaryDataArrayList(:count=>2){
          xml.binaryDataArray(:encodedLength=>mzs.length){
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000523", :name=>"64-bit float", :value=>"")
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000574", :name=>"zlib compression", :value=>"")
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000514", :name=>"m/z array", :value=>"", :unitCvRef=>"MS", :unitAccession=>"MS:1000040", :unitName=>"m/z")
            xml.binary(mzs)
          }
          xml.binaryDataArray(:encodedLength=>ints.length){
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000523", :name=>"64-bit float", :value=>"")
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000574", :name=>"zlib compression", :value=>"")
            xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000515", :name=>"intensity array", :value=>"", :unitCvRef=>"MS", :unitAccession=>"MS:1000131", :unitName=>"number of counts")
            xml.binary(ints)
          }
        }
      }
    end
    return b
  end
  
  def array_to_mzml_string(array, precision='MS:1000523', compression=true)
    unpack_code = 
      case precision.to_s
      when 'MS:1000523' ; 'E*'
      when 'MS:1000521' ; 'e*'
      end
    string = array.pack(unpack_code)
    string = Zlib::Deflate.deflate(string) if compression
    Base64.strict_encode64(string)
  end
  
  def add_noise(mzs, ints)
    for i in (0..@range_mz)
      r = rand(100)
      if r > 80
        mzs<<RThelper.RandomFloat(0.0,@range_mz.to_f)
        ints<<RThelper.RandomFloat(0.0,RThelper.RandomFloat(1.0,4.0))
      end
    end
  end
end
