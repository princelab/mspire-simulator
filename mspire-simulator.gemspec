# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'mspire/simulator/version'

prep = lambda {|arg| arg.split(" ",2).compact }

Gem::Specification.new do |spec|
  spec.name          = "mspire-simulator"
  spec.version       = Mspire::Simulator::VERSION
  spec.authors       = ["Andrew Noyce, John Prince"]
  spec.email         = ["jtprince@gmail.com"]
  spec.description   = %q{Simulates MS1 runs given amino acid FASTA files. Outputs an MZML file.  Can simulate specific data if given an MZML file containing a single isolated peptide peak.}
  spec.summary       = %q{Simulates MS1 runs given amino acid FASTA files. Outputs an MZML file.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  [
    "mspire = 0.8.7",
    "rubyvis = 0.5.2",
    "nokogiri ~> 1.5.9",
    "ffi = 1.0.11",
    "ffi-inliner = 0.2.4",
    "fftw3 = 0.3",
    "distribution = 0.7.0",
    "pony = 1.4",
    "obo = 0.1.3",
    "trollop = 2.0",
    "MS-fragmenter = 0.0.2",
    "sqlite3 = 1.3.6",
  ].each do |arg|
    spec.add_dependency *prep.call(arg)
  end
  [
    "bundler ~> 1.3",
    "rake",
    "rspec ~> 2.13.0", 
    "rdoc ~> 3.12", 
    "simplecov",
  ].each do |arg|
    spec.add_development_dependency *prep.call(arg)
  end
end
