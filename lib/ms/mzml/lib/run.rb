require 'nokogiri'
require 'time'
require 'ms/mzml/lib/spectrumlist'
require 'ms/mzml/lib/chromatogramlist' 

class Run
	
	def initialize(builder,spectra)
		
		#required
		@id = 'run1'
		@defaultInstrumentConfigurationRef = 'IC1' # Note must match one of insturmentConfiguration
		#optional
		@startTimeStamp = Time.now.round(5).iso8601(5)
		@sampleRef
		@defaultSourceFileRef
		init_xml(builder)
		@params
		@spectrumList = SpectrumList.new(builder,spectra)
			builder = @spectrumList.get_builder
		#@chromatogramList = ChromatogramList.new(builder)#maybe put Total Ion Count here
			#builder = @chromatogramList.get_builder
		@builder = builder
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('mzML')) do |xml|
			xml.run(:id=>@id, :defaultInstrumentConfigurationRef=>@defaultInstrumentConfigurationRef, :startTimeStamp=>@startTimeStamp)
		end
		return b
	end
	
	def get_builder
		return @builder
	end
end
