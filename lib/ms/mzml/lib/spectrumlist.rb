
class SpectrumList
	include Writer
	
	def initialize()
	
		@spectrum
		#required
		@count
		@defaultDataProcessingRef
	
	end
end

class Spectrum
	include Writer
	
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
end

class ScanList
	include Writer
	
	def initialize()
	
		@params
		@scans
		#required
		@count
	
	end
end

class Scan
	include Writer
	
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
	include Writer
	
	def initialize()
	
		@scanWindows
		#required
		@count
	
	end
end

class ScanWindow
	include Writer
	
	def initialize()
	
		@params
	
	end
end

class PrecursorList
	include Writer
	
	def initialize()
	
		@precursors
		#required
		@count
	
	end
end

class ProductList
	include Writer
	
	def initialize()
	
		@products
		#required
		@count
	
	end
end
