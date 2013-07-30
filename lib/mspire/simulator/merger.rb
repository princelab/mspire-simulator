require 'mspire/utilities/progress'

module Mspire
  module Simulator ; end
end

class Mspire::Simulator::Merger
  class << self
    def mz_value(arr)
      if arr.class == Hash
        return arr.keys[0][0]
      else
        return arr
      end
    end

    def int_value(arr)
      if arr.class == Array
        return arr.last + int_value(arr.first)
      else
        return arr
      end
    end

    def w_avg(values,weights)
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

    def merge(half_range,db)
      prog = Mspire::Utilities::Progress.new("Merging Overlaps:")
      db.execute "CREATE TABLE IF NOT EXISTS merged(merge_id INTEGER PRIMARY KEY, merged_vals TEXT, a_vals TEXT, b_vals TEXT)"
      spectra = db.execute "SELECT * FROM spectra"
      spectra = spectra.group_by{|spec| spec[2]}
      total = spectra.size
      merge_id = 0
      k = 0
      spectra.each do |rt,peaks|
        if k.even?
          num = (((k/total)*100).to_i)
          prog.update(num)
        end
        peaks.sort_by!{|a| a[2]} #mz
        peaks_t = peaks.transpose
        pep_ids = peaks_t[1]
        cent_ids = peaks_t[0]
        mzs = peaks_t[3]
        ints = peaks_t[4]
        mzs.each_with_index do |mz,i|
          o_mz = mz
          range = (mz..mz+half_range)
          if range.include?(mzs[i+1])
            metaA_mz = [o_mz, mzs[i+1]]
            meta_int = [ints[i],ints[i+1]]
            sum = ints[i] + ints[i+1]
            new_mz = w_avg(metaA_mz,meta_int)
            db.execute "DELETE FROM spectra WHERE cent_id=#{cent_ids[i]}"
            db.execute "DELETE FROM spectra WHERE cent_id=#{cent_ids[i+1]}"
            db.execute "INSERT INTO spectra VALUES(#{cent_ids[i]},#{pep_ids[i]},#{rt},#{new_mz},#{sum},#{merge_id})"
            db.execute "INSERT INTO merged VALUES(#{merge_id}, '#{cent_ids[i]},#{pep_ids[i]},#{rt},#{new_mz},#{sum}', '#{peaks[i]}', '#{peaks[i+1]}')"
            merge_id += 1
          end
        end
        k += 1
      end
      prog.finish!
    end
  end
end
