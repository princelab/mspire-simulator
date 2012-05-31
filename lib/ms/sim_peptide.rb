
require 'mspire/isotope/distribution'

module MS
  class Peptide
    def initialize(sequence, charge)
      @sequence = sequence
      @p_rt = 0
      @rts = []
      @charge = charge
      @c_ratio = nil
      
      spec = calcPercent(@sequence, @charge)
      
      @core_ints = spec.intensities
      @core_mzs = spec.mzs
      @mzs = []
      @ints = []
      @mono_mz = spec.mzs[spec.intensities.index(spec.intensities.max)]
      @mass = @mono_mz * @charge
    end
    
    attr_reader :sequence, :mass, :charge, :c_ratio, :mono_mz, :mzs, :core_mzs, :p_rt, :rts, :core_ints, :ints, :hydro, :pi
    attr_writer :sequence, :mass, :charge, :c_ratio, :mono_mz, :mzs, :core_mzs, :p_rt, :rts, :core_ints, :ints, :hydro, :pi
    
    def to_s
      "Peptide: #{@sequence}"
    end
    
    
    # Calculates the relative intensities of the isotopic 
    # envelope.
    #
    def calcPercent(seq, charge)
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
	
        o = o + Mspire::Isotope::AA::ATOM_COUNTS[aa][:o]
        n = n + Mspire::Isotope::AA::ATOM_COUNTS[aa][:n]
        c = c + Mspire::Isotope::AA::ATOM_COUNTS[aa][:c]
        h = h + Mspire::Isotope::AA::ATOM_COUNTS[aa][:h]
        s = s + Mspire::Isotope::AA::ATOM_COUNTS[aa][:s]
        p = p + Mspire::Isotope::AA::ATOM_COUNTS[aa][:p]
        se = se + Mspire::Isotope::AA::ATOM_COUNTS[aa][:se]
      end
      return (o + 1),n,c,(h + 2) ,s,p,se
    end
  end
end
