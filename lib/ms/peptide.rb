
require 'ms/feature/aa'

module MS
  class Peptide
    def initialize(sequence, rt = 0, mass = 0, charge = 0)
      @sequence = sequence
      @mass   = mass
      @charge = charge
      @rt = rt
      @int = 0
      @mz = calc_mz
    end
    
    attr_reader :sequence, :mass, :charge, :mz, :rt, :int
    attr_writer :sequence, :mass, :charge, :mz, :rt, :int
    
    def to_s
      "Peptide: #{@sequence}, mass = #{@mass}, charge = #{@charge}, m/z = #{@mz}, rt = #{@rt}, int = #{@int}"
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
  end
end
