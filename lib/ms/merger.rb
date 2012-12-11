require_relative '../progress'

class Merger
  def self.mz_value(arr)
    if arr.class == Hash
      return arr.keys[0][0]
    else
      return arr
    end
  end

  def self.int_value(arr)
    if arr.class == Array
      return arr.last + int_value(arr.first)
    else
      return arr
    end
  end

  def self.w_avg(values,weights)
    if values.class == hash
      values = values.values.flatten
    end
    a = []
    int = 0
    mz = 0
    values.each_with_index do |v,i| 
      mz = mz_value(v)
      int = int_value(weights[i])
      a<<mz*int
    end
    a = a.inject(:+)
    b = weights.flatten.inject(:+)
    return a/b
  end

  def self.merge(spectra,half_range)
    new_data = {}
    total = spectra.size
    k = 0
    prog = Progress.new("Merging Overlaps:")
    spectra.each do |rt,val|
      if k.even?
	num = (((k/total)*100).to_i)
	prog.update(num)
      end
      peaks = val.transpose
      peaks.sort_by!{|a| a[0]} #mz
      peaks = peaks.transpose
      mzs = peaks[0]
      ints = peaks[1]
      mzs.each_with_index do |mz,i|
        next if mz.class == Hash
        o_mz = mz
        mz = mz.keys[0][0] if mz.class == Hash
        range = (mz..mz+half_range)
        if range.include?(mzs[i+1])
          metaA_mz = [o_mz, mzs[i+1]]
          meta_int = [ints[i],ints[i+1]]
          sum = meta_int.flatten.inject(:+).to_f
          i1 = ints[i]
          i1 = ints[i].flatten.inject(:+) if ints[i].class == Array
          frac1 = (i1/sum) * 100
          frac2 = (ints[i+1]/sum) * 100
          metaB_mz = {[w_avg(metaA_mz,meta_int),frac1,frac2] => metaA_mz}

          mzs[i] = nil; mzs[i+1] = metaB_mz
          ints[i] = nil; ints[i+1] = meta_int
        end
      end
      spec = [mzs.compact,ints.compact]
      spec.ms_level = val.ms_level
      spec.ms2 = val.ms2
      new_data[rt] = spec
      k += 1
    end
    prog.finish!
    return new_data
  end

  def self.compact(spectra)
    @start = Time.now
    total = spectra.size
    k = 0
    num = 0
    prog = Progress.new("Merge Finishing:")
    step = total/100.0
    spectra.each do |rt,val|
      if k > step * (num + 1)
	num = (((k/total)*100).to_i)
	prog.update(num)
      end
      mzs = val[0]
      ints = val[1]
      mzs.each_with_index do |m,i|
        if m.class == Hash
          mzs[i] = m.keys[0][0]
          ints[i] = ints[i].flatten.inject(:+)
        end
      end
      spec = [mzs,ints]
      spec.ms_level = val.ms_level
      spec.ms2 = val.ms2
      spectra[rt] = spec
      k += 1
    end
    prog.finish!
    return spectra
  end
end

#test
#data = {1 => [[1.0,1.5,1.7,3.0,4.0,5.0,6.0,7.0,8.0,9.0],[10,9,8,7,6,5,4,3,2,1]], 2 => [[1,2,3,4,5,6,7,8,9],[9,8,7,6,5,4,3,2,1]]}
#p Merger.merge(data,0.5)
