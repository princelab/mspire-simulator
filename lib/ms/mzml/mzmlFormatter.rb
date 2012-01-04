#!/usr/bin/env ruby

require "base64"
require 'nokogiri'
require 'AnoyceProject'

=begin
The AnoyceProject file needs to become a gem or otherwise be packaged to make the above code less likely to die
=end

# each of these arrays/variables are used in the code below.  Don't change their names!
outFileName = 'testMzml.mzml'
mzmlAccession = "Accession"
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
#run = AnoyceProject::Mzmlrun.new(5,10,[],[],nil,nil,nil,nil,nil,nil)

=begin
Note that all of the above values are the pieces of information that need to be passed in.
Conveniently, we can change the name of the output file by switching out 'outFileName.'
=end

#### Test Values #####
# populate arrays for testing
cvListArr.push(AnoyceProject::Mzmlcv.new('cv1', 'testcvlist1', '0.1', 'uri'))
cvListArr.push(AnoyceProject::Mzmlcv.new('cv2', 'testcvlist2', '0.11', 'uri2'))

#fileContentArr.push(AnoyceProject::MzmlfileContent.new())

srcFileListArr.push(AnoyceProject::MzmlsourceFile.new('name1', 'name1', 'location1'))
srcFileListArr.push(AnoyceProject::MzmlsourceFile.new('name2', 'name2', 'location2'))

refParamGrpListArr.push(AnoyceProject::MzmlreferenceableParamGroup.new('group1'))
refParamGrpListArr.push(AnoyceProject::MzmlreferenceableParamGroup.new('group2'))

tempArr = []
tempArr.push(AnoyceProject::MzmlreferenceableParamGroupRef.new('group1'))
tempArr2 = []
tempArr2.push(AnoyceProject::MzmlcvParam.new('cv3','ref','blargh'))
tempArr3 = []
tempArr3.push(AnoyceProject::MzmluserParam.new('James'))
sampleListArr.push(AnoyceProject::Mzmlsample.new('sample1', 'Bond',nil,tempArr2,tempArr3))
sampleListArr.push(AnoyceProject::Mzmlsample.new('sample2', 'end', tempArr))

softwareListArr.push(AnoyceProject::Mzmlsoftware.new('v1.83', 'ClustalW'))
softwareListArr.push(AnoyceProject::Mzmlsoftware.new('v1.52', 'Starcraft'))

tempSrcRef = []
tempSrcRef.push(AnoyceProject::MzmlsourceFileRef.new('sourceFile'))
tempTargets = []
tempTargets.push(AnoyceProject::Mzmltarget.new())
scanSettingsListArr.push(AnoyceProject::MzmlscanSettings.new('scan1', tempSrcRef, tempTargets))

testCompList = []
testCompList.push(AnoyceProject::Mzmlcomponent.new('source'))
testCompList.push(AnoyceProject::Mzmlcomponent.new('analyzer'))
testCompList.push(AnoyceProject::Mzmlcomponent.new('detector'))
instConfigListArr.push(AnoyceProject::MzmlinstrumentConfigurationSettings.new('LCQDeca', testCompList))

procMetList = []
procMetList.push(AnoyceProject::MzmlprocessingMethod.new('proc'))
dataProcListArr.push(AnoyceProject::MzmldataProcessing.new('data1', procMetList))


specArr = []
specScanArr = []
specScanWindowList = []
specPrecursorList = []
specProductList = []
specBinList = []
specScanWindowList.push(AnoyceProject::MzmlscanWindow.new([AnoyceProject::MzmlcvParam.new('cv4','anotherRef','moreStuff')]))
specScanArr.push(AnoyceProject::Mzmlscan.new(specScanWindowList,'scanwin','LCQDeca','refSrc','refSpec'))
specPrecursorList.push(AnoyceProject::Mzmlprecursor.new(AnoyceProject::Mzmlactivation.new(),AnoyceProject::MzmlisolationWindow.new(),[AnoyceProject::MzmlselectedIon.new()],'ref685'))
specProductList.push(AnoyceProject::Mzmlproduct.new([AnoyceProject::MzmlisolationWindow.new()]))
arr = [103.45,209.5,708.5677,45,36.345,56,56,345,324,5643,24]
bi = Base64.strict_encode64(arr.to_s)
specBinList.push(AnoyceProject::MzmlbinaryDataArray.new(bi.length,bi,arr.length))
specBinList.push(AnoyceProject::MzmlbinaryDataArray.new(bi.length,bi,arr.length))
specArr.push(AnoyceProject::Mzmlspectrum.new('scan=1','1',AnoyceProject::MzmlscanList.new(specScanArr),specPrecursorList,specProductList,specBinList))
specArr.push(AnoyceProject::Mzmlspectrum.new('scan=2','1',AnoyceProject::MzmlscanList.new(specScanArr),specPrecursorList,specProductList,specBinList))

chromArr = []
chromBinList = []
arr = [1.2,1.3,1.4,1.5,109887.4556]
bi = Base64.strict_encode64(arr.to_s)
chromBinList.push(AnoyceProject::MzmlbinaryDataArray.new(bi.length,bi,arr.length))
chromBinList.push(AnoyceProject::MzmlbinaryDataArray.new(bi.length,bi,arr.length))
chromArr.push(AnoyceProject::Mzmlchromatogram.new('10','chrom1',chromBinList))
chromArr.push(AnoyceProject::Mzmlchromatogram.new('10','chrom2',chromBinList))

# like the arrays above, 'run' is used in the code; don't change the name of this variable!
run = AnoyceProject::Mzmlrun.new('run1','LCQDeca',AnoyceProject::MzmlspectrumList.new('spec3',specArr),AnoyceProject::MzmlchromatogramList.new('refProc',chromArr))

##### end test values #####


builder = Nokogiri::XML::Builder.new do |xml|
	paramPrinter = AnoyceProject::MzmlParamArrPrinter.new(xml)
	xml.mzML(:xmlns=>"http://psi.hupo.org/ms/mzml", :accession=>mzmlAccession, :version=>"1.1.0", :id=>"default_config") {
		xml.cvList(:count=>cvListArr.length) {
			cvListArr.each do |curCv|
				xml.cv(:id=>curCv.id, :fullName=>curCv.name, :version=>curCv.version, :URI=>curCv.uri)
			end
		}
		
		
		
		xml.fileDescription {
			xml.fileContent {
				fileContentArrLength = fileContentArr.length
				if(fileContentArrLength > 0)
					fileContentArr.each do |curFile|
						paramPrinter.print(curFile)
					end
				end
			}
			srcFileListArrLength = srcFileListArr.length
			if(srcFileListArrLength > 0)
				xml.sourceFileList(:count=>srcFileListArrLength) {
					srcFileListArr.each do |curFile|
						xml.sourceFile(:id=>curFile.id, :name=>curFile.name, :location=>curFile.location) {
							paramPrinter.print(curFile)
						}
					end
				}
			end
			xml.contact {
				paramPrinter.print(contactInfo)
			}
		}
		
		
		
		referenceableParamGroupListLength = refParamGrpListArr.length
		if(referenceableParamGroupListLength > 0) 
			xml.referenceableParamGroupList(:count=>referenceableParamGroupListLength) {
				refParamGrpListArr.each do |curRef|
					xml.referenceableParamGroup(:id=>curRef.id) {
						curRefcvParamArr = curRef.cvParamArr
						if(curRefcvParamArr != nil)
							if(curRefcvParamArr.length > 0)
								curRefcvParamArr.each do |curcv|
									paramPrinter.printcv(curcv)
								end
							end
						end
						curRefUserParamArr = curRef.userParamArr
						if(curRefUserParamArr != nil)
							if(curRefUserParamArr.length > 0)
								curRefUserParamArr.each do |curUser|
									paramPrinter.printuser(curUser)
								end
							end
						end
					}
				end
			}
		end
		
		
		
		sampleListArrLength = sampleListArr.length
		if(sampleListArrLength > 0)
			xml.sampleList(:count=>sampleListArrLength) {
				sampleListArr.each do |curSample|
					xml.sample(:id=>curSample.id, :name=>curSample.name) {
						paramPrinter.print(curSample)
					}
				end
			}
		end
		
		
		
		softwareListArrLength = softwareListArr.length
		xml.softwareList(:count=>softwareListArrLength) {
			softwareListArr.each do |curSoft|
				xml.software(:id=>curSoft.id, :version=>curSoft.version) {
					paramPrinter.print(curSoft)
				}
			end
		}
		
		
		
		scanSettingsListArrLength = scanSettingsListArr.length
		if(scanSettingsListArrLength > 0)
			xml.scanSettingsList(:count=>scanSettingsListArrLength) {
				scanSettingsListArr.each do |curScanSet|
					xml.scanSettings(:id=>curScanSet.id) {
						curSrcFileRefListArr = curScanSet.sourceFileRefList
						xml.sourceFileRefList(:count=>curSrcFileRefListArr.length) {
							curSrcFileRefListArr.each do |curRef|
								xml.sourceFileRef(:ref=>curRef.ref)
							end
						}
						curTargetListArr = curScanSet.targetList
						xml.targetList(:count=>curTargetListArr.length) {
							curTargetListArr.each do |curTarget|
								xml.target {
									paramPrinter.print(curTarget)
								}
							end
						}
						paramPrinter.print(curScanSet)
					}
				end
			}
		end
		
		
		
		instConfigListArrLength = instConfigListArr.length
		if(instConfigListArrLength > 0)
			xml.instrumentConfigurationList(:count=>instConfigListArrLength) {
				instConfigListArr.each do |curConfig|
					xml.instrumentConfiguration(:id=>curConfig.id) {
						paramPrinter.print(curConfig)
						curCompListArr = curConfig.componentList
						if(curConfig.componentList)
							xml.componentList(:count=>curCompListArr.length) {
								curCount = 1
								curCompListArr.each do |curComp|
									case curComp.name
									when "source"
										xml.source(:order=>curCount) {
											paramPrinter.print(curComp)
										}
									when "analyzer"
										xml.analyzer(:order=>curCount) {
											paramPrinter.print(curComp)
										}
									when "detector"
										xml.detector(:order=>curCount) {
											paramPrinter.print(curComp)
										}
									else
										# bad news: throw error?
									end
									curCount += 1
								end
							}
						end
						if(curConfig.softwareRef)
							xml.softwareRef(:ref=>curConfig.softwareRef) {}
						end
					}
				end
			}
		end
		
		
		
		dataProcListArrLength = dataProcListArr.length
		if(dataProcListArrLength > 0)
			xml.dataProcessingList(:count=>dataProcListArrLength) {
				dataProcListArr.each do |curProc|
					xml.dataProcessing(:id=>curProc.id) {
						curCount = 1
						ProcMethodListArr = curProc.processingMethodList
						ProcMethodListArr.each do |curMethod|
							xml.processingMethod(:order=>curCount, :softwareRef=>curMethod.softwareRef) {
								paramPrinter.print(curMethod)
							}
							curCount += 1
						end
					}
				end
			}
		end
		
=begin
I didn't have too much trouble debugging up top, but then I started playing with all of the information in run.
I decided that it would be much easier to know what was coming by printing out the class that the program got and then labeling the printing command with the class I was expecting
=end		
		
		xml.run(:id=>run.id, :defaultInstrumentConfigurationRef=>run.defaultInstrumentConfigurationRef, :sampleRef=>run.sampleRef, :startTimeStamp=>run.startTimeStamp) {
			
			specListArr = run.spectrumList
			#puts specListArr.class #MzmlspectrumList
			if(specListArr.count > 0)			
				xml.spectrumList(:count=>specListArr.count, :defaultDataProcessingRef=>specListArr.defaultDataProcessingRef) {
					specArr = specListArr.spectrumArr
					if(specArr && specArr.length > 0)
						specIndex = 0
						specArr.each do |curSpec|
							#puts curSpec.class	#Mzmlspectrum
							xml.spectrum(:id=>curSpec.id, :spotID=>curSpec.spotID, :index=>specIndex, :defaultArrayLength=>curSpec.defaultArrayLength, :dataProcessingRef=>curSpec.dataProcessingRef, :sourceFileRef=>curSpec.sourceFileRef) {
								scanListArr = curSpec.scanList
								#puts scanListArr.class #MzmlscanList
								xml.scanList(:count=>scanListArr.count) {
									thisScanArr = scanListArr.scanArr
									thisScanArr.each do |curScan|
										#puts curScan.class	#Mzmlscan
										xml.scan(:spectrumRef=>curScan.spectrumRef, :sourceFileRef=>curScan.sourceFileRef, :externalSpectrumID=>curScan.externalSpectrumID, :instrumentConfigurationRef=>curScan.instrumentConfigurationRef) {
											curScanWindowListArr = curScan.scanWindowListArr
											#puts curScanWindowListArr.class	#Array
											curScanWindowListArrLength = curScanWindowListArr.length
											if(curScanWindowListArrLength > 0)
												xml.scanWindowList(:count=>curScanWindowListArrLength) {
													curScanWindowListArr.each do |curScanWindow|
														#puts curScanWindow.class	#MzmlscanWindow
														if(curScanWindow)
															xml.scanWindow{
																curScanWindow.cvParamArr.each do |curCVParam|				
																	#puts curCVParam.class #MzmlcvParam
																	paramPrinter.printcv(curCVParam)
																end
															}
														end
													end
												}
											end
										}
									end
								}
								
								curPrecursorListArr = curSpec.precursorList
								curPrecursorListArrLength = curPrecursorListArr.length
								if(curPrecursorListArrLength > 0)
									xml.precursorList(:count=>curPrecursorListArrLength) {
										curPrecursorListArr.each do |curPrecursor|
											#puts curPrecursor.class	#Mzmlprecursor
											xml.precursor(:spectrumRef=>curPrecursor.spectrumRef, :sourceFileRef=>curPrecursor.sourceFileRef, :externalSpectrumID=>curPrecursor.externalSpectrumID) {
												curIsoWin = curPrecursor.isolationWindow
												if(curIsoWin)
													xml.isolationWindow {
														paramPrinter.print(curIsoWin)
													}
												end
												selIonListArr = curPrecursor.selectedIonList
												xml.selectedIonList(:count=>selIonListArr.length) {
													selIonListArr.each do |curSelIon|
														xml.selectedIon {
															paramPrinter.print(curSelIon)
														}
													end
												}
												xml.activation {
													paramPrinter.print(curPrecursor.activation)
												}
											}
										end
									}
								end
								
								prodListArr = curSpec.productList
								#puts prodListArr.class	#Array
								prodListArrLength = prodListArr.length
								if(prodListArrLength > 0)
									xml.productList(:count=>prodListArrLength) {
										prodListArr.each do |curProd|
											#puts curProd.class	#Mzmlproduct
											xml.product {
												curProd.isolationWindowArr.each do |curWin|
													xml.isolationWindow {
														paramPrinter.print(curWin)
													}
												end
											}
										end
									}
								end
								
								binDatArrListArr = curSpec.binaryDataArrayList
								#puts binDatArrListArr.class	#Array
								binDatArrListArrLength = binDatArrListArr.length
								if(binDatArrListArrLength > 0)
									xml.binaryDataArrayList(:count=>binDatArrListArrLength) {
										binDatArrListArr.each do |curBinDataArr|
											#puts curBinDataArr.class	#MzmlbinaryDataArray
											xml.binaryDataArray(:arrayLength=>curBinDataArr.arrayLength, :dataProcessingRef=>curBinDataArr.dataProcessingRef, :encodedLength=>curBinDataArr.encodedLength) {
												paramPrinter.print(curBinDataArr)
												xml.binary curBinDataArr.binary
											}
										end
									}
								end	
								
							}
							specIndex += 1
						end
					end
				}
			end
			
			chromList = run.chromatogramList
			#puts chromList.class	#MzmlchromatogramList
			if(chromList.count > 0)
				xml.chromatogramList(:count=>chromList.count, :defaultDataProcessingRef=>chromList.defaultDataProcessingRef) {
					chromArr = chromList.chromatogramArr
					#puts chromArr.class	#Array
					chromIndex = 0
					chromArr.each do |curChrom|
						#puts curChrom.class	#Mzmlchromatogram
						xml.chromatogram(:id=>curChrom.id, :index=>chromIndex, :defaultArrayLength=>curChrom.defaultArrayLength, :dataProcessingRef=>curChrom.dataProcessingRef) {
							binDatArrListArr = curChrom.binaryDataArrayList
							xml.binaryDataArrayList(:count=>binDatArrListArr.length) {
								binDatArrListArr.each do |curBinDatArr|
									#puts curBinDataArr.class	#MzmlbinaryDataArray
									xml.binaryDataArray(:arrayLength=>curBinDatArr.arrayLength, :dataProcessingRef=>curBinDatArr.dataProcessingRef, :encodedLength=>curBinDatArr.encodedLength) {
										paramPrinter.print(curBinDatArr)
										xml.binary curBinDatArr.binary
									}
								end
							}
						}
						chromIndex += 1
					end
				}
			end
		}
	}
	#xml.indexList
	#xml.indexListOffset
	#xml.fileChecksum
	# I think that these last three are extra options (they weren't in the schema)
end

puts builder.to_xml
# The line above simply prints out the mzML file to the terminal.
File.open(outFileName, 'w') do |output|
	output.write(builder.to_xml)
end
