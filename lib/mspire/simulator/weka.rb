
require 'csv'

module Mspire
  module Weka
    WEKA_MODEL_DIR = File.expand_path(File.dirname(__FILE__) + "/weka")

    #James Dalg
    module_function
    def predict_rts(db, opts)
      #mz,charge,intensity,rt,A,R,N,D,B,C,E,Q,Z,G,H,I,L,K,M,F,P,S,T,W,Y,V,J,mass,hydro,pi
      #make arrf file to feed weka model
      data = []
      rs = db.execute "SELECT * FROM aac"
      rs.each do |row|
        row.delete_at(0)
        data<<row
      end

      arff = make_rt_arff(Time.now.nsec.to_s,data)

      weka_jar_cp_opt = opts[:weka_jar] ? "-cp #{opts[:weka_jar]}" : nil
      cmd = "java #{weka_jar_cp_opt} weka.classifiers.functions.MultilayerPerceptron -T #{arff} -l #{WEKA_MODEL_DIR}/M5Rules.model -p 24 > #{arff}.out"
      system cmd
      system("rm #{arff}")

      #extract what was predicted by weka model
      file = File.open("#{arff}.out","r")
      count = 0
      while line = file.gets
        if line =~ /(\d*\.\d{0,3}){1}/
          p_rt = line.match(/(\d*\.\d{0,3}){1}/)[0].to_f
          db.execute "UPDATE peptides SET p_rt=#{p_rt} WHERE Id='#{count}'"
          count += 1
        end
      end
      system("rm #{arff}.out")
    end



    def predict_ints(db, opts)
      data = []
      aas = "A,R,N,D,B,C,E,Q,Z,G,H,I,L,K,M,F,P,S,T,W,Y,V,J,place_holder"
      rs = db.execute "SELECT mono_mz, charge, mass, p_rt,#{aas} FROM peptides NATURAL JOIN aac" #JOIN aac
      rs.each do |row|
        data<<row
      end

      arff = make_int_arff(Time.now.nsec.to_s,data)

      weka_jar_cp_opt = opts[:weka_jar] ? "-cp #{opts[:weka_jar]}" : nil
      cmd = "java #{weka_jar_cp_opt} weka.classifiers.trees.M5P -T #{arff} -l #{WEKA_MODEL_DIR}/M5P.model -p 27 > #{arff}.out"
      system cmd
      system("rm #{arff}")

      #extract what was predicted by weka model
      file = File.open("#{arff}.out","r")
      count = 0
      while line = file.gets
        if line =~ /(\d*\.\d{0,3}){1}/
          p_int = line.match(/(\d*\.\d{0,3}){1}/)[0].to_f
          db.execute "UPDATE peptides SET p_int=#{p_int} WHERE Id='#{count}'"
          count += 1
        end
      end
      system("rm #{arff}.out")
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
