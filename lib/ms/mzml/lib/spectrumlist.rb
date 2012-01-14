require 'nokogiri'
require 'base64'
require 'zlib'
require 'ms/mzml/lib/runhelper' 

class SpectrumList
	
	def initialize(builder, spectra)
		#[mzs,rts,ints,groups] - spectra data
	
		spectra = spectra.transpose
		spectra = spectra.group_by {|x| x[1]}
	
		#required
		@count = 0
		@defaultDataProcessingRef = 'Ruby_Simulated' # Note must match one of dataProcessing
		init_xml(builder)
		count = 1
		spectra.each_value do |spectrum|
			Spectrum.new(builder,spectrum,count)
			count = count + 1
		end
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
end

class Spectrum
	
	def initialize(builder,spectrum,count)
	
		mzs = spectrum.collect {|x| x[0]} 
		ints = spectrum.collect {|x| x[2]} 
		time = spectrum[0][1]
		
		@params
		@scanList
		@precursorList
		@productList
		#required
		@id = "scan=#{count}"
		@defaultArrayLength = 1 
		@index = (count - 1)
		init_xml(builder,mzs,ints,time)
		#@binaryDataArrayList = BinaryDataArrayList.new(builder,spectrum[0],spectrum[2])
		#builder = @binaryDataArrayList.get_builder
		#optional
		@dataProcessingRef
		@spotId
		@sourceFileRef
	
	end
	
	def init_xml(builder,mzs,ints,time)
		mzs = array_to_mzml_string(mzs)
		ints = array_to_mzml_string(ints)
	
		b = Nokogiri::XML::Builder.with(builder.doc.at('spectrumList')) do |xml|
			xml.spectrum(:id=>@id, :defaultArrayLength=> @defaultArrayLength, :index=> @index){
				xml.cvParam(:cvRef=>"MS", :accession=>"MS:1000127", :name=>"centroid spectrum", :value=>"")
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
end

class ScanList
	
	def initialize()
	
		@params
		@scans
		#required
		@count
	
	end
end

class Scan
	
	def initialize()
	
		@params
		@scanWindowList
		#optional
		@externalSpectrumId
		@spectrumRef
		@sourceFileRef
		@insturmentConfigurationRef
	
	end
end

class ScanWindowList
	
	def initialize()
	
		@scanWindows
		#required
		@count
	
	end
end

class ScanWindow
	
	def initialize()
	
		@params
	
	end
end

class PrecursorList
	
	def initialize()
	
		@precursors
		#required
		@count
	
	end
end

class ProductList
	
	def initialize()
	
		@products
		#required
		@count
	
	end
end
