trails = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
Shoes.app :width => 550, :height => 300, :title => "ms-simulate" do
  background gradient(white,gray)
  @filename = "No file chosen."

    @links = stack :margin => 2, :width => 200, :height => 300 do
      caption "ms-simulate"
      para link("Choose a Digestor") {@disp.replace(@d)} 
      para link("Sampling rate") {@disp.replace(@s)}
      para link("Run time") {@disp.replace(@r)}
      para link("Noise") {@disp.replace(@n)}
      para link("Contaminate") {@disp.replace(@c)}
      @disp = stack :margin => 10 do
        para "Select Above Option"
      end
      @p1 = para "#{@filename}"
    end

  @top = flow :width => 200, :height => 300 do
    @i = image "ani/peaks1.png"
    @i.width = 200
  end

  @hid = flow :width => 350, :height => 300 do
    stack do 
      @d = stack :margin => 10 do
        @digestor = list_box :items => ["arg_c",
          "asp_n",
          "asp_n_ambic",
          "chymotrypsin",
          "cnbr",
          "lys_c",
          "lys_c_p",
          "pepsin_a",
          "tryp_cnbr",
          "tryp_chymo",
          "trypsin_p",
          "v8_de",
          "v8_e",
          "trypsin",
          "v8_e_trypsin",
          "v8_de_trypsin"],
        :choose => "trypsin"
      end
      
      @s = stack :margin => 10 do
        #para "Sampling rate:"
        @s_per_sec = edit_line :text => "1"
      end
      
      @r = stack :margin => 10 do
        #para "Run time:"
        @run_time = edit_line :text => "3000"
      end
      
      @n = stack :margin => 10 do
        #para "Noise?"
        @noise = list_box :items => ["true","false"],
        :choose => "true"
      end
      
      @nd = stack :margin => 10 do
        #para "Noise Density:"
        @noise = edit_line :text => "20"
      end
      
      @c = stack :margin => 10 do
        #para "Contaminate?"
        @noise = list_box :items => ["true","false"],
        :choose => "true"
      end
    end
    
    stack :margin => 10 do
        @b1 = button "Choose Fasta File" do
          @filename = ask_open_file 
          @p1.replace(@filename)
        end
      end
      
    stack :margin => 10 do
      button "Run Simulation" do
        system "ruby -I lib bin/ms-simulate.rb -d #{@digestor.text} -s #{@s_per_sec.text} -r #{@run_time.text} #{@filename}"
      end
    end
    
  end
  @hid.hide

  @top.animate(24) do 
      trails << trails.shift
        @i.path = "ani/peaks#{trails[0]}.png"
        
    end

end
