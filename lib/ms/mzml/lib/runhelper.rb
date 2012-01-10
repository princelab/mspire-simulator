
class BinaryDataArrayList
	include Writer
	
	def initialize()
		#required
		@count
		@binaryDataArray
	
	end
end

class BinaryDataArray
	include Writer
	
	def initialize()
	
		@params
		@binary
		#required
		@encodeLength
		#optional
		@arrayLength
		@dataProcessingRef
	
	end
end

class Precursor
	include Writer
	
	def initialize()
	
		@isolationWindow
		@selectedIonList
		@activation
		#optional
		@externalSpectrumId
		@sourceFileRef
		@spectrumRef
	
	end
end

class IsolationWindow
	include Writer
	
	def initialize()
	
		@params
	
	end
end

class SelectedIonList
	include Writer
	
	def initialize()
	
		@selectedIons
		#required
		@count

	end
end

class SelectedIon
	include Writer
	
	def initialize()
	
		@params

	end
end

class Activation
	include Writer
	
	def initialize()
	
		@params

	end
end

class Product
	include Writer
	
	def initialize()
	
		@isolationWindow
	
	end
end

class IsolationWindow
	include Writer
	
	def initialize()
	
		@params
	
	end
end
