
class DataProccessingList
	include Writer
	
	def initialize()
		#required
		@count
		@dataProccessings
	
	end
end

class DataProccessing
	include Writer
	
	def initialize()
		#required
		@id
		@proccessingMethod
	
	end
end

class ProccessingMethod
	include Writer
	
	def initialize()
		
		@params
	
	end
end
