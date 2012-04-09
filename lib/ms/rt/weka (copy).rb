
require 'csv'

module MS
  module Weka
  #James Dalg
    module_function
    def predict_rts(peptides)
      #mz,charge,intensity,rt,A,R,N,D,B,C,E,Q,Z,G,H,I,L,K,M,F,P,S,T,W,Y,V,J,mass,hydro,pi
      #make arrf file to feed weka model
      data = []
      peptides.each do |pep|
        data<<[pep.mono_mz,pep.charge,0,0,
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
      system("java -classpath ./bin/weka/weka.jar weka.classifiers.rules.M5Rules -c 4 -T #{arff} -l bin/weka/M5Rules.model -p 0 > #{arff}.out")
      system("rm #{arff}")
      
      #extract what was predicted by weka model
      file = File.open("#{arff}.out","r")
      count = 0
      while line = file.gets
        if line =~ /(\d*\.\d{0,3}){1}/
          peptides[count].p_rt = line.match(/(\d*\.\d{0,3}){1}/)[0].to_f
          count += 1
        end
      end
      system("rm #{arff}.out")
      return peptides
    end
    
    #James Dalg
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
