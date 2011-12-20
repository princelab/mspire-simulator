
module MS
  module Feature
    module Isotopes
      ISOTOPES_STR = {
        'c' => { :c12 =>0.9893, :c13 =>0.0107 },
        'o' => { :o16 =>0.99757, :o17 =>(3.8*10**-4) , :o18 =>(2.05*10**-3) },
        'n' => { :n14 =>0.99636, :n15 =>0.00364 },
        'h' => { :h1 =>0.999885, :h2 =>0.000115 },
        's' => { :s32 =>0.9493, :s33 =>0.0076 , :s34 =>0.0429 , :s36 =>(2*10**-4) },
        'p' => { :p31 =>1.0 },
        'se' => { :se74 =>0.0089, :se76 =>0.0937 , :se77 =>0.0763 , :se78 =>0.2377 , :se80 =>0.4961 , :se82 =>0.0873 }
      }
      ISOTOPES_SYM = {
        :c => { :c12 =>0.9893, :c13 =>0.0107 },
        :o => { :o16 =>0.99757, :o17 =>(3.8*10**-4) , :o18 =>(2.05*10**-3) },
        :n => { :n14 =>0.99636, :n15 =>0.00364 },
        :h => { :h1 =>0.999885, :h2 =>0.000115 },
        :s => { :s32 =>0.9493, :s33 =>0.0076 , :s34 =>0.0429 , :s36 =>(2*10**-4) },
        :p => { :p31 =>1.0 },
        :se => { :se74 =>0.0089, :se76 =>0.0937 , :se77 =>0.0763 , :se78 =>0.2377 , :se80 =>0.4961 , :se82 =>0.0873 }
      }
      ISOTOPES_STR.each {|aa,val| ISOTOPES_SYM[aa.to_sym] = val }

      # string and symbol access of isotope fractions (atoms and isotopes are all lower case
      # symbols)
      ISOTOPES = ISOTOPES_SYM.merge ISOTOPES_STR
    end
  end
end
