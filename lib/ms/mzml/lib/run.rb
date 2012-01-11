require 'nokogiri'

class Run
	
	def initialize(builder)
		
		@params
		@spectrumList
		@chromatogramList
		#required
		@id
		@defaultInsturmentConfigurationRef
		#optional
		@startTimeStamp
		@sampleRef
		@defaultSourceFileRef
	
	end
end
