require 'msplat'
require 'ms/cvlist'

class CvList
  
  def initialize(cvs)
  
    @cvs = Array.new
    #attributes - required
    @count
    
    cvs.each do |cv|
      @cvs.push(MS::CV::Param.new(cv))
    end
  
  end
  
  def to_s
    puts "Working"
  end
end

class Cv
  
  def initialize()

    #attributes - required
    @uri
    @fullName
    @id
    #optional 
    @version
    
  end
end
