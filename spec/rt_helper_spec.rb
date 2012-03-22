#rt_helper_spec.rb

require 'ms/rt/rt_helper'

describe RThelper do 
  
  it "#gaussian Defines a guassian function, returns the 'y' value for a given 'x' value, 'mu' and standard deviation" do 
    x = 5
    mu = 10
    sd = 30
    RThelper.gaussian(x, mu, sd).should == 0.013206053525209427
  end
  
  
  
  it "#gaussianI Defines a gaussian function with a scaling factor" do 
    x = 5
    mu = 10
    sd = 30
    scale = 100
    RThelper.gaussianI(x, mu, sd, scale).should == 97.26044464111328
  end
  
  
  
  it "#RandomFloat Returns a random float in the specified range" do 
    r_float = RThelper.RandomFloat(20,40)
    r_float.should > 20.0
    r_float.should < 40.0
    r_float.should be_a(Float)
  end
  
end
