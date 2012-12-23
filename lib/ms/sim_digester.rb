
class String
  abu = 0
  attr_reader :abu
  attr_writer :abu
end

module MS
  class Sim_Digester

    attr_reader :digested_file
    attr_writer :digested_file

    def initialize(digestor,pH,missed_cleavages,db)
      @db = db
      @digestor = digestor
      @pH = pH
      @missed_cleavages = missed_cleavages
      @digested_file = ".#{Time.now.nsec.to_s}"
    end

    def create_digested_file(file)
      abundances = []
      inFile = File.open(file,"r")
      seq = ""
      inFile.each_line do |sequence| 
        if sequence =~ />/
          num = sequence.match(/\#.+/).to_s.chomp.gsub('#','')
          if num != ""
            abundances<<(num.to_f)*10.0**-2
          else
            abundances<<1.0
          end
        sequence
        seq = seq<<";"
        elsif sequence == "/n"; else
          seq = seq<<sequence.chomp
        end
      end
      inFile.close

      proteins = seq.split(/;/).delete_if{|str| str == ""}

      trypsin = Mspire::Digester[@digestor]

      digested = []
      d_file = File.open(@digested_file, "w")
      proteins.each_with_index do |prot,index|
        dig = trypsin.digest(prot,@missed_cleavages) # two missed cleavages for fig 6
        dig.each do |d|
          d.abu = abundances[index]
          digested<<d
        end
      end
      proteins.clear
      digested.uniq!

      trun_digested = []
      if digested.length > 50000
        50000.times do 
          trun_digested<<digested[rand(digested.length)]
        end
        digested.clear
        digested = trun_digested
      end

      digested.each do |dig|
        d_file.puts(dig<<"#"<<dig.abu.to_s)
      end
      d_file.close
      num_digested = digested.size
      digested.clear
      puts "Number of peptides: #{num_digested}"
      return num_digested
    end

    def digest(file)
      num_digested = create_digested_file(file)

      d_file = File.open(@digested_file, "r")
      i = 0
      count = 0

      peptides = []

      prog = Progress.new("Creating peptides '#{file}':")
      num = 0
      total = num_digested
      step = total/100.0
      d_file.each_line do |peptide_seq|
        peptide_seq.chomp!
        peptide_seq.abu = peptide_seq.match(/#.+/).to_s.chomp.gsub('#','').to_f
          peptide_seq.gsub!(/#.+/,'')
          if count > step * (num + 1)
            num = ((count/total.to_f)*100.0).to_i
            prog.update(num)
          end

        charge_ratio = charge_at_pH(identify_potential_charges(peptide_seq), @pH)
        charge_f = charge_ratio.floor
        charge_c = charge_ratio.ceil
        peptide_f = MS::Peptide.new(peptide_seq, charge_f, peptide_seq.abu,@db,i) if charge_f != 0
        i += 1 if charge_f != 0
        peptide_c = MS::Peptide.new(peptide_seq, charge_c, peptide_seq.abu,@db,i) if charge_c != 0
        i += 1 if charge_c != 0

        peptides<<peptide_f if charge_f != 0
        peptides<<peptide_c if charge_c != 0
        count += 1
      end
      prog.finish!
      d_file.close
      File.delete(@digested_file)
      return peptides
    end
  end
end
