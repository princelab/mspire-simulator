
module MS
	class Peptide
		def initialize(sequence, mass, charge, rt = 0, group = 0)
			@sequence = sequence
			@mass   = mass
			@charge = charge
			@rt = rt
			@int = 0
			@group = group
			if charge == 0
				@mz = 0
			else
				@mz = mass/charge
			end
		end
		
		attr_reader :sequence, :mass, :charge, :mz, :rt, :int, :group
		attr_writer :sequence, :mass, :charge, :mz, :rt, :int, :group
		
		def to_s
			"Peptide: #{@sequence}, mass = #{@mass}, charge = #{@charge}, m/z = #{@mz}, rt = #{@rt}, int = #{@int}, group = #{@group}"
		end
	end
end
