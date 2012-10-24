$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

  config.before(:all) do 
    system("mkdir .m .i")
    system("mkdir .m/A .m/R .m/N .m/D .m/C .m/E .m/Q .m/G .m/H .m/I .m/L .m/K .m/M .m/F .m/P .m/S .m/T .m/W .m/Y .m/V .m/U .m/O")
    system("mkdir .i/A .i/R .i/N .i/D .i/C .i/E .i/Q .i/G .i/H .i/I .i/L .i/K .i/M .i/F .i/P .i/S .i/T .i/W .i/Y .i/V .i/U .i/O")
  end
  
  config.after(:all) {system("rm -r -f .m .i")}
end
