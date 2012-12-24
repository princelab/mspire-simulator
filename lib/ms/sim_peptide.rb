require 'mspire/isotope/distribution'

module MS
  class Peptide
    def initialize(sequence, charge, abu = 1.0,db,id,prot_id)
      @abu = abu
      @p_rt = 0
      @p_int = 0
      @rts = []
      @charge = charge 

      spec = calcSpectrum(sequence, @charge)

      # TODO Ryan: alter this to handle variable and static mass modifications... Add it from the Katamari code

      #core mzs, ints
      db.execute "INSERT INTO core_spec VALUES(#{id},'#{spec.mzs}','#{spec.intensities}')"

      @mono_mz = spec.mzs[spec.intensities.index(spec.intensities.max)]
      @mass = @mono_mz * @charge
      #U,O,X ???
      @aa_counts = []
      stm = "INSERT INTO aac VALUES(#{id},"
      amino_acids = ['A','R','N','D','B','C','E','Q','Z','G','H','I',
        'L','K','M','F','P','S','T','W','Y','V','J']
      amino_acids.map do |aa|
        count = sequence.count(aa)
        stm<<"#{count},"
        count
      end
      stm<<"0.0)" #place holder for predicted values
      stm = db.prepare(stm)
      stm.execute
      stm.close if stm
      db.execute "INSERT INTO peptides VALUES(#{id},'#{sequence}', #{@mass}, #{charge}, #{@mono_mz}, #{@p_rt},NULL, #{@p_int}, #{@abu}, NULL,NULL,NULL,#{prot_id})"
    end

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

      mf = Mspire::MolecularFormula.from_string(var, charge)
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
	#maybe in the future ignore fringe case amino acids
        #"X" is for any (I exclude uncommon "U" and "O")
        if aa == "X"
          aas = Mspire::Isotope::AA::ATOM_COUNTS.keys[0..19]
          aa = aas[rand(20)]
          #"B" is "N" or "D"
        elsif aa == "B"
          aas = ["N","D"]
          aa = aas[rand(2)]
          #"Z" is "Q" or "E"
        elsif aa == "Z"
          aas = ["Q","E"]
          aa = aas[rand(2)]
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
      @charge.times {h += 1}
      return (o + 1),n,c,(h + 2),s,p,se
    end
  end
end
