
require 'time'
require 'distribution'
require 'msplat'
require 'ms/peptide'
require 'ms/feature/isotope'
require 'ms/rt/rt_helper'

module MS
  module Feature
    class Feature 
      def initialize(peptide_groups,sampling_rate,r_time)
        #predict isotopes/relative abundance
        #add noise (wobble)
        @start = Time.now
        @features = []
        @data = {}
	@sampling_rate = sampling_rate
	@r_time = r_time
        peptide_groups.each_with_index do |peptides,ind|
          Progress.progress("Generating features:",(((ind+1)/peptide_groups.size.to_f)*100).to_i)
          relative_abundances = calcPercent(peptides[0][0].sequence)
          avg_rt = peptides[1]
          waves = []
          
          relative_abundances.length.times do
            newpeps = []
            peptides[0].each do |peptide|
              newpeps<<MS::Peptide.new(peptide.sequence,peptide.rt)
            end
            waves<<newpeps
          end
          
          feature = getInts(waves,relative_abundances,avg_rt)
          @features<<feature
        end
        Progress.progress("Generating features:",100,Time.now-@start)
        puts ""
        @start = Time.now
        
        @features = @features.flatten.group_by{|pep| pep.rt}
        count = 1
        @features.each do |rt, peps|
          Progress.progress("Populating structure for mzml:",((count/@features.size.to_f)*100).to_i)
          mzs = []
          ints = []
          peps.each do |pep|
            mzs<<pep.mz
            ints<<pep.int
          end
          @data[rt] = [mzs,ints]
          count += 1
        end
        Progress.progress("Populating structure for mzml:",100,Time.now-@start)
        puts ""
      end
      
      attr_reader :data
      attr_writer :data
      
      # Counts the number of each atom in the peptide sequence.
      #
      def countAtoms(seq)
        o = 0
        n = 0
        c = 0
        h = 0
        s = 0
        p = 0
        se = 0
        seq.each_char do |aa|
          o = o + MS::Feature::AA::ATOM_COUNTS[aa][:o]
          n = n + MS::Feature::AA::ATOM_COUNTS[aa][:n]
          c = c + MS::Feature::AA::ATOM_COUNTS[aa][:c]
          h = h + MS::Feature::AA::ATOM_COUNTS[aa][:h]
          s = s + MS::Feature::AA::ATOM_COUNTS[aa][:s]
          p = p + MS::Feature::AA::ATOM_COUNTS[aa][:p]
          se = se + MS::Feature::AA::ATOM_COUNTS[aa][:se]
        end
        return o,n,c,h,s,p,se
      end
      
      # Calculates the relative intensities of the isotopic 
      # envelope.
      #
      def calcPercent(seq)
        #isotope.rb from Dr. Prince
        atoms = countAtoms(seq)
        
        var = ""
        var<<"O"
        var<<atoms[0].to_s
        var<<"N"
        var<<atoms[1].to_s
        var<<"C"
        var<<atoms[2].to_s
        var<<"H"
        var<<atoms[3].to_s
        var<<"S"
        var<<atoms[4].to_s
        var<<"P"
        var<<atoms[5].to_s
        var<<"SE"
        var<<atoms[6].to_s
  
        rel_intesities = Isotope.dist(var)
        #puts percents
        return rel_intesities
      end
      
      # Intensities are shaped in the rt direction by the gaussian with 
      # a dynamic standard deviation.
      # They are also shaped in the m/z direction 
      # by a simple gaussian curve (see 'factor' below). 
      #
      def getInts(fins, relative_abundances, avg)
        intRand = (fins[0][0].charge)*10**2
        stddev = rand+2
      
        index = 0
        neutron = 0
        
        fins.each do |fin|
          mzmu = fin[0].mz + neutron + 0.5
          max_y = RThelper.gaussian(mzmu,mzmu,0.05) 
          
          #percent_int = intRand*percents[index]
          relative_abundances_int = relative_abundances[index]
          
          fin.uniq! {|p| p.rt}
          fin = fin.sort_by {|p| p.rt}
          
          #This 'x' is for tailing,
          #needs to change for different
          #sampling rates.
	  #TODO expand and contract ???
	  rt_mean = @r_time/2
	  length = RThelper.gaussianI(avg,rt_mean,@r_time/2.5,200.0)
	  
	  time = (fin.max_by {|p| p.rt}.rt - fin.min_by {|p| p.rt}.rt)/2
	  
          step = time/(length*10)
	  puts "step: #{step}, length: #{length}, fin_length: #{fin.length}"
          x = 0.0
          
          fin.each do |p|
            
            
            #-------------Tailing-------------------------
            shape = 0.35*x + 6.65
	    p.int = (RThelper.gaussianI(p.rt,avg,shape,relative_abundances_int))
            #---------------------------------------------
            
            
            #-------------mz wobble-----------------------
            y = p.int
            if y > 0.5
              wobble_int = 0.001086*y**(-0.5561)
            else
              wobble_int = 0.001
            end
            wobble_mz = Distribution::Normal.rng(mzmu,(wobble_int/2.0)).call
            if wobble_mz < 0
              wobble_mz = 0.01
            end
            p.mz = wobble_mz
            #---------------------------------------------
            
            
            #-------------M/Z Peak shape------------------
            fraction = RThelper.gaussian(p.mz,mzmu,0.05)
            factor = fraction/max_y
            p.int = p.int * factor
            #---------------------------------------------
            
            
            #-------------Jagged-ness---------------------
            sd = 0.1418 * p.int
            diff = (Distribution::Normal.rng(0,sd).call)
            p.int = p.int + diff
            #---------------------------------------------
            
            
            x += step

          end
	  
          index = index+1
          neutron = neutron+1.009
        end
	#  Filter for low intensities
        return fins.each {|fin| fin.delete_if {|p| p.int < 0.1}}
      end
    end
  end
end
