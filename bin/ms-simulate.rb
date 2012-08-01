#!/usr/bin/env ruby
$LOAD_PATH << './lib'

require 'time'
require 'progress'
require 'nokogiri'
require 'mspire/digester'
require 'mspire/tagged_peak'
require 'mspire'
require 'ms/sim_peptide'
require 'ms/rt/rtgenerator'
require 'ms/sim_spectra'
require 'ms/noise'
require 'ms/mzml_wrapper'
require 'trollop'
require 'ms/tr_file_writer'
require 'ms/isoelectric_calc'
require 'ms/sim_digester'
require 'ms/sim_trollop'
require 'ms/merger'

module MspireSimulator
  begin

  @start = Time.now
  @opts = MS::Troll.new.get

    one_d = @opts[:one_d]
    noise = @opts[:noise]
    truth = @opts[:truth]
    out_file = @opts[:out_file]
    email = @opts[:email]
    
    if one_d == "true"
      one_d = true
      run_time = 300.0
    else
      one_d = false
    end

    if @opts[:contaminate] == 'true'
      ARGV<<contaminants
    end
    
    module_function
    def opts; @opts end
    
    #------------------------Digest-----------------------------------------------
    peptides = []
    digester = MS::Sim_Digester.new(@opts[:digestor],@opts[:pH])
    ARGV.each do |file|
      peptides<<digester.digest(file)
    end
    peptides.flatten!.uniq!
    #-----------------------------------------------------------------------------



    #------------------------Create Spectrum--------------------------------------
    spectra = MS::Sim_Spectra.new(peptides, @opts[:sampling_rate], @opts[:run_time], @opts[:dropout_percentage], @opts[:noise_density], one_d)
    data = spectra.data
    
    if noise == 'true'
      noise = spectra.noiseify
    end
    #-----------------------------------------------------------------------------
    
    
    
    #------------------------Merge Overlaps---------------------------------------
    spectra.spectra = Merger.merge(spectra.spectra,@opts[:overlapRange].to_f)
    #-----------------------------------------------------------------------------
    
    
    
    #------------------------Truth Files------------------------------------------
    if truth != "false"
      if truth == "xml"
	MS::Txml_file_writer.write(spectra.features,spectra.spectra,out_file)
      elsif truth == "csv"
	MS::Tcsv_file_writer.write(spectra.spectra,data,noise,spectra.features,out_file)
      end
    end
    #-----------------------------------------------------------------------------
    
    
    #-----------------------Merge Finish------------------------------------------
    spectra.spectra = Merger.compact(spectra.spectra)
    #-----------------------------------------------------------------------------
    
    
    #-----------------------Clean UP----------------------------------------------
    spectra.features.each{|fe| fe.delete}
    peptides.clear
    #-----------------------------------------------------------------------------
    
    
    
    #-----------------------MZML--------------------------------------------------
    data = spectra.spectra
    mzml = Mzml_Wrapper.new(data)
    puts "Writing to file..."
    mzml.to_xml(out_file)
    puts "Done."
    #-----------------------------------------------------------------------------



  rescue Exception => e  #Clean up if exception 
    puts e.message  
    puts e.backtrace 
    if digester != nil
      if File.exists?(digester.digested_file)
	File.delete(digester.digested_file)
      end
    end
    if spectra != nil
    spectra.features.each{|fe| fe.delete}
    end
    if !peptides.empty?
      peptides.each{|pep| pep.delete}
    end
    puts "Exception - Simulation Failed"
    
    system "ruby bin/sim_mail.rb #{email} Exception - Simulation Failed" if email != "nil"
  else
    system "ruby bin/sim_mail.rb #{email} Success! - Simulation Complete" if email != "nil"
  end
end
