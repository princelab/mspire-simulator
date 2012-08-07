
require 'time'
require 'mspire'
require 'ms/sim_spectra'
require 'ms/sim_peptide'
require 'ms/merger'

describe MS::Txml_file_writer do
  before(:all) do
    peptides = []
    peptides<<MS::Peptide.new("ANDY",1)
    peptides<<MS::Peptide.new("PRINCE",2)
    peptides<<MS::Peptide.new("PEPTIDE",3)
    one_d = false
    opts = {:sampling_rate => 1.0, :run_time => 5000.0,
            :dropout_percentage => 0, :noise_density => 20,
            :jagA => 10.34, :jagC => 0.00712, :jagB => 0.12,
            :wobA => 0.001071, :wobB => -0.5430, :mu => 25.0}
    @spectra = MS::Sim_Spectra.new(peptides,opts,one_d)
    @features = @spectra.features
    @file_name = Time.now.to_s
  end
  
  after(:all) do
    File.delete("#{@file_name}_truth.xml")
  end
  
  it "#write Writes an XML file that includes all information for the spectra" do
    xml = MS::Txml_file_writer.write(@features,@spectra.spectra,@file_name)
    File.exist?("#{@file_name}_truth.xml").should == true
    file = File.open("#{@file_name}_truth.xml","r")
    pep_verify = []
    file.each_line{|line| if line =~ /ANDY|PRINCE|PEPTIDE/; pep_verify<<true; end;}
    pep_verify.should have(3).Boolean
    pep_verify.each do |ver|
      ver.should == true
    end
  end
end


describe MS::Tcsv_file_writer do
  before(:all) do
    peptides = []
    peptides<<MS::Peptide.new("ANDY",1)
    peptides<<MS::Peptide.new("PRINCE",2)
    peptides<<MS::Peptide.new("PEPTIDE",3)
    one_d = false
    opts = {:sampling_rate => 1.0, :run_time => 5000.0,
            :dropout_percentage => 0, :noise_density => 20,
            :jagA => 10.34, :jagC => 0.00712, :jagB => 0.12,
            :wobA => 0.001071, :wobB => -0.5430, :mu => 25.0}
    @spectra = MS::Sim_Spectra.new(peptides,opts,one_d)
    @noise = @spectra.noiseify
    @features = @spectra.features
    @file_name = Time.now.to_s 
  end
  
  after(:all) do
    File.delete("#{@file_name}_truth.csv")
  end
  
  it "#write Writes an CSV file that includes all information for the spectra" do
    csv = MS::Tcsv_file_writer.write(@spectra.spectra,@spectra.data,@noise,@features,@file_name)
    r_times = MS::Sim_Spectra.r_times
    times_ver = []
    File.exist?("#{@file_name}_truth.csv").should == true
    file = File.open("#{@file_name}_truth.csv","r")
    file.each_line do |line| 
      next if line =~ /rt/
      r_times.include?(line.chomp.split(/,/)[0].to_f).should == true
    end
  end
end
