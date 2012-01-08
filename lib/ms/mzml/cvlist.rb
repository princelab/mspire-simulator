
class CvList
	include Writer
	
	def initialize()
	
		@cvs
		#attributes - required
		@count
	
	end
end

class Cv
	include Writer
	
	def initialize()

		#attributes - required
		@uri
		@fullName
		@id
		#optional 
		@version
		
	end
end
