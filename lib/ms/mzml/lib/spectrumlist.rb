require 'nokogiri'

class SpectrumList
	
	def initialize(builder)
	
		#required
		@count = 0
		@defaultDataProcessingRef = 'Ruby_Simulated' # Note must match one of dataProcessing
		init_xml(builder)
		#@spectrum = Spectrum.new(builder)
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
	
	def initialize()
	
		@params
		@scanList
		@precursorList
		@productList
		@binaryDataArrayList
		#required
		@id 
		@defaultArrayLength 
		@index  
		#optional
		@dataProcessingRef
		@spotId
		@sourceFileRef
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('spectrumList')) do |xml|
			#xml.spectrum(:id=>'', :defaultArrayLength=> , :index=> )
		end
		return b
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
