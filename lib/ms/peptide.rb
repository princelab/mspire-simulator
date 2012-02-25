
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
    
    def calc_hydro(seq)
      hydrohash = { #assumes pH of 2, which is not perfect,
      #source http://www.sigmaaldrich.com/life-science/metabolomics/learning-center/amino-acid-reference-chart.html#hydro
      #no well established hydrophobic values exist for selenomethionine, selenocysteine, or pyrrolysine
         "*"=>0,
         "A"=>47.0,
         "B"=>-29.5, #averaged D and N
         "C"=>52.0,
         "D"=>-18.0,
         "E"=>8.0,
         "F"=>92.0,
         "G"=>0.0,
         "H"=>-42.0,
         "I"=>100,
         "K"=>-37.0,
         "L"=>100.0,
         "M"=>74.0,
         "N"=>-41.0,
         #"O"=>100.0,
         "P"=>-46.0,
         "Q"=>-18.0,
         "R"=>-26.0,
         "S"=>-7.0,
         "T"=>13.0,
         #"U"=>150.0379,
         "V"=>79.0,
         "W"=>84.0,
         "X"=>0, #unknowns given a neutral value of 0, the same as G
         "Y"=>49.0,
         "Z"=>-5.0 #averaged E and Q
       }
       sum = 0.0
       seq.each_char do |ch|
         sum += hydrohash[ch]
       end
       return sum/seq.length
    end
    
    def calc_pi(seq)
      pihash = { #assumes pH of 2, which is not perfect,
        #source http://www.imb-jena.de/IMAGE_AA.html
        "*"=>0,
        "B"=>4.195, #averaged D and N
        "X"=>5.21685, #average of all residues
        "Z"=>-5.0, #averaged E and Q
        "A"=>6.107,
        "R"=>10.76,
        "D"=>2.98,
        "N"=>-0,
        "C"=>5.02,
        "E"=>3.08,
        "Q"=>-0,
        "G"=>6.064,
        "H"=>7.64,
        "I"=>6.038,
        "L"=>6.036,
        "K"=>9.47,
        "M"=>5.74,
        "F"=>5.91,
        "P"=>6.3,
        "S"=>5.68,
        "T"=>-0,
        "W"=>5.88,
        "Y"=>5.63,
        "V"=>6.002
      }
      sum = 0.0
       seq.each_char do |ch|
         sum += pihash[ch]
       end
       return sum/seq.length
    end
  end
end
