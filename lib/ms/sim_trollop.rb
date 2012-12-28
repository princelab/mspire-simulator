require 'ms/curvefit'

module MS
  class Troll
    def initialize
      @opts = Trollop::options do
        version "mspire-simulator 0.0.1a (c) 2012 Brigham Young University"
        banner <<-EOS

        *********************************************************************
         Description: Simulates ms runs given protein fasta files. Outputs
         a mzML file.


        Usage:
             mspire-simulator [options] <filenames>+

        where [options] are:
        EOS
        opt :digestor, "Digestion Enzyme; one of: \n\t\targ_c,\n \t\tasp_n,
    asp_n_ambic,
                chymotrypsin,\n \t\tcnbr,
                lys_c,\n \t\tlys_c_p,
                pepsin_a,\n\t\ttryp_cnbr,
                tryp_chymo,\n \t\ttrypsin_p,
                v8_de,\n \t\tv8_e,
                trypsin,\n \t\tv8_e_trypsin,
                v8_de_trypsin",
                :default => "trypsin" 
                opt :missed_cleavages, "Number of missed cleavages during digestion", :default => 2
                opt :sampling_rate, "How many scans per second", :default => 0.5 
                opt :run_time, "Run time in seconds", :default => 1000.0 
                opt :noise, "Noise on or off", :default => "true"
                opt :noise_density, "Determines the density of white noise", :default => 10
                opt :noiseMaxInt, "The max noise intensity level", :default => 1000
                opt :noiseMinInt, "The minimum noise intensity level", :default => 50
                opt :pH, "The pH that the sample is in - for determining charge", :default => 2.6
                opt :out_file, "Name of the output file", :default => "test.mzml"
                opt :contaminants, "Fasta file containing contaminant sequences", :default => "testFiles/contam/hum_keratin.fasta"
                opt :dropout_percentage, "Defines the percentage of random dropouts in the run. 0.0 <= percentage < 1.0", :default => 0.01
                opt :shuffle, "Option shuffles the scans to simulate 1d data", :default => "false"
                opt :one_d, "Turns on one dimension simulation; run_time is automatically set to 300.0", :default => "false"
                opt :truth, "Determines truth file type; false gives no truth file; one of: 'xml' or 'csv' or 'xml_csv' (for both)", :default => "csv"
                opt :front, "Fronting chromatography parameter", :default => 6.65
                opt :tail, "Tailing chromatography parameter", :default => 0.30
                opt :mu, "Expected value of the chromatography curve", :default => 25.0
                opt :wobA, "m/z wobble parameter", :default => 0.001071
                opt :wobB, "m/z wobble parameter", :default => -0.5430
                opt :jagA, "intensity variance parameter", :default => 10.34
                opt :jagC, "intensity variance parameter", :default => 0.00712
                opt :jagB, "intensity variance parameter", :default => 0.12
                opt :overlapRange, "range in which to determine overlapping peaks", :default => 1.0724699230489427
                opt :email, "Email address to send completion messages to", :default => "nil"
                opt :mzml, "Mzml file to extract simulation parameters from", :default => "nil"
                opt :generations, "If an mzml file is provided this specifies the number of generations for the curve fitting algorithm", :default => 30000
                opt :mass_label, "Specify a mass tag pattern", :default => 0
                opt :ms2s, "Number of peptide ms2s to perform on each scan", :default => 1
                opt :ms2, "Turn on/off ms2 (true == on)", :default => "true"
                opt :databaseName, "Name of database file", :default => "peptides_[Time.now.sec]"
                opt :memory, "Determines whether to store the database in memory or write to file (false == write to file) Note: if true no database file will be accessible after simulation", :default => "false"
                opt :modifications, "To define residue or termini modifications. Enter a string Id1R1_Id2R2_ ... 
                                    where Idi is a modification Id from http://psidev.cvs.sourceforge.net/viewvc/psidev/psi/mod/data/PSI-MOD.obo 
                                    and Ri is the residue/terminus to apply it to (c-term = CT, n-term = NT). Place a lowercase 'v' after the residue if variable.
                                    (e.g. MOD:00412Mv - oxidation on Methionine, variable)", :default => "false"

      end

      if @opts[:mzml] != "nil"
        @opts = CurveFit.get_parameters(@opts)
      end
      Trollop::die :sampling_rate, "must be greater than 0" if @opts[:sampling_rate] <= 0
      Trollop::die :run_time, "must be non-negative" if @opts[:run_time] < 0
      Trollop::die "must supply a .fasta protein sequence file" if ARGV.empty?
      Trollop::die :dropout_percentage, "must be between greater than or equal to 0.0 or less than 1.0" if @opts[:dropout_percentage] < 0.0 or @opts[:dropout_percentage] >= 1.0
      @opts[:overlapRange] = (@opts[:overlapRange]*10.0**-6)/2.0
    end

    def get; @opts; end
  end
end
