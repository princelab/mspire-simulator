require 'ms/peptide'

module MS
	class Mzml
		class Writer
			def to_file(peptides,rts)
				outFile = File.new("temp.txt", "w")
				outFile.write("#    scanNumber       msLevel           m/z     intensity\n")
				peptides.each do |pep,scan|
				  intsty = rand(600)
				  outFile.write("              #{pep.group}           ms1      #{pep.mz.round(4)}        #{intsty}\n")
				end
				
				outFile.close
				
				system "./bin/txt2mzml temp.txt out/simulated.mzML"
				File.delete("temp.txt")
				
				scanList = "<scanList count=\"1\">\n"
				scanList<<"<cvParam cvRef=\"MS\" accession=\"MS:1000795\" name=\"no combination\" />\n"
				scanList<<"<scan>\n"
				scanList<<"<cvParam cvRef=\"MS\" accession=\"MS:1000016\" name=\"scan start time\" value=\""
				scanList2 = "\" unitAccession=\"UO:0000010\" unitName=\"second\" unitCvRef=\"UO\" />\n"
				scanList2<<"</scan>"
				
				mzFile = File.open("out/simulated.mzML","r")
				result = ""
				nrts = Array.new(rts)
				nrts.reverse!
				while(!mzFile.eof?)
					tmp = mzFile.gets #next line in file
					count = tmp.gsub(/\D/,"").to_i #gets the count that txtmzml made <spectrumList count="4" defaultDataProcessingRef="pwiz_processing">
					tmp = tmp.gsub(/<spectrumList count="\d*">/, #find this text with \d* being a number
					"<spectrumList count=\"#{count}\" defaultDataProcessingRef=\"pwiz_processing\">") #pastes this string with the count gotten 2 lines above
					
					tmp = tmp.gsub("<scanList count=\"0\">",scanList+nrts.pop.round(2).to_s+scanList2)
					
					result<<tmp
				end
				mzFile.close
				nmzFile = File.new("out/simulated.mzML","w")
				nmzFile.write(result)
				nmzFile.close
				
			end
		end
	end
end
=begin wanted code:
<scanList count="1">
<cvParam cvRef="MS" accession="MS:1000795" name="no combination" value=""/>
<scan instrumentConfigurationRef="LCQ_x0020_Deca">
<cvParam cvRef="MS" accession="MS:1000016" name="scan start time" value="5.8905000000000003" unitCvRef="UO" unitAccession="UO:0000031" unitName="minute"/>
<cvParam cvRef="MS" accession="MS:1000512" name="filter string" value="+ c NSI Full ms [ 400.00-1800.00]"/>
<cvParam cvRef="MS" accession="MS:1000616" name="preset scan configuration" value="3"/>
<scanWindowList count="1">
<scanWindow>
<cvParam cvRef="MS" accession="MS:1000501" name="scan window lower limit" value="400" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>
<cvParam cvRef="MS" accession="MS:1000500" name="scan window upper limit" value="1800" unitCvRef="MS" unitAccession="MS:1000040" unitName="m/z"/>
=end
