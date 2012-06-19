
module MS
  class Sim_Digester
  
    attr_reader :digested_file
    attr_writer :digested_file
    
    def initialize(digestor,pH)
      @digestor = digestor
      @pH = pH
      @digested_file = ".#{Time.now.nsec.to_s}"
    end
    
    def create_digested_file(file)
      inFile = File.open(file,"r")
      seq = ""
      inFile.each_line do |sequence| 
        if sequence =~ />/ or sequence == "\n"
          seq = seq<<";"
        else
          seq = seq<<sequence.chomp
        end
      end
      inFile.close
      
      proteins = seq.split(/;/).delete_if{|str| str == ""}

      trypsin = Mspire::Digester[@digestor]
      
      digested = []
      d_file = File.open(@digested_file, "w")
      proteins.each do |prot|
        dig = trypsin.digest(prot)
        dig.each do |d|
          digested<<d
        end
      end
      proteins.clear
      digested.uniq!
      
      trun_digested = []
      if digested.length > 100000
        100000.times do 
          trun_digested<<digested[rand(digested.length)]
        end
        digested.clear
        digested = trun_digested
      end
      
      digested.each do |dig|
        d_file.puts(dig)
      end
      d_file.close
      num_digested = digested.size
      digested.clear
      return num_digested
    end
    
    def digest(file)
      start = Time.now
      
      num_digested = create_digested_file(file)
      
      d_file = File.open(@digested_file, "r")
      i = 0
      
      peptides = []

      d_file.each_line do |peptide_seq|
        peptide_seq.chomp!
        Progress.progress("Creating peptides '#{file}':",((i/num_digested.to_f)*100.0).to_i)
        
        charge_ratio = charge_at_pH(identify_potential_charges(peptide_seq), @pH)
        charge_f = charge_ratio.floor
        charge_c = charge_ratio.ceil
        
        peptide_f = MS::Peptide.new(peptide_seq, charge_f) if charge_f != 0
        peptide_c = MS::Peptide.new(peptide_seq, charge_c) if charge_c != 0
      
        peptides<<peptide_f if charge_f != 0
        peptides<<peptide_c if charge_c != 0
        i += 1
      end
      d_file.close
      File.delete(@digested_file)
      Progress.progress("Creating peptides '#{file}':",100,Time.now-start)
      puts ''
      return peptides
    end
  end
end
