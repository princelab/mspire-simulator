require 'msplat'
require 'nokogiri'
require 'filedescription'

class Mzml

	def initialize(builder)
	#things needed:
	#each file needs a location, name, id, and accession number
		file = ['some_location', 'some_name', 'file=1', 'MS:1001348']
	#array of iles
		sourceFiles = [file]
	#fileContent cvParam accession number
		'MS:1000294'
	#Contact name
		'SOME_NAME'
	
	
		@cvList
		@fileDescription = FileDescription.new(builder)
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
		
		@builder = @fileDescription.get_builder

	end
	
	def get_builder
		return @builder
	end
end

builder = Nokogiri::XML::Builder.new do |xml|

	xml.mzml{
		xml.cvList(:count=>2){
			xml.cv(:id=>"MS", :fullName=>"Proteomics Standards Initiative Mass Spectrometry Ontology", :version=>"1.18.2", :URI=>"http://psidev.cvs.sourceforge.net/*checkout*/psidev/psi/psi-ms/mzML/controlledVocabulary/psi-ms.obo")
			xml.cv(:id=>"UO", :fullName=>"Unit Ontology", :version=>"04:03:2009", :URI=>"http://obo.cvs.sourceforge.net/*checkout*/obo/obo/ontology/phenotype/unit.obo")
		}
	}

end
puts Mzml.new(builder).get_builder.to_xml


