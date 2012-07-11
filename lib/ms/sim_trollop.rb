

module MS
  class Troll
    def initialize
      @opts = Trollop::options do
        version "ms-simulate 0.0.1a (c) 2012 Brigham Young University"
        banner <<-EOS
        
        *********************************************************************
         Description: Simulates ms runs given protein fasta files. Outputs
         a mzML file.
         
         
        Usage:
             ms-simulate [options] <filenames>+
             
        where [options] are:
        EOS
        opt :digestor, "Digestion Enzyme; one of: \n\t\targ_c,\n \t\tasp_n,
                                                  \n \t\tasp_n_ambic,
                                                  \n \t\tchymotrypsin,\n \t\tcnbr,
                                                  \n \t\tlys_c,\n \t\tlys_c_p,
                                                  \n \t\tpepsin_a,\n\t\ttryp_cnbr,
                                                  \n \t\ttryp_chymo,\n \t\ttrypsin_p,
                                                  \n \t\tv8_de,\n \t\tv8_e,
                                                  \n \t\ttrypsin,\n \t\tv8_e_trypsin,
                                                  \n\t\tv8_de_trypsin",
                                                   :default => "trypsin" 
        opt :sampling_rate, "How many scans per second", :default => 0.5 
        opt :run_time, "Run time in seconds", :default => 1000.0 
        opt :noise, "Noise on or off", :default => "true"
        opt :contaminate, "Contamination on or off", :default => "true"
        opt :noise_density, "Determines the density of white noise", :default => 10
        opt :pH, "The pH that the sample is in - for determining charge", :default => 2.6
        opt :out_file, "Name of the output file", :default => "test.mzml"
        opt :contaminants, "Fasta file containing contaminant sequences", :default => "testFiles/contam/hum_keratin.fasta"
        opt :dropout_percentage, "Defines the percentage of random dropouts in the run. 0.0 <= percentage < 1.0", :default => 0.12
        opt :shuffle, "Option shuffles the scans to simulate 1d data", :default => "false"
        opt :one_d, "Turns on one dimension simulation; run_time is automatically set to 300.0", :default => "false"
        opt :truth, "Determines truth file type; false gives no truth file; one of: xml or csv", :default => "false"
        opt :front, "Fronting chromatography parameter", :default => 6.65
        opt :tail, "Tailing chromatography parameter", :default => 0.30
        opt :wobA, "m/z wobble parameter", :default => 0.001071
        opt :wobB, "m/z wobble parameter", :default => -0.5430
        opt :wobMax, "maximum m/z wobble parameter", :default => 0.003
      end

      Trollop::die :sampling_rate, "must be greater than 0" if @opts[:sampling_rate] <= 0
      Trollop::die :run_time, "must be non-negative" if @opts[:run_time] < 0
      Trollop::die "must supply a .fasta protien sequence file" if ARGV.empty?
      Trollop::die :dropout_percentage, "must be between greater than or equal to 0.0 or less than 1.0" if @opts[:dropout_percentage] < 0.0 or @opts[:dropout_percentage] >= 1.0
    end
    
    def get; @opts; end
  end
end
