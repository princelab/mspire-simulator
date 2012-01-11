
class ScanSettingsList
	
	def initialize(builder)
		#required
		@count
		@scanSettings
	
	end
end

class ScanSettings
	
	def initialize()
	
		@params
		@sourceFileRefList
		@targetList
		#required
		@id
	
	end
end

class SourceFileRefList
	
	def initialize()
		#required
		@count
		@sourceFileRefs
	
	end
end

class SourceFileRef
	
	def initialize()
		#required
		@ref
	
	end
end

class TargetList
	
	def initialize()
		#required
		@count
		@targets
	
	end
end

class Target
	
	def initialize()
		
		@params
	
	end
end
