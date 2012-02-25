
require 'time'
require 'csv'
require 'ms/feature/feature'
require 'ms/peptide'
require 'ms/rt/rt_helper'

module MS
  class Rtgenerator
    
    def generateRT(peptides, r_time,run_time)
      @start = Time.now
      new_peptides = []
      @r_time = r_time
      @run_time = run_time
      
      peptides.delete_if{|pep| pep.charge == 0}
      
      #mz,charge,intensity,rt,A,R,N,D,B,C,E,Q,Z,G,H,I,L,K,M,F,P,S,T,W,Y,V,J,mass,hydro,pi
      data = []
      peptides.each do |pep|
        data<<[pep.mz,pep.charge,pep.int,pep.rt,
        pep.sequence.count("A"),
        pep.sequence.count("R"),
        pep.sequence.count("N"),
        pep.sequence.count("D"),
        pep.sequence.count("B"),
        pep.sequence.count("C"),
        pep.sequence.count("E"),
        pep.sequence.count("Q"),
        pep.sequence.count("Z"),
        pep.sequence.count("G"),
        pep.sequence.count("H"),
        pep.sequence.count("I"),
        pep.sequence.count("L"),
        pep.sequence.count("K"),
        pep.sequence.count("M"),
        pep.sequence.count("F"),
        pep.sequence.count("P"),
        pep.sequence.count("S"),
        pep.sequence.count("T"),
        pep.sequence.count("W"),
        pep.sequence.count("Y"),
        pep.sequence.count("V"),
        pep.sequence.count("J"),
        pep.mass,pep.hydro,pep.pi]
      end
      arff = makeArff(Time.now.nsec.to_s,data)
      system("java -classpath ./weka.jar weka.classifiers.rules.M5Rules -c 4 -T #{arff} -l j48.model -p 0 > #{arff}.out")
      system("rm #{arff}")
      file = File.open("#{arff}.out","r")
      count = 0
      while line = file.gets
        if line =~ /(\d*\.\d{0,3}){1}/
          peptides[count].rt = line.match(/(\d*\.\d{0,3}){1}/)[0].to_f
          count += 1
        end
      end
      system("rm #{arff}.out")
    
      peptides.each_with_index do |pep,ind|
        Progress.progress("Generating peptides:",(((ind+1)/peptides.size.to_f)*100).to_i)
        peps = Array.new
        
        #multiply peptides
        @r_time.length.times do
          peps<<MS::Peptide.new(pep.sequence,pep.rt)
        end
  
        #predict rts and spread them by a normal density func.
        avg_rt = getRTs(peps)
        
        #eliminate redundant rts in pep
        peps.uniq!{|pep| pep.rt}
        
        new_peptides<<[peps,avg_rt]
      end
      new_peptides.delete_if{|pep_group| pep_group[1] == 1}
      Progress.progress("Generating peptides:",100,Time.now-@start)
      puts ""
      if new_peptides.empty?
        puts "None predicted in time range: try increasing run time."
        abort
      end
      return new_peptides
    end
    
    # Gets retention times from the weka model
    #
    def getRTs(peps)
        
      avg_rt = 0.0
      rtmu = peps[0].rt
    
      peps.each do |pep|
        spreadRTs(pep,rtmu)
        if(pep.rt == nil)
          pep.rt = 1
        end
        avg_rt = avg_rt+pep.rt
      end
      
      avg_rt = avg_rt/(peps.length)
      return avg_rt
    end
    
    # Spreading peaks by a normal density function.
    # This may not be the correct thing to do.
    #
    def spreadRTs(pep,mu)
      pep.rt = Distribution::Normal.rng(mu,80).call
      pep.rt = @r_time.find {|i| i >= pep.rt}
    end
    
    def makeArff(sourcefile, training)
      sourcefile<<".arff"
      File.open(sourcefile, "wb") do |f| # need to cite f.puts (not %Q)? if so http://www.devdaily.com/blog/post/ruby/how-write-text-to-file-ruby-example
        f.puts %Q{%
%
       @RELATION molecularinfo
       @ATTRIBUTE mz   real
       @ATTRIBUTE charge   real
       @ATTRIBUTE intensity  real
       @ATTRIBUTE rt   real
       @ATTRIBUTE A    real
       @ATTRIBUTE R    real
       @ATTRIBUTE N    real
       @ATTRIBUTE D    real
       @ATTRIBUTE B    real
       @ATTRIBUTE C    real
       @ATTRIBUTE E    real
       @ATTRIBUTE Q    real
       @ATTRIBUTE Z    real
       @ATTRIBUTE G    real
       @ATTRIBUTE H    real
       @ATTRIBUTE I    real
       @ATTRIBUTE L    real
       @ATTRIBUTE K    real
       @ATTRIBUTE M    real
       @ATTRIBUTE F    real
       @ATTRIBUTE P    real
       @ATTRIBUTE S    real
       @ATTRIBUTE T    real
       @ATTRIBUTE W    real
       @ATTRIBUTE Y    real
       @ATTRIBUTE V    real
       @ATTRIBUTE J    real
       @ATTRIBUTE AVMASS    real
       @ATTRIBUTE AVHYDRO    real
       @ATTRIBUTE AVPI    real
       @DATA
%
%      }
      end
      training.each do |innerarray|
        CSV.open(sourcefile, "a") do |csv| #derived from sample code http://www.ruby-doc.org/stdlib-1.9.3/libdoc/csv/rdoc/CSV.html
          csv << innerarray #idea may be slightly attributable to http://www.ruby-forum.com/topic/299571
        end
      end
      return sourcefile
    end
  end
end
