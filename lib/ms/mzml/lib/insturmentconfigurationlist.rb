require 'params'
require 'nokogiri'

class InsturmentConfigurationList
	
	def initialize(builder)
		#required
		@count = 1
		init_xml(builder)
		@insturmentConfigurations = InsturmentConfiguration.new(builder)
		@builder = builder
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('mzML')) do |xml|
			xml.instrumentConfigurationList(:count=>@count)
		end
		return b
	end
	
	def get_builder
		return @builder
	end
end

class InsturmentConfiguration
	
	def initialize(builder)
	
		@params
		@componentList
		@softwareRef
		#required
		@id = 'IC1'
		init_xml(builder)
		#optional
		@scanSettingsRef
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('instrumentConfigurationList')) do |xml|
			xml.instrumentConfiguration(:id=>@id)
		end
		return b
	end
end

class ComponentList
	
	def initialize()
	
		@source
		@analyzer
		@detector
		#required
		@count
	
	end
end

class Source
	
	def initialize()
		
		@params
	
	end
end

class Analyzer
	
	def initialize()
		
		@params
	
	end
end

class Detector
	
	def initialize()
		
		@params
	
	end
end

class SoftwareRef
		
	def initialize()
		#required
		@ref
	
	end
end
