
class ChromatogramList
	include Writer
	
	def initialize()
		
		@chromatogram
		#required
		@count
		@defaultDataProcessingRef
	
	end
end

class Chromatogram
	include Writer
	
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
