
class InsturmentConfigurationList
	include Writer
	
	def initialize()
		#required
		@count
		@insturmentConfigurations
	
	end
end

class InsturmentConfiguration
	include Writer
	
	def initialize()
	
		@params
		@componentList
		@softwareRef
		#required
		@id
		#optional
		@scanSettingsRef
	
	end
end

class ComponentList
	include Writer
	
	def initialize()
	
		@source
		@analyzer
		@detector
		#required
		@count
	
	end
end

class Source
	include Writer
	
	def initialize()
		
		@params
	
	end
end

class Analyzer
	include Writer
	
	def initialize()
		
		@params
	
	end
end

class Detector
	include Writer
	
	def initialize()
		
		@params
	
	end
end

class SoftwareRef
	include Writer
	
	def initialize()
		#required
		@ref
	
	end
end
