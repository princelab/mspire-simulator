# encoding: utf-8


require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "mspire-simulator"
  gem.homepage = "http://dl.dropbox.com/u/42836826/Ms_Sim_Homepage.html"
  gem.license = "MIT"
  gem.summary = %Q{Simulates MS1 runs given amino acid FASTA files. Outputs an MZML file.}
  gem.description = %Q{Simulates MS1 runs given amino acid FASTA files. Outputs an MZML file.
			Can simulate specific data if given an MZML file containing a single isolated peptide peak.}
  gem.email = "andrewbnoyce@gmail.com"
  gem.authors = ["anoyce"]
  
  gem.add_dependency "mspire", "0.8.2"
  gem.add_dependency "rubyvis", "= 0.5.2"
  gem.add_dependency "nokogiri", "= 1.5.2"
  gem.add_dependency "ffi", "= 1.0.11"
  gem.add_dependency "ffi-inliner", "= 0.2.4"
  gem.add_dependency "fftw3", "= 0.3"
  gem.add_dependency "distribution", "= 0.7.0"
  gem.add_dependency "pony", "= 1.4"
  gem.add_dependency "obo", "= 0.1.0"
  gem.add_dependency "trollop", "= 1.16.2"
  
  gem.executables = ["mspire-simulator"]
  gem.files.exclude "elution_curvefit.svg"
  gem.files.exclude "intensity_var_curvefit.svg"
  gem.files.exclude "lib/pool.rb"
  gem.files.exclude "mz_var_curvefit.svg"
  gem.files.exclude "single.mzML"
  gem.files.exclude "test.mzml"
  gem.files.exclude "test.mzml_truth.csv"
  gem.files.exclude "test.mzml_truth.xml"
  gem.files.exclude "testFiles/*"
  gem.files.include "bin/weka/M5P.model"
  gem.files.include "bin/weka/M5Rules.model"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec
