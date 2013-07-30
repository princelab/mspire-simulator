require 'mspire/isotope/distribution'

module Mspire
  module Simulator
    class Peptide
      def initialize(sequence, charge, abu = 1.0,db,id,prot_id,modifications)
        @abu = abu
        @p_rt = 0
        @p_int = 0
        @rts = []
        @charge = charge 

        @mods = modifications

        spec = calcSpectrum(sequence)

        # TODO Ryan: alter this to handle variable and static mass modifications...Add it from the Katamari code

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
      def calcSpectrum(seq)
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

        mf = Mspire::MolecularFormula.from_string(var, @charge)
        spec = Mspire::Isotope::Distribution.spectrum(mf, :max, 0.001)

        spec.intensities.map!{|i| i = i*100.0}

        return spec
      end


      # Counts the number of each atom in the peptide sequence.
      #
      def countAtoms(seq)
        atom_indexes = {'O' => 0,'N' => 1,'C' => 2,'H' => 3,'S' => 4,'P' => 5,'Se' => 6}
        o = 0
        n = 0
        c = 0
        h = 0
        s = 0
        p = 0
        se = 0
        @charge.times {h += 1}
        atom_counts = [(o + 1),n,c,(h + 2),s,p,se]

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

          #perform modification for residue
          if @mods != nil
            if @mods[aa] != nil
              mods = @mods[aa]
              mods.each do |mod|
                if mod[2] #variable
                  if rand(2) == 1
                    mod[1].split(/\s/).each_slice(2) do |sl|
                      atom_counts[atom_indexes[sl[0]]] = atom_counts[atom_indexes[sl[0]]] + sl[1].to_i 
                    end
                  end
                else
                  mod[1].split(/\s/).each_slice(2) do |sl|
                    atom_counts[atom_indexes[sl[0]]] = atom_counts[atom_indexes[sl[0]]] + sl[1].to_i 
                  end
                end
              end
            elsif seq[0] == aa and @mods["CT"] != nil#N-terminus
              mods = @mods["CT"]
              mods.each do |mod|
                if mod[2] #variable
                  if rand(2) == 1
                    mod[1].split(/\s/).each_slice(2) do |sl|
                      atom_counts[atom_indexes[sl[0]]] = atom_counts[atom_indexes[sl[0]]] + sl[1].to_i 
                    end
                  end
                else
                  mod[1].split(/\s/).each_slice(2) do |sl|
                    atom_counts[atom_indexes[sl[0]]] = atom_counts[atom_indexes[sl[0]]] + sl[1].to_i 
                  end
                end
              end
            elsif seq[-1] == aa and @mods["NT"] != nil#C-terminus
              mods = @mods["NT"]
              mods.each do |mod|
                if mod[2] #variable
                  if rand(2) == 1
                    mod[1].split(/\s/).each_slice(2) do |sl|
                      atom_counts[atom_indexes[sl[0]]] = atom_counts[atom_indexes[sl[0]]] + sl[1].to_i 
                    end
                  end
                else
                  mod[1].split(/\s/).each_slice(2) do |sl|
                    atom_counts[atom_indexes[sl[0]]] = atom_counts[atom_indexes[sl[0]]] + sl[1].to_i 
                  end
                end
              end
            end
          end

          if aa !~ /A|R|N|D|C|E|Q|G|H|I|L|K|M|F|P|S|T|W|Y|V|U|O/
            puts "No amino acid match for #{aa}"
          else
            atom_counts[0] = atom_counts[0] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:o]
            atom_counts[1] = atom_counts[1] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:n]
            atom_counts[2] = atom_counts[2] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:c]
            atom_counts[3] = atom_counts[3] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:h]
            atom_counts[4] = atom_counts[4] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:s]
            atom_counts[5] = atom_counts[5] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:p]
            atom_counts[6] = atom_counts[6] + Mspire::Isotope::AA::ATOM_COUNTS[aa][:se]
          end
        end
        return atom_counts
      end
    end
  end
end
