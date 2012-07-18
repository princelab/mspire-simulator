
require 'mspire/isotope/distribution'

module MS
  class Peptide
    def initialize(sequence, charge)
      sequence
      @p_rt = 0
      @p_int = 0
      @rts = []
      @charge = charge #this is saved in the file name as well
      
      spec = calcSpectrum(sequence, @charge)
      
      @core_ints = spec.intensities.clone
      @core_mzs = spec.mzs.clone
      @mzs_file = ".m_#{sequence[0...15]}_#{charge}"
      @ints_file = ".i_#{sequence[0...15]}_#{charge}"
      file = File.open(@mzs_file, "w")
      file.puts(sequence)
      file.close
      @mono_mz = spec.mzs[spec.intensities.index(spec.intensities.max)]
      @mass = @mono_mz * @charge
      
      @aa_counts = [
        sequence.count("A"),
        sequence.count("R"),
        sequence.count("N"),
        sequence.count("D"),
        sequence.count("B"),
        sequence.count("C"),
        sequence.count("E"),
        sequence.count("Q"),
        sequence.count("Z"),
        sequence.count("G"),
        sequence.count("H"),
        sequence.count("I"),
        sequence.count("L"),
        sequence.count("K"),
        sequence.count("M"),
        sequence.count("F"),
        sequence.count("P"),
        sequence.count("S"),
        sequence.count("T"),
        sequence.count("W"),
        sequence.count("Y"),
        sequence.count("V"),
        sequence.count("J"),
        0.0]
    end
    
    attr_reader :mass, :charge, :mono_mz, :core_mzs, :p_rt, :p_int, :core_ints, :hydro, :pi, :aa_counts, :p_rt_i
    attr_writer :mass, :charge, :mono_mz, :core_mzs, :p_rt, :p_int, :core_ints, :hydro, :pi, :aa_counts, :p_rt_i
    
    def to_s
      file = File.open(@mzs_file,"r")
      seq = file.gets.chomp
      file.close
      "Peptide: #{seq}"
    end
    
    def sequence
      file = File.open(@mzs_file,"r")
      seq = file.gets.chomp
      file.close
      seq
    end
    
    #---------------------------------------------------------------------------
    def ints
      file = File.open(@ints_file, "r")
      line = file.gets.chomp.split(/;/)
      file.close
      ints = []
      line.each do |iso|
	ints<<iso.chomp.split(/,/).map!{|fl| fl.to_f}
      end
      return ints
    end
    
    def insert_ints(arr)
      file = File.open(@ints_file, "a")
      arr.each do |val|
	file.print("#{val},")
      end
      file.print(";")
      file.close
    end
    
    def mzs
      file = File.open(@mzs_file, "r")
      line = file.gets
      line = file.gets.chomp.split(/;/)
      file.close
      mzs = []
      line.each do |iso|
	mzs<<iso.chomp.split(/,/).map!{|fl| fl.to_f}
      end
      return mzs
    end
    
    def insert_mzs(arr)
      file = File.open(@mzs_file, "a")
      arr.each do |val|
	file.print("#{val},")
      end
      file.print(";")
      file.close
    end
    
    def rts
      return Sim_Spectra::r_times[@rts[0]..@rts[1]]
    end
    
    def set_rts(a,b)
      @rts = [a,b]
    end
    
    def delete
      if File.exists?(@mzs_file)
	File.delete(@mzs_file)
      end
      if File.exists?(@ints_file)
	File.delete(@ints_file)
      end
    end
    #---------------------------------------------------------------------------
    
    # Calculates theoretical specturm
    #
    def calcSpectrum(seq, charge)
      #isotope.rb from Dr. Prince
      atoms = countAtoms(seq)
      
      var = ""
      var<<"O"
      var<<atoms[0].to_s
      var<<"N"
      var<<atoms[1].to_s
      var<<"C"
      var<<atoms[2].to_s
      var<<"H"
      var<<atoms[3].to_s
      var<<"S"
      var<<atoms[4].to_s
      var<<"P"
      var<<atoms[5].to_s
      var<<"Se"
      var<<atoms[6].to_s
      
      mf = Mspire::MolecularFormula.new(var, charge)
      spec = Mspire::Isotope::Distribution.spectrum(mf, :max, 0.001)

      spec.intensities.map!{|i| i = i*100.0}

      return spec
    end
    
      
    # Counts the number of each atom in the peptide sequence.
    #
    def countAtoms(seq)
      o = 0
      n = 0
      c = 0
      h = 0
      s = 0
      p = 0
      se = 0
      seq.each_char do |aa|
      
	#poly amino acids
	#"X" is for any (I exclude uncommon "U" and "O")
	if aa == "X"
	  aas = Mspire::Isotope::AA::ATOM_COUNTS.keys[0..19]
	  aa = aas[rand(20)]
	#"B" is "N" or "D"
	elsif aa == "B"
	  aas = ["N","D"]
	  aa = aas[rand(3)]
	#"Z" is "Q" or "E"
	elsif aa == "Z"
	  aas = ["Q","E"]
	  aa = aas[rand(3)]
	end
	
	if aa !~ /A|R|N|D|C|E|Q|G|H|I|L|K|M|F|P|S|T|W|Y|V|U|O/
	  puts "No amino acid match for #{aa}"
	else
	  o = o + Mspire::Isotope::AA::ATOM_COUNTS[aa][:o]
	  n = n + Mspire::Isotope::AA::ATOM_COUNTS[aa][:n]
	  c = c + Mspire::Isotope::AA::ATOM_COUNTS[aa][:c]
	  h = h + Mspire::Isotope::AA::ATOM_COUNTS[aa][:h]
	  s = s + Mspire::Isotope::AA::ATOM_COUNTS[aa][:s]
	  p = p + Mspire::Isotope::AA::ATOM_COUNTS[aa][:p]
	  se = se + Mspire::Isotope::AA::ATOM_COUNTS[aa][:se]
	end
      end
      return (o + 1),n,c,(h + 2) ,s,p,se
    end
  end
end
