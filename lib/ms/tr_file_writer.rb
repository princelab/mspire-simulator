require 'progress'

#if m/z value is in "[m/z, percentage contributed to peak]" it's a
#merged peak. 
module MS
  class Txml_file_writer
    def self.write(features,spectra,file_name)
      @spectra = spectra
      file = File.open("#{file_name}_truth.xml","w")

      r_times = spectra.keys.sort

      file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
      file.puts "<simulated_peptides>"
      total = features.size.to_f
      prog = Progress.new("Writing xml:")
      num = 0
      step = total/100.0
      features.each_with_index do |fe,k|
        sequence = fe.sequence
        charge = fe.charge
        mzs = fe.mzs
        ints = fe.ints
        rts = fe.rts
        if k > step * (num + 1)
          num = (((k/total)*100).to_i)
          prog.update(num)
        end
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

      prog.finish!
    end

    def self.get_ind(mz,rt)
      index = nil
      if @spectra[rt] != nil
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
      end
      return index
    end
  end

  class Tcsv_file_writer
    def self.write(full_spectra,spectra,noise,features,file_name)
      @spectra = full_spectra

      #create indices for real peaks
      ind_hash = create_indicies(features)

      #create data structure with indices
      data = data_with_indicies(full_spectra,spectra,noise,ind_hash)

      #group by retention time
      data = data.group_by{|d| d[0]}

      #write
      file = File.open("#{file_name}_truth.csv","w")
      file.puts "rt,mz,int,index"
      total = data.size.to_f
      count = 0
      prog = Progress.new("Writing csv(process 2 of 2):")
      num = 0
      step = total/100
      data.each_value do |val|
        if count > step * (num + 1)
          num = (((count/total)*100).to_i)
          prog.update(num)
        end
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
      prog.finish!
    end

    def self.get_merged_mz(mz,rt)
      m_mz = nil
      int = nil
      mzs = @spectra[rt][0]
      ints = @spectra[rt][1]
      mzs.each_with_index do |m, i|
        if m == mz
          m_mz = mz
          int = ints[i]
        elsif m.class == Hash
          if ind = m.values[0].index(mz)
            m_mz = [m.keys[0][0],m.keys[0][ind+1]]
            int = ints[i].flatten.inject(:+)
          end
        end
      end
      return m_mz,int
    end

    def self.create_indicies(features)
      ind_hash = {}
      features.each_with_index do |pep,i|
        pep.mzs.each_with_index do |m_ar,j|
          m_ar.each do |mz|
            ind_hash[mz] = "#{i + 1}.#{j + 1}".to_f
          end
        end
      end
      return ind_hash
    end

    def self.data_with_indicies(full_spectra,spectra,noise,ind_hash)
      count = 1
      time_i = 0.0
      data = []
      total = spectra.length
      prog = Progress.new("Writing csv(process 1 of 2):")
      num = 0
      step = total/100
      spectra.each do |k,v|
        if time_i > step * (num + 1)
          num = (((time_i/total)*100).to_i)
          prog.update(num)
        end

        merged_d = full_spectra[k]
        merged_mzs = merged_d[0]
        merged_ints = merged_d[1]

        if noise != "false"
          n_data = noise[k]
        end

        if v != nil
          v.each_slice(2) do |m,i|
            m.each_with_index do |mz,index|
              peak_index = ind_hash[mz]
              mz,int = get_merged_mz(mz,k)
              data<<[k,mz.inspect,int,peak_index]
            end
          end
        end

        if noise != "false"
          n_data.each_slice(2) do |m,i|
            m.each_with_index do |mz,index|
              mz,int = get_merged_mz(mz,k)
              data<<[k,mz.inspect,int,0]
            end
          end
        end
        time_i += 1
      end
      return data
    end
  end
end
