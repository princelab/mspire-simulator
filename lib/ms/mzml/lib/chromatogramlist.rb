require 'spectrumlist'

class ChromatogramList
	
	def initialize(builder)
		
		@chromatogram
		#required
		@count
		@defaultDataProcessingRef
	
	end
end

class Chromatogram
	
	def initialize()
		
		@params
		@precursor
		@product
		@binaryDataArrayList
		#required
		@id
		@defaultArrayLength
		@index
		#optional
		@dataProcessingRef
	
	end
end
