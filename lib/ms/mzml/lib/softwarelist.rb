
class SoftwareList
	include Writer
	
	def initialize()
		#required
		@count
		@softwares
	
	end
end

class Software
	include Writer
	
	def initialize()
	
		@params
		#required
		@version
		@id
	
	end
end
