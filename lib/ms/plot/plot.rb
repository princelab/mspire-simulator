require 'ms/peptide'
require 'ms/plot/mgl_plot'

module MS
	class Plot
		def plot(centroids)
			plot3d(centroids[1])
		end
		
		def plot3d(cents)
			#[mzs,rts,ints,groups]

			Mgl_Plot.newPlot(1.0,0.0)
			x = cents[0].sort[0]
			x2 = cents[0].sort[cents[0].length-1]
			y = cents[1].sort[0]
			y2 = cents[1].sort[cents[0].length-1]
			z = cents[2].sort[0]
			z2 = cents[2].sort[cents[0].length-1]
			Mgl_Plot.setRange(x,x2,y,y2,z,z2)
			
			for i in (0..(cents[0].length-1))
				Mgl_Plot.addLine(cents[0][i],cents[1][i],cents[2][i])
			end
			
			Mgl_Plot.plotC()
		end
	end
end

