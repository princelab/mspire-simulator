#!/usr/bin/env ruby

require 'time'

=begin
http://www.peptideatlas.org/tmp/mzML1.1.0.html
Above is the URL for the schema documentation.

A few guidlines that I tried to follow in creating the classes:

Naming: 
each of the classes start with 'Mzml'
whatever comes after is the name of the tag that the class represents

Class Variables:
Except for the counting attributes, each of the class variables are attributes associated with the tag
Unless the attribute name specifically names something as a '-List,' I added '-Arr' to signify that I want an array there

Constructor:
The order of the parameters is determined in the following order:
necessity (the schema requires that this information be present, as opposed to it being optional)
schema order (the order that the attributes were put in the schema)
inheritance (a subclass leaves superclass parameters for last)

The order of the classes was actually dictated by the way I looked up the information in the schema.
I started at the top of the schema, and then went depth-first through the tags.

I haven't implemented any checking or assertions (except where they are needed - an example is MzmlspectrumList)
=end

module AnoyceProject

class Mzmlcv
	attr_accessor :id, :name, :version, :uri
	def initialize(in_id, in_name, in_version, in_uri)
		@id = in_id
		@name = in_name
		@version = in_version
		@uri = in_uri
	end
end

class MzmlfileDescription
	attr_accessor :fileContent, :sourceFileList, :contactArr
	def initialize(in_fileContent, in_sourceFileList=nil, in_contact=nil)
		@fileContent = in_fileContent
		@sourceFileList = in_sourceFileList
		@contactArr = in_contact
	end
end

=begin
This is one of two classes in the module that isn't directly related to a tag.
It is the superclass of many of the other classes, since so many other tags have the option of holding this information
Note that unlike the other classes, the second word is capitalized.
=end
class MzmlParamArr
	attr_accessor :referenceableParamGroupRefArr, :cvParamArr, :userParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		@referenceableParamGroupRefArr = in_referenceableParamGroupRefArr
		@cvParamArr = in_cvParamArr
		@userParamArr = in_userParamArr
	end
end

class MzmlfileContent < MzmlParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
	end
end

class MzmlsourceFile < MzmlParamArr
	attr_accessor :id, :name, :location
	def initialize(in_id, in_name, in_location, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@name = in_name
		@location = in_location
	end
end

class Mzmlcontact < MzmlParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
	end
end

=begin
This was somewhat annoying, since I couldn't actually inherit from MzmlParamArr.
In mzmlFormatter, I still used MzmlParamArrPrinter, but I had to call the individual functions instead of the general 'print' function to get the information out of this class
=end
class MzmlreferenceableParamGroup
	attr_accessor :id, :cvParamArr, :userParamArr
	def initialize(in_id, in_cvParamArr=nil, in_userParamArr=nil)
		@id = in_id
		@cvParamArr = in_cvParamArr
		@userParamArr = in_userParamArr
	end
end

class MzmlreferenceableParamGroupRef
	attr_accessor :ref
	def initialize(in_ref)
		@ref = in_ref
	end
end

class MzmlcvParam
	attr_accessor :accession, :cvRef, :name, :unitAccesion, :unitCvRef, :unitName, :value
	def initialize(in_accession, in_cvRef, in_name, in_unitAccession=nil, in_unitCvRef='nil', in_unitName=nil, in_value=nil)
		@accession = in_accession
		@cvRef = in_cvRef
		@name = in_name
		@unitAccession = in_unitAccession
		@unitCvRef = in_unitCvRef
		@unitName = in_unitName
		@value = in_value
	end
end

class MzmluserParam
	attr_accessor :name, :type, :unitAccession, :unitCvRef, :unitName, :value
	def initialize(in_name, in_type=nil, in_unitAccession=nil, in_unitCvRef='nil', in_unitName=nil, in_value=nil)
		@name = in_name
		@type = in_type
		@unitAccession = in_unitAccession
		@unitCvRef = in_unitCvRef
		@unitName = in_unitName
		@value = in_value
	end
end

class Mzmlsample < MzmlParamArr
	attr_accessor :id, :name
	def initialize(in_id, in_name, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@name = in_name
	end
end

class Mzmlsoftware < MzmlParamArr
	attr_accessor :id, :version
	def initialize(in_id, in_version, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@version = in_version
	end
end

class MzmlscanSettings < MzmlParamArr
	attr_accessor :id, :sourceFileRefList, :targetList
	def initialize(in_id, in_sourceFileRefList, in_targetList, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@sourceFileRefList = in_sourceFileRefList
		@targetList = in_targetList
	end
end

class MzmlsourceFileRef
	attr_accessor :ref
	def initialize(in_ref)
		@ref = in_ref
	end
end

class Mzmltarget < MzmlParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
	end
end

class MzmlinstrumentConfigurationSettings < MzmlParamArr
	attr_accessor :id, :componentList, :softwareRef
	def initialize(in_id, in_componentList=nil, in_softwareRef=nil, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@componentList = in_componentList
		@softwareRef = in_softwareRef
	end
end

class Mzmlcomponent < MzmlParamArr
	attr_accessor :name
	def initialize(in_name, in_scanSettingsRef=nil, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@name = in_name
	end
end

class MzmldataProcessing
	attr_accessor :id, :processingMethodList
	def initialize(in_id, in_processingMethodList)
		@id = in_id
		@processingMethodList = in_processingMethodList
	end
end

class MzmlprocessingMethod < MzmlParamArr
	attr_accessor :softwareRef
	def initialize(in_softwareRef, in_scanSettingsRef=nil, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@softwareRef = in_softwareRef
	end
end

class Mzmlrun < MzmlParamArr
	attr_accessor :id, :defaultInstrumentConfigurationRef, :defaultSourceFileRef, :sampleRef, :startTimeStamp, :spectrumList, :chromatogramList
	def initialize(in_id, in_defaultInstrumentConfigurationRef, in_spectrumList, in_chromatogramList, in_defaultSourceFileRef=nil, in_sampleRef='nil', in_startTimeStamp=(Time.now.round(5).iso8601(5)), in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@defaultInstrumentConfigurationRef = in_defaultInstrumentConfigurationRef
		@defaultSourceFileRef, = in_defaultSourceFileRef
		@sampleRef = in_sampleRef
		@startTimeStamp = in_startTimeStamp
		@spectrumList = in_spectrumList
		@chromatogramList = in_chromatogramList
	end
end

class MzmlspectrumList
	attr_accessor :count, :defaultDataProcessingRef, :spectrumArr
	def initialize(in_defaultDataProcessingRef, in_spectrum=nil)
		if(in_spectrum)
			@count = in_spectrum.length
		else
			@count = 0
		end
		@defaultDataProcessingRef = in_defaultDataProcessingRef
		@spectrumArr = in_spectrum
	end
end

class Mzmlspectrum < MzmlParamArr
	attr_accessor :id, :spotID, :defaultArrayLength, :dataProcessingRef, :sourceFileRef, :scanList, :precursorList, :productList, :binaryDataArrayList
	def initialize(in_id, in_defaultArrayLength, in_scanList=nil, in_precursorList=nil, in_productList=nil, in_binaryDataArrayList=nil, in_spotID=nil, in_dataProcessingRef='nil', in_sourceFileRef='nil', in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@id = in_id
		@spotID = in_spotID
		@defaultArrayLength = in_defaultArrayLength
		@dataProcessingRef = in_dataProcessingRef
		@sourceFileRef = in_sourceFileRef
		@scanList = in_scanList
		@precursorList = in_precursorList
		@productList = in_productList
		@binaryDataArrayList = in_binaryDataArrayList
	end
end

class MzmlscanList < MzmlParamArr
	attr_accessor :count, :scanArr
	def initialize(in_scanArr, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@count = in_scanArr.length
		@scanArr = in_scanArr
	end
end

class Mzmlscan < MzmlParamArr
	attr_accessor :scanWindowListArr, :externalSpectrumID, :instrumentConfigurationRef, :sourceFileRef, :spectrumRef
	def initialize(in_scanWindowListArr=nil, in_externalSpectrumID=nil, in_instrumentConfigurationRef=nil, in_sourceFileRef='nil', in_spectrumRef=nil, in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@scanWindowListArr = in_scanWindowListArr
		@externalSpectrumID = in_externalSpectrumID
		@instrumentConfigurationRef = in_instrumentConfigurationRef
		@sourceFileRef = in_sourceFileRef
		@spectrumRef = in_spectrumRef
	end
end

class MzmlscanWindow
	attr_accessor :cvParamArr
	def initialize(in_cvParamArr)
		@cvParamArr = in_cvParamArr
	end
end

class Mzmlprecursor
	attr_accessor :activation, :isolationWindow, :selectedIonList, :externalSpectrumID, :sourceFileRef, :spectrumRef
	def initialize(in_activation, in_isolationWindow=nil, in_selectedIonList=nil, in_externalSpectrumID=nil, in_sourceFileRef='nil', in_spectrumRef=nil)
		@activation = in_activation
		@isolationWindow = in_isolationWindow	# up to one
		@selectedIonList = in_selectedIonList
		@externalSpectrumID = in_externalSpectrumID
		@sourceFileRef = in_sourceFileRef
		@spectrumRef = in_spectrumRef
	end
end

class MzmlisolationWindow < MzmlParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
	end
end

class MzmlselectedIon < MzmlParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
	end
end

class Mzmlactivation < MzmlParamArr
	def initialize(in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
	end
end

class Mzmlproduct
	attr_accessor :isolationWindowArr
	def initialize(in_isolationWindowArr=nil)
		@isolationWindowArr = in_isolationWindowArr
	end
end

class MzmlbinaryDataArray < MzmlParamArr
	attr_accessor :encodedLength, :binary, :arrayLength, :dataProcessingRef
	def initialize(in_encodedLength, in_binary, in_arrayLength, in_dataProcessingRef='nil', in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@encodedLength = in_encodedLength
		@binary = in_binary
		@arrayLength = in_arrayLength
		@dataProcessingRef = in_dataProcessingRef
	end
end

class MzmlchromatogramList
	attr_accessor :defaultDataProcessingRef, :chromatogramArr, :count
	def initialize(in_defaultDataProcessingRef, in_chromatogramArr)
		@defaultDataProcessingRef = in_defaultDataProcessingRef
		@chromatogramArr = in_chromatogramArr
		if(@chromatogramArr)
			@count = in_chromatogramArr.length
		else
			@count = 0
		end
	end
end

class Mzmlchromatogram < MzmlParamArr
	attr_accessor :defaultArrayLength, :id, :binaryDataArrayList, :dataProcessingRef, :precursor, :product
	def initialize(in_defaultArrayLength, in_id, in_binaryDataArrayList, in_precursor=nil, in_product=nil, in_dataProcessingRef='nil', in_referenceableParamGroupRefArr=nil, in_cvParamArr=nil, in_userParamArr=nil)
		super(in_referenceableParamGroupRefArr, in_cvParamArr, in_userParamArr)
		@defaultArrayLength = in_defaultArrayLength
		@id = in_id
		@binaryDataArrayList = in_binaryDataArrayList
		@dataProcessingRef = in_dataProcessingRef
		@precursor = in_precursor
		@product = in_product
	end
end

=begin
This class was actually inspired by James' suggestion.
The contructor parameter 'in_xml' is the parse tree we are building with nokogiri
This is the class I use to print out all of the annoying stuff from MzmlParamArr
=end
class MzmlParamArrPrinter
	attr_accessor :xml
	def initialize(in_xml)
		@xml = in_xml
	end
	def print(in_obj)
		refGroupArr = in_obj.referenceableParamGroupRefArr
		if(refGroupArr)
			refGroupArr.each do |curRef|
				printref(curRef)
			end
		end
		cvArr = in_obj.cvParamArr
		if(cvArr)
			cvArr.each do |curcv|
				# Prince thing?
				printcv(curcv)
			end
		end
		userArr = in_obj.userParamArr
		if(userArr)
			userArr.each do |curUser|
				# Prince thing?
				printuser(curUser)
			end
		end
	end
	def printref(curRef)
		@xml.referenceableParamGroupRef(:ref=>curRef.ref)
	end
	def printcv(curcv)
		@xml.cvParam(:accession=>curcv.accession, :cvRef=>curcv.cvRef, :name=>curcv.name, :unitCvRef=>curcv.unitCvRef, :unitName=>curcv.unitName, :value=>curcv.value)
	end
	def printuser(curUser)
		@xml.userParam(:name=>curUser.name, :type=>curUser.type, :unitAccession=>curUser.unitAccession, :unitCvRef=>curUser.unitCvRef, :unitName=>curUser.unitName, :value=>curUser.value)
	end
end

end
