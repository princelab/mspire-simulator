require 'nokogiri'

class DataProcessingList
	
	def initialize(builder)
		#required
		@count = 1
		init_xml(builder)
		@dataProcessings = DataProcessing.new(builder)
		@builder = builder
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('mzML')) do |xml|
			xml.dataProcessingList(:count=>@count)
		end
		return b
	end
	
	def get_builder
		return @builder
	end
end

class DataProcessing
	
	def initialize(builder)
		#required
		@id = 'Ruby_Simulated'
		init_xml(builder)
		@processingMethod = ProcessingMethod.new(builder)
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('dataProcessingList')) do |xml|
			xml.dataProcessing(:id=>@id)
		end
		return b
	end
end

class ProcessingMethod
	
	def initialize(builder)
		
		@params
		#required
		@order = 1
		@softwareRef = 'MS-Simulate' # Note must match one of software id
		init_xml(builder)
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('dataProcessing')) do |xml|
			xml.processingMethod(:order=>@order, :softwareRef=>@softwareRef){
				xml.userParam(:name=>'MS-Simulate')
			}
		end
		return b
	end
end
