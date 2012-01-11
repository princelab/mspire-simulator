require 'msplat'
require 'nokogiri'
require 'filedescription'
require 'softwarelist'
require 'insturmentconfigurationlist'
require 'dataprocessinglist'
require 'run'

class Mzml

	def initialize(builder)
	
		@cvList # may not be needed
		@fileDescription = FileDescription.new(builder)
		@referenceableParamGroupList # may not be needed
		@sampleList # may not be needed
		@softwareList = SoftwareList.new(builder)
		@scanSettingsList # may not be needed
		@insturmentConfigurationList = InsturmentConfigurationList.new(builder)
		@dataProcessingList = DataProcessingList.new(builder)
		@run = Run.new(builder)
		#attributes - only version is required
		@version
		@id
		@accession
		
		@builder = @run.get_builder

	end
	
	def get_builder
		return @builder
	end
end

builder = Nokogiri::XML::Builder.new do |xml|
xml.indexedmzML(:xmlns=>"http://psi.hupo.org/ms/mzml", :'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance", :'xsi:schemaLocation'=>"http://psi.hupo.org/ms/mzml http://psidev.info/files/ms/mzML/xsd/mzML1.1.0_idx.xsd"){
	xml.mzML(:xmlns=>"http://psi.hupo.org/ms/mzml", :'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance", :'xsi:schemaLocation'=>"http://psi.hupo.org/ms/mzml http://psidev.info/files/ms/mzML/xsd/mzML1.1.0.xsd", :id=>"", :version=>"1.1.0"){
		xml.cvList(:count=>2){
			xml.cv(:id=>"MS", :fullName=>"Proteomics Standards Initiative Mass Spectrometry Ontology", :version=>"1.18.2", :URI=>"http://psidev.cvs.sourceforge.net/*checkout*/psidev/psi/psi-ms/mzML/controlledVocabulary/psi-ms.obo")
			xml.cv(:id=>"UO", :fullName=>"Unit Ontology", :version=>"04:03:2009", :URI=>"http://obo.cvs.sourceforge.net/*checkout*/obo/obo/ontology/phenotype/unit.obo")
		}
	}
}
end

built = Mzml.new(builder).get_builder

puts built.to_xml

File.open('testMzml.mzml', 'w') do |output|
	output.write(built.to_xml)
end

