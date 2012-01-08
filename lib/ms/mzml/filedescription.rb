
class FileDescription
	include Writer
	
	def initialize()
	
		@fileContent
		@sourceFileList
		@contact
	
	end
end

class FileContent
	include Writer
	
	def initialize()
	
		@params
	
	end
end

class SourceFileList
	include Writer
	
	def initialize()
		#required
		@count
		@sourceFiles
	
	end
end

class SourceFile
	include Writer
	
	def initialize()
		#required
		@location
		@name
		@id
		@params
	
	end
end

class Contact
	include Writer
	
	def initialize()
		
		@params
	
	end
end
