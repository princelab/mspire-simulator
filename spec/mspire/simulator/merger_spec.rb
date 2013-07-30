$LOAD_PATH << './lib'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ms/merger'

describe Merger do 
  before(:all) do 
    @spectra = {1 => [[1.0,1.5,1.7,3.0,4.0,5.0,6.0,7.0,8.0,9.0],[10,9,8,7,6,5,4,3,2,1]], 2 => [[1,2,3,4,5,6,7,8,9],[9,8,7,6,5,4,3,2,1]]}
  end
  
  it "#merge Takes spectra and a value that represents half the range where two peaks would be considered overlapping, then it merges these into meta peaks and returns the spectra" do
    half_range = 0.5
    meta_merged = Merger.merge(@spectra,half_range)
    meta_merged[1].should == [[{[1.236842105263158, 52.63157894736842, 47.368421052631575]=>[1.0, 1.5]}, 1.7, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], [[10, 9], 8, 7, 6, 5, 4, 3, 2, 1]]
    meta_merged[2].should == [[1, 2, 3, 4, 5, 6, 7, 8, 9], [9, 8, 7, 6, 5, 4, 3, 2, 1]]
  end 
  
  it "#compact Takes a meta merged spectra and removes meta data to return normal merged spectra" do
    half_range = 0.5
    meta_merged = Merger.merge(@spectra,half_range)
    merged = Merger.compact(meta_merged)
    merged[1].should == [[1.236842105263158, 1.7, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0], [19, 8, 7, 6, 5, 4, 3, 2, 1]]
    merged[2].should == [[1, 2, 3, 4, 5, 6, 7, 8, 9], [9, 8, 7, 6, 5, 4, 3, 2, 1]]
  end
end
