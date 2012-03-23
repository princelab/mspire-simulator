#noise_spec.rb

require 'noise'

describe MS::Noise do 

  it "Adds noise to the spetra (as a hash {retention time => [[m/zs] ,[intensities]]})" do 
    hash = {10.0 => [[1,2,3], [4,5,6]]}
  end

end
