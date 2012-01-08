require 'ms/peptide'

module Writer
	
end

class Mzml
	include Writer

	def initialize()
	
		@cvList
		@fileDescription
		@referenceableParamGroupList
		@sampleList
		@softwareList
		@scanSettingsList
		@insturmentConfigurationList
		@dataProcessingList
		@run
		#attributes - only version is required
		@version
		@id
		@accession

	end
end
