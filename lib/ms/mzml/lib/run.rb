
class Run
	include Writer
	
	def initialize()
		
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
