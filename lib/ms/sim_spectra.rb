
module MS
  class Sim_Spectra
    def initialize(peptides,sampling_rate, run_time, drop_percentage = 0.12,density = 10.0,one_d = false)
      @density = density
      @data
      @max_mz
      #RTS
      @@r_times = []
      num_of_spec = sampling_rate*run_time
      spec_time = 1/sampling_rate
      num_of_spec.to_i.times do
        @@r_times<<spec_time+RThelper.RandomFloat(-0.5,0.5)
        spec_time = spec_time + (1/sampling_rate)
      end
      @@r_times = MS::Noise.spec_drops(drop_percentage)
      
      pre_features = MS::Rtgenerator.generateRT(peptides,one_d)
      
      #Features
      features_o = MS::Sim_Feature.new(pre_features,one_d)
      @features = features_o.features
      @data = features_o.data
      @max_mz = @data.max_by{|key,val| if val != nil;val[0].max;else;0;end}[1][0].max
      @spectra = @data.clone
      
      @noise = nil
      
    end
    
    def noiseify
      @noise = MS::Noise.noiseify(@density,@max_mz)
      
      @@r_times.each do |k|
	s_v = @data[k]
	n_v = @noise[k]
	if s_v != nil
	  @spectra[k] = [s_v[0]+n_v[0],s_v[1]+n_v[1]]
	else
	  @spectra[k] = [n_v[0],n_v[1]]
	end
      end
      
      #-----------------------------------------------------------------
      #Detect overlapping peaks:
      #Weighted avg for m/z - Sum Intensities
      @start = Time.now
      new_spectra = {}
      count = 0
      @spectra.each do |k,arr|
	Progress.progress("Merging Overlaps:",((count/@spectra.size.to_f)*100).to_i)
	overlaps = []
	mzs = arr[0].clone
	ints = arr[1].clone
	max = mzs.max
	min = mzs.min
	mzs.clone.each do |mz|
	  group = mzs.group_by{|m| ((mz-0.01)..(mz+0.01)).member?(m)}[true]
	  if group.size > 1
	    group_i = group.map{|m| mzs.index(m)}
	    overlaps<<group_i
	  end
	end
	overlaps.uniq!
	#bigger groups than two
	overlaps.clone.combination(2) do |a,b|
	  c = a.size + b.size
	  if c != (a+b).uniq.size
	    if a.size > b.size
	      overlaps.delete(b)
	    else
	      overlaps.delete(a)
	    end
	  end
	end
	#end
	if !overlaps.empty?
	  overlaps.each do |ol|
	    new_int = 0
	    new_mz = 0
	    n_mzs = []
	    n_ints = []
	    ol.each{|i| new_int += ints[i]; n_mzs<<mzs[i]; n_ints<<ints[i]}
	    new_mz = w_avg(n_mzs,n_ints)
	    ol.each{|i| ints[i] = nil; mzs[i] = nil}
	    ints<<new_int
	    mzs<<new_mz
	  end
	end
	new_spectra[k] = [mzs.compact,ints.compact]
	count += 1
      end
      @spectra = new_spectra
      Progress.progress("Merging Overlaps:",100,Time.now-@start)
      puts ""
      #-----------------------------------------------------------------
      
      return @noise
    end
    
    def self.r_times
      @@r_times
    end
    
    def w_avg(values,weights)
      a = []
      values.each_with_index{|v,i| a<<v*weights[i]}
      a = a.inject(:+)
      b = weights.inject(:+)
      return a/b
    end
    
    attr_reader :data, :max_mz, :spectra, :noise, :features
    attr_writer :data, :max_mz, :spectra, :noise, :features
    
  end
end

#charge ratio: take both charge states, determine pH effective
#more small peaks from lesser charge states

#one_d
#fit to other labs data - different machine
