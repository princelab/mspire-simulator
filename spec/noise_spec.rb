#noise_spec.rb

require 'ms/noise'

describe MS::Noise do 

  it "Adds noise to the spetra (as a hash {retention time => [[m/zs] ,[intensities]]}) with a given density value" do 
    hash = {10.0 => [[1,2,3], [4,5,6]]}
    density = 20
    
    noisy_hash = MS::Noise.noiseify(hash, density)
    noisy_hash.should be_a(Hash)
    noisy_hash[10.0][0].size.should > 20
  end

end
