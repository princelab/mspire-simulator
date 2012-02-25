
require 'ms/feature/aa'

module MS
  class Peptide
    def initialize(sequence, rt = 0, mass = 0, charge = 0)
      @sequence = sequence
      @hydro = calc_hydro(@sequence)
      @pi = calc_pi(@sequence)
      @mass   = mass
      @charge = charge
      @rt = rt
      @int = 0
      @mz = calc_mz
    end
    
    attr_reader :sequence, :mass, :charge, :mz, :rt, :int, :hydro, :pi
    attr_writer :sequence, :mass, :charge, :mz, :rt, :int, :hydro, :pi
    
    def to_s
      "Peptide: #{@sequence}"
    end
    
    def calc_mz
      @sequence.each_char do |aa|
        @mass = @mass + MS::Mass::AA::MONO[aa]
        h = 'H'
        k = 'K'
        r = 'R'
        if aa == h or aa == k or aa == r
          @charge = @charge + 1
        end
      end
      return @mass/@charge
    end
    
    #James Dalg
    def calc_hydro(seq)
       sum = 0.0
       seq.each_char do |ch|
         sum += MS::Feature::AA::HYDROPHOBICTY[ch]
       end
       return sum/seq.length
    end
    
    #James Dalg
    def calc_pi(seq)
      sum = 0.0
       seq.each_char do |ch|
         sum += MS::Feature::AA::PIHASH[ch]
       end
       return sum/seq.length
    end
  end
end
