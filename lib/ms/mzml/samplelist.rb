
class SampleList
	include Writer
	
	def initialize()
		#required
		@count
		@samples
	
	end
end

class Sample
	include Writer
	
	def initialize()
		
		@params
		#required
		@id
		#optional
		@name
	
	end
end
