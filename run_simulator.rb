trails = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
Shoes.app :width => 620, :height => 400, :title => "ms-simulate" do
  background gradient(white,gray)
  @filename = "No file chosen."

    @links = stack :margin => 2, :width => 200 do
      caption "ms-simulate"
      para link("Choose a Digestor") {@d.show;@s.hide;@r.hide;@n.hide;@nd.hide;@c.hide} 
      para link("Sampling rate") {@d.hide;@s.show;@r.hide;@n.hide;@nd.hide;@c.hide}
      para link("Run time") {@d.hide;@s.hide;@r.show;@n.hide;@nd.hide;@c.hide}
      para link("Noise/Noise Density") {@d.hide;@s.hide;@r.hide;@n.show;@nd.show;@c.hide}
      para link("Contaminate") {@d.hide;@s.hide;@r.hide;@n.hide;@nd.hide;@c.show}
    end

  @hid = flow :width => 300, :top => 30 do
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
        @noised = edit_line :text => "20"
      end
      
      @c = stack :margin => 10 do
        #para "Contaminate?"
        @contaminate = list_box :items => ["true","false"],
        :choose => "true"
      end
    end
    
  end
  @d.hide;@s.hide;@r.hide;@n.hide;@nd.hide;@c.hide
  
  stack :margin => 10, :width => 200 do
    @disp = para "Run through the Options above first"
    @p1 = para "#{@filename}"
  end
  
  stack :margin => 10, :width => 200 do
    @b1 = button "Choose Fasta File" do
      @filename = ask_open_file 
      @p1.replace(@filename)
    end
  end
    
  stack :margin => 10, :width => 200 do
    button "Run Simulation" do
      if @filename == "No file chosen." or @filename == ""
        alert("No file chosen")
      else
        if @digestor.text == nil or @s_per_sec.text == nil or @run_time.text == nil or @noise.text == nil or @noised.text == nil or @contaminate.text == nil
          alert("Please initialize all options before running")
        else
          out = system "ruby -I lib bin/ms-simulate.rb -d #{@digestor.text} -s #{@s_per_sec.text} -r #{@run_time.text} -n #{@noise.text} -o #{@noised.text} -c #{@contaminate.text} #{@filename}"
          if out == false
            alert("Something went wrong, look at your parameters again")
          else
            alert("Run is finished!")
          end
        end
      end
    end
  end
  
   @top = flow :width => 100 do
    @i = image "ani/peaks1.png"
    @i.width = 100
  end

  @top.animate(2) do 
      trails << trails.shift
        @i.path = "ani/peaks#{trails[0]}.png"
        
    end

end
