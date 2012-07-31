require 'progress'

module MS
  class Txml_file_writer
    def self.write(features,spectra,file_name)
      @spectra = spectra
      @start = Time.now
      file = File.open("#{file_name}_truth.xml","w")
      
      r_times = spectra.keys.sort
      
      file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      file.puts "<simulated_peptides>"
	total = features.size.to_f
	features.each_with_index do |fe,k|
	  sequence = fe.sequence
	  charge = fe.charge
	  mzs = fe.mzs
	  ints = fe.ints
	  rts = fe.rts
	  Progress.progress("Writing xml:",(((k/total)*100).to_i))
	  file.puts "\t<simulated_peptide sequence=\"#{sequence}\" charge=\"#{charge.round}\">"
	    mzs.each_with_index do |mzs,i|
	      tags = ""
	      centroids = ""
	      tags<<"\t\t<lc_centroids isotopic_index=\"#{i}\">"
		mzs.each_with_index do |mz,ind|
		  if ints[i][ind] > 0.9
		    index = get_ind(mz,rts[ind])
		    centroids<<"#{r_times.index(rts[ind])},#{index.inspect};"
		  end
		end
	      if centroids != ""
		tags<<centroids
		tags<<"</lc_centroids>\n"
		file<<tags
	      end
	    end
	  file.puts "\t</simulated_peptide>"
	end
      file.puts "</simulated_peptides>"
      file.close
      
      Progress.progress("Writing xml:",100,Time.now-@start)
      puts ''
    end
    
    def self.get_ind(mz,rt)
      index = nil
      mzs = @spectra[rt][0]
      ints = @spectra[rt][1]
      mzs.each_with_index do |m, i|
	if m == mz
	  index = i
	elsif m.class == Hash
	  if ind = m.values[0].index(mz)
	    index = [i,m.keys[0][ind+1]]
	  end
	end
      end
      return index
    end
  end
  
  class Tcsv_file_writer
    def self.write(spectra,noise,features,file_name)
      @start = Time.now
    
      ind_hash = {}
      features.each_with_index do |pep,i|
	pep.mzs.each_with_index do |m_ar,j|
	  m_ar.each do |mz|
	    ind_hash[mz] = "#{i + 1}.#{j + 1}".to_f
	  end
	end
      end
    
      file = File.open("#{file_name}_truth.csv","w")
      file.puts "rt,mz,int,index"
      count = 1
      time_i = 0.0
      data = []
      total = spectra.length
      spectra.each do |k,v|
	Progress.progress("Writing csv(process 1 of 2):",(((time_i/total)*100).to_i))
	#puts "#{count}/#{total}"
	#count += 1
	if noise != "false"
	  n_data = noise[k]
	end
	
	if v != nil
	  v.each_slice(2) do |m,i|
	    m.each_with_index do |mz,index|
	      peak_index = ind_hash[mz]
	      #puts " #{peak_index}, #{mz}"
	      data<<[k,mz,i[index],peak_index]
	    end
	  end
	end
	
	if noise != "false"
	  n_data.each_slice(2) do |m,i|
	    m.each_with_index do |mz,index|
	      data<<[k,mz,i[index],0]
	    end
	  end
	end
	time_i += 1
      end
      
      data = data.group_by{|d| d[0]}
      
      total = data.values.size.to_f
      count = 0
      data.each_value do |val|
	Progress.progress("Writing csv(process 2 of 2):",(((count/total)*100).to_i))
	val = val.sort_by{|a| a[1]}
	val.each do |a|
	  if a[3] >= 1
	    file.puts "#{a[0]},#{a[1]},#{a[2]},#{a[3]}"
	  else
	    file.puts "#{a[0]},#{a[1]},#{a[2]},#{0}"
	  end
	end
	count += 1
      end
      file.close
      
      Progress.progress("Writing csv:",100,Time.now-@start)
      puts ''
    end
  end
end
