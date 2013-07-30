require 'mspire/utilities/progress'
require 'mspire/simulator/curve_fit/mzml_reader'
require 'mspire/simulator/curve_fit/helper'


module Mspire
  module Simulator ; end
end

class Mspire::Simulator::CurveFit
  @@avg_mz = 0
  @@avg_rt = 0

  def self.get_parameters(opts)
    data = MzmlReader.get_data(opts[:mzml])
    generations = opts[:generations]

    @pts_int_var = []
    @pts_mz_var = []
    @pts_elut = []

    file = File.open(opts[:mzml],"r")

    mzs_in = data[0]
    rts_in = data[1]
    ints_in = data[2]

    @@avg_mz = mzs_in.inject(:+)/mzs_in.size.to_f
    @@avg_rt = rts_in.inject(:+)/rts_in.size.to_f

    ints_in = GenCurvefit.normalize(ints_in)
    #-----------------------overlapRange--------------------------------------------
    mean = mzs_in.inject(:+)/mzs_in.size
    opts[:overlapRange] = (mzs_in.sample_variance(mean)*10**6)/4
    #-------------------------------------------------------------------------------


    #----------------------create points/curve to fit elution-----------------------
    ints_in.each_with_index do |s,i|
      @pts_elut<<[rts_in[i],s]
    end
    opts[:sampling_rate] = rts_in.size/(rts_in.max - rts_in.min)

    a_fit = GenCurvefit.new(@pts_elut)
    a_fit.set_fit_function(lambda{|a,i| 100.0*Math.exp(-(rts_in.index(i)-a[2])**2/((a[1]*rts_in.index(i)+a[0])**2))})
    a_fit.mutation_limits = [[-5,5],[-1,1],[-rts_in.size/2,rts_in.size/2]]
    a_fit.popsize = 10
    a_fit.paramsize = 3
    a_fit.init_population
    a_fit.generations = generations

    best = a_fit.fit
    opts[:front] = best[0]
    opts[:tail] = best[1]
    opts[:mu] = best[2]
    #puts "RMSD = #{best[3]}"
    labels = ["retention time","normalized intensity"]
    a_fit.plot("elution_curvefit.svg",labels)
    #-------------------------------------------------------------------------------


    #-----------------create points/curve to fit m/z variance-----------------------
    wobs = []
    mean = mzs_in.inject(:+)/mzs_in.size
    mzs_in.each do |mz|
      wobs<<(mean-mz).abs
    end

    ints_in.length.times do |d|
      if d >= 3
        sd = wobs[d-3..d].standard_deviation
        @pts_mz_var<<[ints_in[d],sd]
      end
    end

    b_fit = GenCurvefit.new(@pts_mz_var)
    b_fit.set_fit_function(lambda{|a,i| a[0]*i**a[1]})
    b_fit.mutation_limits = [[-1,1],[-1,1]]
    b_fit.popsize = 10
    b_fit.paramsize = 2
    b_fit.init_population
    b_fit.generations = generations

    best = b_fit.fit
    opts[:wobA] = best[0]
    opts[:wobB] = best[1]
    #puts "RMSD = #{best[2]}"
    labels = ["normalized intensity","m/z variance"]
    b_fit.plot("mz_var_curvefit.svg",labels)
    #-------------------------------------------------------------------------------

    #--------------------create points/curve to fit intensity variance--------------
    smooth_ave = GenCurvefit.smoothave(ints_in)

    diff = []
    smooth_ave.each_with_index do |s,i|
      if s == nil
        diff<<0
      else
        diff<<(s-ints_in[i]).abs
      end
    end


    ints_in.each_with_index do |i,d|
      if d >= 3
        sd = diff[d-3..d].standard_deviation
        @pts_int_var<<[i,sd]
      end
    end

    c_fit = GenCurvefit.new(@pts_int_var)
    c_fit.set_fit_function(lambda{|a,i| a[0]*(1-Math.exp(-a[2]*i))+a[1]})
    c_fit.mutation_limits = [[-20,20],[-0.5,0.5],[-0.5,0.5]]
    c_fit.popsize = 10
    c_fit.paramsize = 3
    c_fit.init_population
    c_fit.generations = generations

    best = c_fit.fit
    opts[:jagA] = best[0]
    opts[:jagC] = best[1]
    opts[:jagB] = best[2]
    #puts "RMSD = #{best[3]}"
    labels = ["normalized intensity","intensity variance"]
    c_fit.plot("intensity_var_curvefit.svg",labels)
    #-------------------------------------------------------------------------------

    return opts
  end
end
=begin
out_file = File.open("mzvar_params.txt","w")
out_file.puts "wobA\twobB\tavg_mz\tavg_rt"
ARGV.each do |file|
p file
  opts = {:mzml => file, :generations => 30000}
  opts = CurveFit.get_parameters(opts)
  out_file.puts "#{opts[:wobA]}\t#{opts[:wobB]}\t#{@@avg_mz}\t#{@@avg_rt}"
end
out_file.close
=end
