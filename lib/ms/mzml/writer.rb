require 'ms/peptide'

module MS
	class Writer
		def to_file(features)
		puts "TO FILE..."
		
		outFileName = 'testMzml.mzml'
		mzmlAccession = ""
		cvListArr = []
		fileContentArr = []
		srcFileListArr = []
		contactInfo = AnoyceProject::Mzmlcontact.new()
		refParamGrpListArr = []
		sampleListArr = []
		softwareListArr = []
		scanSettingsListArr = []
		instConfigListArr = []
		dataProcListArr = []
		
		#### Test Values #####
		# populate arrays for testing
		cvListArr.push(AnoyceProject::Mzmlcv.new('1234', 'testcvlist', '0.1', 'uri'))
		cvListArr.push(AnoyceProject::Mzmlcv.new('34', 'testcvlist2', '0.11', 'uri2'))

		#fileContentArr.push(AnoyceProject::MzmlfileContent.new())

		srcFileListArr.push(AnoyceProject::MzmlsourceFile.new('5678', 'pask.fasta', 'testFastaFiles'))

		refParamGrpListArr.push(AnoyceProject::MzmlreferenceableParamGroup.new('085'))
		refParamGrpListArr.push(AnoyceProject::MzmlreferenceableParamGroup.new('135'))

		tempArr = []
		tempArr.push(AnoyceProject::MzmlreferenceableParamGroupRef.new('369'))
		tempArr2 = []
		tempArr2.push(AnoyceProject::MzmlcvParam.new('123456789','ref','blargh'))
		tempArr3 = []
		tempArr3.push(AnoyceProject::MzmluserParam.new('James'))
		sampleListArr.push(AnoyceProject::Mzmlsample.new('007', 'Bond',nil,tempArr2,tempArr3))
		sampleListArr.push(AnoyceProject::Mzmlsample.new('12242012', 'end', tempArr))

		softwareListArr.push(AnoyceProject::Mzmlsoftware.new('1.83', 'ClustalW'))
		softwareListArr.push(AnoyceProject::Mzmlsoftware.new('1.52', 'Starcraft'))

		tempSrcRef = []
		tempSrcRef.push(AnoyceProject::MzmlsourceFileRef.new('789456123'))
		tempTargets = []
		tempTargets.push(AnoyceProject::Mzmltarget.new())
		scanSettingsListArr.push(AnoyceProject::MzmlscanSettings.new('14', tempSrcRef, tempTargets))

		testCompList = []
		testCompList.push(AnoyceProject::Mzmlcomponent.new('source'))
		testCompList.push(AnoyceProject::Mzmlcomponent.new('analyzer'))
		testCompList.push(AnoyceProject::Mzmlcomponent.new('detector'))
		instConfigListArr.push(AnoyceProject::MzmlinstrumentConfigurationSettings.new('1597534682', testCompList))

		procMetList = []
		procMetList.push(AnoyceProject::MzmlprocessingMethod.new('45'))
		dataProcListArr.push(AnoyceProject::MzmldataProcessing.new('789123456', procMetList))


		specArr = []
		specScanArr = []
		specScanWindowList = []
		specPrecursorList = []
		specProductList = []
		specBinList = []
		specScanWindowList.push(AnoyceProject::MzmlscanWindow.new([AnoyceProject::MzmlcvParam.new('4682','anotherRef','moreStuff')]))
		specScanArr.push(AnoyceProject::Mzmlscan.new(specScanWindowList,'7913','ref:468','refSrc','refSpec'))
		specPrecursorList.push(AnoyceProject::Mzmlprecursor.new(AnoyceProject::Mzmlactivation.new(),AnoyceProject::MzmlisolationWindow.new(),[AnoyceProject::MzmlselectedIon.new()],'ref685'))
		specProductList.push(AnoyceProject::Mzmlproduct.new([AnoyceProject::MzmlisolationWindow.new()]))
		arr = [103.45,209.5,708.5677,45,36.345,56,56,345,324,5643,24]
		bi = Base64.strict_encode64(arr.to_s)
		specBinList.push(AnoyceProject::MzmlbinaryDataArray.new('789',bi))
		specArr.push(AnoyceProject::Mzmlspectrum.new('id','length',AnoyceProject::MzmlscanList.new(specScanArr),specPrecursorList,specProductList,specBinList))
		specArr.push(AnoyceProject::Mzmlspectrum.new('id','length',AnoyceProject::MzmlscanList.new(specScanArr),specPrecursorList,specProductList,specBinList))

		chromArr = []
		chromBinList = []
		arr = [1.2,1.3,1.4,1.5,109887.4556]
		bi = Base64.strict_encode64(arr.to_s)
		chromBinList.push(AnoyceProject::MzmlbinaryDataArray.new('asdf',bi))
		chromArr.push(AnoyceProject::Mzmlchromatogram.new('100','x493',chromBinList))
		chromArr.push(AnoyceProject::Mzmlchromatogram.new('100','x493',chromBinList))

		# like the arrays above, 'run' is used in the code; don't change the name of this variable!
		run = AnoyceProject::Mzmlrun.new(5,10,AnoyceProject::MzmlspectrumList.new('1950',specArr),AnoyceProject::MzmlchromatogramList.new('refProc',chromArr),nil,nil,nil,nil,nil,nil)

		##### end test values #####

		end
	end
end

