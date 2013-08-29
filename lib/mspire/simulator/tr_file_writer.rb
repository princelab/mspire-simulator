require 'mspire/utilities/progress'

module Mspire
  module Simulator
    class Txml_file_writer
      def self.write(db,file_name,opts)
        prog = Mspire::Utilities::Progress.new("Writing xml:")
        file = File.open("#{file_name}_truth.xml","w")
        peps = db.execute "SELECT * FROM peptides"

        file.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        file.puts "<simulated_peptides>"
        file.puts "<simulator_options>\n"
        opts.each do |k,v|
          file.puts "\t#{k}=#{v},"
        end
        file.puts "</simulator_options>\n"
        total = peps.size.to_f

        num = 0
        step = total/100.0

        peps.each do |pep|
          k = pep[0]
          if k > step * (num + 1)
            num = (((k/total)*100).to_i)
            prog.update(num)
          end
          sequence = pep[1]
          charge = pep[3]
          cents = db.execute "SELECT * FROM spectra WHERE pep_id=#{k}"

          file.puts "\t<simulated_peptide sequence=\"#{sequence}\" charge=\"#{charge.round}\">"
          tags = ""
          tags<<"\t\t<centroids>\n"
          centroids = ""
          cents.each do |cent|
            centroids<<"\t\t\tcent_id=#{cent[0]},pep_id=#{cent[1]},rt=#{cent[2]},mz=#{cent[3]},int=#{cent[4]},merge_id=#{cent[5]}\n"
          end
          tags<<centroids
          tags<<"\t\t</centroids>\n"
          file<<tags
          file.puts "\t</simulated_peptide>"
        end
        file.puts "</simulated_peptides>"
        file.close
        prog.finish!
      end
    end

    class Tcsv_file_writer
      def self.write(db,file_name,opts)
        prog = Mspire::Utilities::Progress.new("Writing csv:")
        spectra = db.execute "SELECT * FROM spectra AS S JOIN peptides AS P ON S.pep_id=P.Id"
        total = spectra.size

        #write
        file = File.open("#{file_name}_truth.csv","w")
        file.puts "simulator_options=#{opts.inspect}"
#        file.puts "rt,mz,int,centroid_id,merge_id,peptide_id,protien_id,seq,charge,abu,isotope_id"
        file.puts "centroid_id,mz,rt,int,protein_id,peptide_id,isotope_id,seq,charge,abu,merge_id,"

        count = 0

        num = 0
        step = total/100
        spectra.each do |cent|
          file.puts "#{cent[0]},#{cent[3]},#{cent[2]},#{cent[4]},#{cent[19]},#{cent[1]},#{cent[6]},#{cent[8]},#{cent[10]},#{cent[15]},#{cent[5]}"
#old          file.puts "#{cent[2]},#{cent[3]},#{cent[4]},#{cent[0]},#{cent[5]},#{cent[1]},#{cent[18]},#{cent[7]},#{cent[9]},#{cent[14]}"
        end
        file.close
        prog.finish!
      end
    end
  end
end
