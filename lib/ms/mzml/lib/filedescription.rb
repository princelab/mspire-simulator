require 'params'
require 'nokogiri'

class FileDescription
	
	def initialize(builder)
	
		init_xml(builder)
		@fileContent = FileContent.new(builder)
		#each file needs a location, name, id, and accession number
		file = ['some_location', 'some_name', 'file=1', 'MS:1001348']
		sourceFiles = [file]
		@sourceFileList = SourceFileList.new(builder,sourceFiles)
		@contact = Contact.new(builder)
		
		@builder = builder
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('mzml')) do |xml|
			xml.fileDescription
		end
		return b
	end
	
	def get_builder
		return @builder
	end
end

class FileContent
	
	def initialize(builder)
	
		@cvParam = MS::CV::Param.new('MS:1000294')
		builder = init_xml(builder)
		#@params = Params.new(builder,'MS:1000294') TODO
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('fileDescription')) do |xml|
			xml.fileContent{
				xml.cvParam(:cvRef=>@cvParam.cv_ref, :accession=>@cvParam.accession ,:name=>@cvParam.name)
			}
		end
		return b
	end
end

class SourceFileList
	
	def initialize(builder, sourceFiles)
	
		#required
		@count = 1 #TODO
		init_xml(builder)
		@sourceFiles = Array.new
		sourceFiles.each do |file|
			@sourceFiles.push(SourceFile.new(builder,file))
		end
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('fileDescription')) do |xml|
			xml.sourceFileList(:count=>@count)
		end
		return b
	end
end

class SourceFile
	
	def initialize(builder,file)
		#required
		@location = file[0]
		@name = file[1]
		@id = file[2]
		#@params = Params.new(builder,file[3]) TODO
		@cvParam = MS::CV::Param.new(file[3])
		init_xml(builder)
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('sourceFileList')) do |xml|
			xml.sourceFile(:id=>@id, :name=>@name, :location=>@location){
				xml.cvParam(:cvRef=>@cvParam.cv_ref, :accession=>@cvParam.accession ,:name=>@cvParam.name)
			}
		end
		return b
	end
end

class Contact
	
	def initialize(builder, name = 'SOME_NAME')
		
		@params
		@name = name
		init_xml(builder)
	
	end
	
	def init_xml(builder)
		b = Nokogiri::XML::Builder.with(builder.doc.at('fileDescription')) do |xml|
			xml.contact{
				xml.userParam(:name=>@name)
			}
		end
		return b
	end
end
