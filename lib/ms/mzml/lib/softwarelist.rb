require 'nokogiri'

class SoftwareList
	
	def initialize(builder)
		#required
		@count = 1
		init_xml(builder)
		@softwares = Software.new(builder)
		@builder = builder
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('mzML')) do |xml|
			xml.softwareList(:count=>@count)
		end
		return b
	end
	
	def get_builder
		return @builder
	end
end

class Software
	
	def initialize(builder)
	
		#@params
		#required
		@version = '1.0.0'
		@id = 'MS-Simulate'
		init_xml(builder)
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('softwareList')) do |xml|
			xml.software(:id=>@id, :version=>@version){
				xml.userParam(:name=>'MS-Simulate')
			}
		end
		return b
	end
end
