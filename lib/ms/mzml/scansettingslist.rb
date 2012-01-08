
class ScanSettingsList
	include Writer
	
	def initialize()
		#required
		@count
		@scanSettings
	
	end
end

class ScanSettings
	include Writer
	
	def initialize()
	
		@params
		@sourceFileRefList
		@targetList
		#required
		@id
	
	end
end

class SourceFileRefList
	include Writer
	
	def initialize()
		#required
		@count
		@sourceFileRefs
	
	end
end

class SourceFileRef
	include Writer
	
	def initialize()
		#required
		@ref
	
	end
end

class TargetList
	include Writer
	
	def initialize()
		#required
		@count
		@targets
	
	end
end

class Target
	include Writer
	
	def initialize()
		
		@params
	
	end
end
