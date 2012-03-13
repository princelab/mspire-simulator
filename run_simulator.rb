trails = [[0, 0]] * 60
Shoes.app :width => 550, :height => 300, :title => "ms-simulate" do

  @filename = "No file chosen."

    @links = stack :margin => 2, :width => 200, :height => 300 do
      background gradient(white,gray)
      caption "ms-simulate"
      para link("Choose a Digestor") {@d.show; @s.hide; @r.hide; @n.hide; @nd.hide; @c.hide} 
      para link("Sampling rate") {@d.hide; @s.show; @r.hide; @n.hide; @nd.hide; @c.hide}
      para link("Run time") {@d.hide; @s.hide; @r.show; @n.hide; @nd.hide; @c.hide}
      para link("Noise") {@d.hide; @s.hide; @r.hide; @n.show; @nd.show; @c.hide}
      para link("Contaminate") {@d.hide; @s.hide; @r.hide; @n.hide; @nd.hide; @c.show}
      stack :margin => 10 do
        @p1 = para "#{@filename}"
      end
    end


  @top = flow :width => 350, :height => 300 do
  
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
    
    @d.hide; @s.hide; @r.hide; @n.hide; @nd.hide; @c.hide
    
  end

  @top.animate(10) do 
      trails.shift
      trails << self.mouse[1, 2]

        # change the background based on where the pointer is
        @top.background gradient(white,rgb(
          20 + (70 * (trails.last[0].to_f / self.width)).to_i, 
          20 + (70 * (trails.last[1].to_f / self.height)).to_i,
          51))
        
    end

end
