
module MS
  module Feature
    module AA
      ATOM_COUNTS_STR = {
        'A' => { :c =>3, :h =>7 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'R' => { :c =>6, :h =>14 , :o =>2 , :n =>4 , :s =>0 , :p =>0, :se =>0 },
        'N' => { :c =>4, :h =>8 , :o =>3 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        'D' => { :c =>4, :h =>7 , :o =>4 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'C' => { :c =>3, :h =>7 , :o =>2 , :n =>1 , :s =>1 , :p =>0, :se =>0 },
        'E' => { :c =>5, :h =>9 , :o =>4 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'Q' => { :c =>5, :h =>10 , :o =>3 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        'G' => { :c =>2, :h =>5 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'H' => { :c =>6, :h =>9 , :o =>2 , :n =>3 , :s =>0 , :p =>0, :se =>0 },
        'I' => { :c =>6, :h =>13 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'L' => { :c =>6, :h =>13 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'K' => { :c =>6, :h =>14 , :o =>2 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        'M' => { :c =>5, :h =>11 , :o =>2 , :n =>1 , :s =>1 , :p =>0, :se =>0 },
        'F' => { :c =>9, :h =>11 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'P' => { :c =>5, :h =>9 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'S' => { :c =>3, :h =>7 , :o =>3 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'T' => { :c =>4, :h =>9 , :o =>3 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'W' => { :c =>11, :h =>12 , :o =>2 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        'Y' => { :c =>9, :h =>11 , :o =>3 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'V' => { :c =>5, :h =>11 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        'U' => { :c =>3, :h =>7 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>1 },
        'O' => { :c =>12, :h =>21 , :o =>3 , :n =>3 , :s =>0 , :p =>0, :se =>0 }
      }
      ATOM_COUNTS_SYM = {
        :A => { :c =>3, :h =>7 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :R => { :c =>6, :h =>14 , :o =>2 , :n =>4 , :s =>0 , :p =>0, :se =>0 },
        :N => { :c =>4, :h =>8 , :o =>3 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        :D => { :c =>4, :h =>7 , :o =>4 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :C => { :c =>3, :h =>7 , :o =>2 , :n =>1 , :s =>1 , :p =>0, :se =>0 },
        :E => { :c =>5, :h =>9 , :o =>4 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :Q => { :c =>5, :h =>10 , :o =>3 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        :G => { :c =>2, :h =>5 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :H => { :c =>6, :h =>9 , :o =>2 , :n =>3 , :s =>0 , :p =>0, :se =>0 },
        :I => { :c =>6, :h =>13 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :L => { :c =>6, :h =>13 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :K => { :c =>6, :h =>14 , :o =>2 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        :M => { :c =>5, :h =>11 , :o =>2 , :n =>1 , :s =>1 , :p =>0, :se =>0 },
        :F => { :c =>9, :h =>11 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :P => { :c =>5, :h =>9 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :S => { :c =>3, :h =>7 , :o =>3 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :T => { :c =>4, :h =>9 , :o =>3 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :W => { :c =>11, :h =>12 , :o =>2 , :n =>2 , :s =>0 , :p =>0, :se =>0 },
        :Y => { :c =>9, :h =>11 , :o =>3 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :V => { :c =>5, :h =>11 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>0 },
        :U => { :c =>3, :h =>7 , :o =>2 , :n =>1 , :s =>0 , :p =>0, :se =>1 },
        :O => { :c =>12, :h =>21 , :o =>3 , :n =>3 , :s =>0 , :p =>0, :se =>0 }
      }
      ATOM_COUNTS_STR.each {|aa,val| ATOM_COUNTS_SYM[aa.to_sym] = val }

      # string and symbol access of amino acid (atoms are all lower case
      # symbols)
      ATOM_COUNTS = ATOM_COUNTS_SYM.merge ATOM_COUNTS_STR
      
      #James Dalg
      #assumes pH of 2, which is not perfect,
      #source http://www.sigmaaldrich.com/life-science/metabolomics/
      #learning-center/amino-acid-reference-chart.html#hydro
      #no well established hydrophobic values exist for 
      #selenomethionine, selenocysteine, or pyrrolysine
      #B = averaged D and N
      #X = unknowns given a neutral value of 0, the same as G
      #Z = averaged E and Q
      HYDROPHOBICTY = { 
         "*"=>0,"A"=>47.0,"B"=>-29.5,"C"=>52.0,"D"=>-18.0,"E"=>8.0,
         "F"=>92.0,"G"=>0.0,"H"=>-42.0,"I"=>100,"K"=>-37.0,"L"=>100.0,
         "M"=>74.0,"N"=>-41.0,"O"=>100.0,"P"=>-46.0,"Q"=>-18.0,
         "R"=>-26.0,"S"=>-7.0,"T"=>13.0,"U"=>150.0379,"V"=>79.0,
         "W"=>84.0,"X"=>0,"Y"=>49.0,"Z"=>-5.0 
       }
      
      #James Dalg 
      #assumes pH of 2, which is not perfect,
      #source http://www.imb-jena.de/IMAGE_AA.html
      #B = averaged D and N
      #X = average of all residues
      #Z = averaged E and Q
       PIHASH = { 
        "*"=>0,"B"=>4.195,"X"=>5.21685,"Z"=>-5.0,"A"=>6.107,"R"=>10.76,
        "D"=>2.98,"N"=>-0,"C"=>5.02,"E"=>3.08,"Q"=>-0,"G"=>6.064,
        "H"=>7.64,"I"=>6.038,"L"=>6.036,"K"=>9.47,"M"=>5.74,"F"=>5.91,
        "P"=>6.3,"S"=>5.68,"T"=>-0,"W"=>5.88,"Y"=>5.63,"V"=>6.002
      }
      
    end
  end
end
