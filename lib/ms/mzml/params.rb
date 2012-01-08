
class Params
	include Writer
	
	def initialize()
	
		@referenceableParamGroupRef
		@cvParam
		@userParam
			
	end
end

class ReferenceableParamGroupRef
	include Writer
	
	def initialize()
	
		@ref
	
	end
end

class CvParam
	include Writer
	
	def initialize()
	
		#optional
		@unitCvRef
		@unitName
		@unitAccession
		@value
		#required
		@name
		@accession
		@cvRef
	
	end
end

class UserParam
	include Writer
	
	def initialize()
	
		#optional
		@unitCvRef
		@unitName
		@unitAccession
		@value
		@type
		#required
		@name
	
	end
end
