
require 'time'
require 'mspire/simulator/curve_fit/fit_plot'


module Enumerable
  def sum
    self.inject(0){|accum, i| accum + i }
  end

  def mean
    self.sum/self.length.to_f
  end

  def sample_variance(mean)
    m = mean
    sum = self.inject(0){|accum, i| accum +(i-m)**2 }
    sum/(self.length - 1).to_f
  end

  def standard_deviation(mean = self.mean)
    return Math.sqrt(self.sample_variance(mean))
  end
end

module Mspire
  module Simulator ; end
end

class Mspire::Simulator::GenCurvefit
  def initialize(pts_in,function = nil,paramsize = nil,mutation_limits = nil,popsize = 0,generations = nil)
    @pts_in = pts_in
    @function = function
    @paramsize = paramsize
    @mutation_limits = mutation_limits
    @popsize = popsize
    @generations = generations
    @population = []
    if @popsize != 0 and @paramsize != nil and @mutation_limits != nil and @function != nil
      init_population
    end
  end

  attr_reader :function, :paramsize, :mutation_limits, :population, :generations, :popsize
  attr_writer :paramsize, :mutation_limits, :population, :generations, :popsize

  def init_population
    @popsize.times do
      set = []
      @paramsize.times do |i|
        limits = @mutation_limits[i]
        set<<random_float(limits[0],limits[1])
      end
      set<<fitness(set,@pts_in)
      @population<<set
    end
  end

  def set_fit_function(func)
    @function = func
  end

  def mutate(set)
    index = rand(set.size-1)
    limits = @mutation_limits[index]
    set[index] += random_float(limits[0],limits[1])
  end

  def self.smoothave(arr)
    smooth_ave = [nil,nil,nil]
    queue = []
    arr.each do |i|
      queue.push(i)
      if queue.size > 7
        queue.shift
      end
      smooth_ave<<queue.inject(:+)/queue.size if queue.size == 7
    end
    3.times do 
      smooth_ave<<nil
    end
    return smooth_ave
  end

  def self.normalize(arr)
    max = arr.max
    arr.map!{|i| (i.to_f/max) * 100}
  end

  def sort_by_fitness
    @population.sort_by!{|set| set.last}     
  end  

  def random_float(a,b)
    a = a.to_f
    b = b.to_f
    random = rand(2147483647.0) / 2147483647.0
    diff = b - a
    r = random * diff
    return a + r
  end

  def rmsd(v,w)
    n = v.size
    sum = 0.0
    n.times{|i| sum += ((v[i][0]-w[i][0])**2.0 + (v[i][1]-w[i][1])**2.0) }
    return Math.sqrt( (1/n.to_f) * sum )
  end


  def fitness(set,pts_in,plot = false)
    pts = []
    xs = pts_in.transpose[0]
    xs.each do |x|
      fit_pt = function.call(set,x)
      pts<<[x,fit_pt]
    end

    if plot
      return pts
    end

    return rmsd(pts_in,pts)
  end

  def fit
    prog = Mspire::Utilities::Progress.new("Generation")
    num = 0
    total = @generations
    step = total/100
    @generations.times do |i|
      if i > step * (num + 1)
	num = ((i/total.to_f)*100).to_i
	prog.update(num," #{i+1}:")
      end
      #Generate mutations
      index = rand(@popsize)
      clone = @population[index].clone
      mutate(clone)
      clone[@paramsize] = fitness(clone,@pts_in)

      if(clone.last < @population.last.last)
        @population[@population.size - (@paramsize-1)] = clone
      end
      #Re-sort
      @population = sort_by_fitness

      #Print best
      if i == @generations - 1
        @best = @population.first
      end
    end 
    prog.finish!
    return @best
  end

  def plot(file,labels = nil)
    pts = fitness(@best,@pts_in,true)
    FitPlot.plot(@pts_in,pts,file,labels)
    puts "  Output File: #{file}"
  end

end
