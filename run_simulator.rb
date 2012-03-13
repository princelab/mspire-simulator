trails = [[0, 0]] * 60
Shoes.app :width => 320, :height => 700, :title => "ms-simulate" do

  background do
    
    animate(60) do
      trails.shift
      trails << self.mouse[1, 2]

      clear do
        # change the background based on where the pointer is
        background rgb(
          20 + (70 * (trails.last[0].to_f / self.width)).to_i, 
          20 + (70 * (trails.last[1].to_f / self.height)).to_i,
          51)

        # draw circles progressively bigger
        trails.each_with_index do |(x, y), i|
          i += 1
          oval :left => x, :top => y, :radius => (i*0.5), :center => true
        end
      end
    end
  end


  @filename = "No file chosen."

  stack :margin => 40 do
    stack :margin => 10 do
      para "Choose a Digestor"
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
    
    stack :margin => 10 do
      para "Sampling rate:"
      @s_per_sec = edit_line :text => "1"
    end
    
    stack :margin => 10 do
      para "Run time:"
      @run_time = edit_line :text => "3000"
    end
    
    stack :margin => 10 do
      para "Noise?"
      @noise = list_box :items => ["true","false"],
	:choose => "true"
    end
    
    stack :margin => 10 do
      para "Noise Density:"
      @noise = edit_line :text => "20"
    end
    
    stack :margin => 10 do
      para "Contaminate?"
      @noise = list_box :items => ["true","false"],
	:choose => "true"
    end
    
    stack :margin => 10 do
      @b1 = button "Choose Fasta File" do
      @filename = ask_open_file 
      @b1.click(@p1.replace(@filename))
      end
    end
    
    stack :margin => 10 do
      @p1 = para "#{@filename}"
    end
    
    stack :margin => 10 do
      button "Run Simulation" do
        system "ruby -I lib bin/ms-simulate.rb -d #{@digestor.text} -s #{@s_per_sec.text} -r #{@run_time.text} #{@filename}"
      end
    end
  end
end
