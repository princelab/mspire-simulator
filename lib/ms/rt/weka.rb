
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
        data<<pep.aa_counts
      end
      arff = make_rt_arff(Time.now.nsec.to_s,data)
      system("java -classpath ./bin/weka/weka.jar weka.classifiers.functions.MultilayerPerceptron -T #{arff} -l bin/weka/M5Rules.model -p 24 > #{arff}.out")
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
    
    
    
    def predict_ints(peptides)
      data = []
      peptides.each do |pep|
	array = []
	array<<pep.mono_mz<<pep.charge<<pep.mass<<pep.p_rt
        data << array.concat(pep.aa_counts)
      end
      arff = make_int_arff(Time.now.nsec.to_s,data)
      system("java -classpath ./bin/weka/weka.jar weka.classifiers.trees.M5P -T #{arff} -l bin/weka/M5P.model -p 27 > #{arff}.out")
      system("rm #{arff}")
      
      #extract what was predicted by weka model
      file = File.open("#{arff}.out","r")
      count = 0
      while line = file.gets
        if line =~ /(\d*\.\d{0,3}){1}/
          p_int = line.match(/(\d*\.\d{0,3}){1}/)[0].to_f
      case true
        when (0..1).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(0,69046)
        when (1..2).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(69046,126235)
        when (2..3).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(126235,397580)
        when (3..4).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(397580,760745)
        when (4..5).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(760745,1523150)
        when (5..6).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(1523150,3446050)
        when (6..7).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(3446050,5773600)
        when (7..8).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(5773600,7943750)
        when (8..9).member?(p_int)
          peptides[count].p_int = RThelper.RandomFloat(7943750,13183000)
        else
          peptides[count].p_int = RThelper.RandomFloat(13183000,15000000)
      end
          count += 1
        end
      end
      system("rm #{arff}.out")
      return peptides
    end
    
    
    
    #James Dalg
    def make_rt_arff(sourcefile, training)
      sourcefile<<".arff"
      File.open(sourcefile, "wb") do |f| # need to cite f.puts (not %Q)? if so http://www.devdaily.com/blog/post/ruby/how-write-text-to-file-ruby-example
        f.puts %Q{%
%
       @RELATION molecularinfo
       @ATTRIBUTE A    NUMERIC
       @ATTRIBUTE R    NUMERIC
       @ATTRIBUTE N    NUMERIC
       @ATTRIBUTE D    NUMERIC
       @ATTRIBUTE B    NUMERIC
       @ATTRIBUTE C    NUMERIC
       @ATTRIBUTE E    NUMERIC
       @ATTRIBUTE Q    NUMERIC
       @ATTRIBUTE Z    NUMERIC
       @ATTRIBUTE G    NUMERIC
       @ATTRIBUTE H    NUMERIC
       @ATTRIBUTE I    NUMERIC
       @ATTRIBUTE L    NUMERIC
       @ATTRIBUTE K    NUMERIC
       @ATTRIBUTE M    NUMERIC
       @ATTRIBUTE F    NUMERIC
       @ATTRIBUTE P    NUMERIC
       @ATTRIBUTE S    NUMERIC
       @ATTRIBUTE T    NUMERIC
       @ATTRIBUTE W    NUMERIC
       @ATTRIBUTE Y    NUMERIC
       @ATTRIBUTE V    NUMERIC
       @ATTRIBUTE J    NUMERIC
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
    
    
        #James Dalg
    def make_int_arff(sourcefile, training)
      sourcefile<<".arff"
      File.open(sourcefile, "wb") do |f| # need to cite f.puts (not %Q)? if so http://www.devdaily.com/blog/post/ruby/how-write-text-to-file-ruby-example
        f.puts %Q{%
%
       @RELATION molecularinfo
       @ATTRIBUTE mz   	NUMERIC
       @ATTRIBUTE charge   NUMERIC
       @ATTRIBUTE mass 	NUMERIC
       @ATTRIBUTE rt   NUMERIC
       @ATTRIBUTE A    NUMERIC
       @ATTRIBUTE R    NUMERIC
       @ATTRIBUTE N    NUMERIC
       @ATTRIBUTE D    NUMERIC
       @ATTRIBUTE B    NUMERIC
       @ATTRIBUTE C    NUMERIC
       @ATTRIBUTE E    NUMERIC
       @ATTRIBUTE Q    NUMERIC
       @ATTRIBUTE Z    NUMERIC
       @ATTRIBUTE G    NUMERIC
       @ATTRIBUTE H    NUMERIC
       @ATTRIBUTE I    NUMERIC
       @ATTRIBUTE L    NUMERIC
       @ATTRIBUTE K    NUMERIC
       @ATTRIBUTE M    NUMERIC
       @ATTRIBUTE F    NUMERIC
       @ATTRIBUTE P    NUMERIC
       @ATTRIBUTE S    NUMERIC
       @ATTRIBUTE T    NUMERIC
       @ATTRIBUTE W    NUMERIC
       @ATTRIBUTE Y    NUMERIC
       @ATTRIBUTE V    NUMERIC
       @ATTRIBUTE intensity  NUMERIC
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
