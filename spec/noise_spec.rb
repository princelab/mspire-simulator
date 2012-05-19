#noise_spec.rb

require 'ms/noise'

describe MS::Noise do 

  it "Creates a hash of noise given an array of scan times with a given density value and the max m/z value" do 
    scan_times = [1,2,3,4,5,6,7,8,9]
    density = 20
    mz_max = 300
    
    noisy_hash = MS::Noise.noiseify(scan_times, density,mz_max)
    noisy_hash.should be_a(Hash)
    noisy_hash[6][0].size.should >= 20
  end

end
