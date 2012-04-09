
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
        data<<[pep.hydro,0.0]
      end
      arff = makeArff(Time.now.nsec.to_s,data)
      system("java -classpath ./bin/weka/weka.jar weka.classifiers.functions.MultilayerPerceptron -T #{arff} -l bin/weka/M5Rules_hy_only.model -p 2 > #{arff}.out")
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
       @ATTRIBUTE hy    NUMERIC
       @ATTRIBUTE rt    NUMERIC
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
