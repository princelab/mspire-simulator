class String
  abu = 0
  attr_reader :abu
  attr_writer :abu
end

module MS
  class Sim_Digester

    attr_reader :digested_file
    attr_writer :digested_file

    def initialize(digestor,pH)
      @digestor = digestor
      @pH = pH
      @digested_file = ".#{Time.now.nsec.to_s}"
      system("mkdir .m .i")
      system("mkdir .m/A .m/R .m/N .m/D .m/C .m/E .m/Q .m/G .m/H .m/I .m/L .m/K .m/M .m/F .m/P .m/S .m/T .m/W .m/Y .m/V .m/U .m/O")
      system("mkdir .i/A .i/R .i/N .i/D .i/C .i/E .i/Q .i/G .i/H .i/I .i/L .i/K .i/M .i/F .i/P .i/S .i/T .i/W .i/Y .i/V .i/U .i/O")
    end

    def clean
      system("rm -r -f .m .i")
    end

    def create_digested_file(file)
      abundances = []
      inFile = File.open(file,"r")
      seq = ""
      inFile.each_line do |sequence| 
        if sequence =~ />/ or sequence == "\n"
          abundances<<sequence.match(/\#.+/).to_s.chomp.gsub('#','').to_f
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
      proteins.each_with_index do |prot,index|
        dig = trypsin.digest(prot)
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
      start = Time.now

      num_digested = create_digested_file(file)

      d_file = File.open(@digested_file, "r")
      i = 0

      peptides = []

      d_file.each_line do |peptide_seq|
        peptide_seq.chomp!
        peptide_seq.abu = peptide_seq.match(/#.+/).to_s.chomp.gsub('#','').to_f
          peptide_seq.gsub!(/#.+/,'')
          Progress.progress("Creating peptides '#{file}':",((i/num_digested.to_f)*100.0).to_i)

        charge_ratio = charge_at_pH(identify_potential_charges(peptide_seq), @pH)
        charge_f = charge_ratio.floor
        charge_c = charge_ratio.ceil
        peptide_f = MS::Peptide.new(peptide_seq, charge_f, peptide_seq.abu) if charge_f != 0
        peptide_c = MS::Peptide.new(peptide_seq, charge_c, peptide_seq.abu) if charge_c != 0

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
