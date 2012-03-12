Shoes.app :width => 320, :height => 420 do
  #background "sim.png"

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
      button "Choose Fasta File" do
	@filename = ask_open_file 
	para "#{@filename}"
      end
    end
    
    stack :margin => 10 do
      button "Run Simulation" do
        system "ruby -I lib bin/ms-simulate.rb -d #{@digestor.text} -s #{@s_per_sec.text} -r #{@run_time.text} #{@filename}"
      end
    end
  end
end
