#Author: John Prince

require 'fftw3'
# install Rserve  (linux: sudo apt-get install rserve)
# % gem install rserve-simpler

#require 'rserve/simpler/R'

#mz = [1,2,3,4,5]
#int = [10,20,10,30,50]
#
#R.converse(mzr: mz, intr: int) do
#  %Q{
#  plot(mzr, intr, type="h")
#
#  }
#end
#R.pause


module Isotope_dist
  #MAX_MASS needs to be highest possible nominal mass
  MAX_MASS=2**16;
  ORDER = [:h, :c, :n, :o, :s]
  ISOTOPE_VALUES = {
    1 => [0.9998443, 0.0001557],
    12 => [0.98889, 0.01111],
    14 => [0.99634, 0.00366],
    16 => [0.997628, 0.000372, 0.002000],
    32 => [0.95018, 0.00750, 0.04215, 0, 0.00017],
  }

  module_function
  # returns atomic composition as a new array ordered by ORDER.  arg is a
  # String, Array, or Hash:
  #
  #     [22, 12, 1, 3, 2]                 # must be ordered: H, C, N, O, S (returns a duplicated array)
  #     "H22C12N1O3S2"                    # <= order doesn't matter
  #     {h: 22, c: 12, n: 1, o: 3, s: 2}  # case and string/sym doesn't matter
  #
  # Ensures that the element array is complete
  def any_to_num_elements(arg)
    array = 
      if arg.is_a? Array
        arg.dup
      else
        hash = arg.is_a?(Hash) ? arg : Hash[arg.scan(/([HCNOS])(\d+)/i).map {|k,v| [k, v.to_i] }]
        hash.map {|k,v| [ORDER.index(k.to_s.downcase.to_sym), v]}.sort.map(&:last)
      end
    ORDER.size.times.map {|i| array[i] || 0 } 
  end

  # takes a valid element array (see any_to_num_elements) and returns an array
  # giving isotope ratios at each atomic number
  # e.g. the monoisotopic peak for CH3 will be at the 15th position (index 14)
  def raw_dist(el_ar, max_mass=MAX_MASS)
    freqs = ISOTOPE_VALUES.zip(el_ar).map do |(z,ivals),nz|
      z_ar = NArray.float(max_mass)
      z_ar[z...(z+ivals.size)] = ivals
      FFTW3.fft(z_ar)**nz
    end
    FFTW3.ifft(freqs.reduce(:*)).real.to_a.rotate!(1)
  end

  # takes any element composition (see any_to_num_elements).
  #
  # returns isotopic distribution beginning with monoisotopic peak and
  # finishing when the peak contributes less than percent_cutoff to the total
  # distribution.  percent_total gives the distribution in terms of percent of
  # total distribution.  If false, gives it relative to highest peak.
  def dist(composition, percent_cutoff=0.001, percent_total=true)
    el_ar = any_to_num_elements(composition)
    dist = raw_dist(el_ar)
    start_index = el_ar.zip(ISOTOPE_VALUES.keys).map {|n,z| n * z }.reduce(:+) - 1
    mono_dist = dist[start_index..-1]
    final_output = []
    sum = 0.0
    mono_dist.each do |peak|
      break if (peak / sum)*100 < percent_cutoff
      final_output << peak
      sum += peak 
    end
    norm_by = percent_total ? sum : final_output.max
    final_output.map {|i| 100 * i / norm_by }
  end

  extend(self)
end

=begin
    # NArray is given n,m
    grid = NArray.float(MAX_MASS, ORDER.size).fill(0.0)
    ISOTOPE_VALUES.each_with_index do |(z,ivals),i|
      grid[z...(z+ivals.size),i] = ivals
    end
    t_grid = FFTW3.fft(grid,0)
    t_products = NArray.float(MAX_MASS).fill(1.0)
    ORDER.size.times do |i|
      t_products *= t_grid[true,i]**el_array[i]
    end
    ript_a = FFTW3.ifft(t_products).real
    id = NArray.float(MAX_MASS)
    id[0..-2] = ript_a[1..-1]
    id
=end

if __FILE__ == $0
  var = "C12H22N1S2O3"                    # <= order doesn't matter
  #var = [22, 12, 1, 3, 2]                 # ordered: H, C, N, O, S 
  #var = {h: 22, c: 12, n: 1, o: 3, s: 2}  # case and string/sym doesn't matter
  #var = [1]
  p Isotope.any_to_num_elements(var)
  id = Isotope.raw_dist(Isotope.any_to_num_elements(var))
  p id[291,10]
  id = Isotope.dist(var, 0.001, true)
  p id
  id = Isotope.dist(var)
  p id
  p id.reduce(:+)
  #R.converse(id: id) {%Q{svg("hiya.svg"); barplot(id); dev.off() }}
end
