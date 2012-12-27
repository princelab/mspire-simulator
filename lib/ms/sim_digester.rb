
require 'obo/ontology'

class String
  attr_reader :abu, :prot_id
  attr_writer :abu, :prot_id
end

module MS
  class Sim_Digester

    def initialize(opts,db)
      @db = db
      @db.execute "CREATE TABLE IF NOT EXISTS digested(prot_id INTEGER PRIMARY KEY,header TEXT, abu REAL, sequence TEXT, peptides TEXT)"
      @digestor = opts[:digestor]
      @pH = opts[:pH]
      @missed_cleavages = opts[:missed_cleavages]
      @modifications = Modifications.new(opts[:modifications]).modifications
      @digested = nil
    end

    def create_digested(file)
      abundances = []
      headers = []
      inFile = File.open(file,"r")
      seq = ""
      inFile.each_line do |sequence| 
        if sequence =~ />/
          headers<<sequence
          num = sequence.match(/\#.+/).to_s.chomp.gsub('#','')
          if num != ""
            abundances<<(num.to_f)*10.0**-2
          else
            abundances<<1.0
          end
        sequence
        seq = seq<<";"
        elsif sequence == "/n"; else
          seq = seq<<sequence.chomp.upcase
        end
      end
      inFile.close

      proteins = seq.split(/;/).delete_if{|str| str == ""}

      trypsin = Mspire::Digester[@digestor]

      @digested = []
      proteins.each_with_index do |prot,index|
        dig = trypsin.digest(prot,@missed_cleavages) # two missed cleavages for fig 6
        @db.execute "INSERT INTO digested(header,abu,sequence,peptides) VALUES(\"#{headers[index]}\",#{abundances[index]},\"#{prot}\",'#{dig}')"
        dig.each do |d|
          d.abu = abundances[index]
          d.prot_id = index
          @digested<<d
        end
      end
      proteins.clear
      dige = @digested.uniq!
      
      num_digested = @digested.size
      puts "Number of peptides: #{num_digested}"
    end

    def digest(file)
      prog = Progress.new("Creating peptides '#{file}':")
      create_digested(file)

      i = 0
      count = 0
      num = 0
      total = @digested.size
      step = total/100.0
      @digested.each do |peptide_seq|
          if count > step * (num + 1)
            num = ((count/total.to_f)*100.0).to_i
            prog.update(num)
          end

        charge_ratio = charge_at_pH(identify_potential_charges(peptide_seq), @pH)
        charge_f = charge_ratio.floor
        charge_c = charge_ratio.ceil
        peptide_f = MS::Peptide.new(peptide_seq, charge_f, peptide_seq.abu,@db,i,peptide_seq.prot_id,@modifications) if charge_f != 0
        i += 1 if charge_f != 0
        peptide_c = MS::Peptide.new(peptide_seq, charge_c, peptide_seq.abu,@db,i,peptide_seq.prot_id,@modifications) if charge_c != 0
        i += 1 if charge_c != 0

        count += 1
      end
      prog.finish!
    end
  end
end
