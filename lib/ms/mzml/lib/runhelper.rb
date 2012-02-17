require 'nokogiri'

class BinaryDataArrayList
  
  def initialize(builder, mzs, ints)
    #required
    @count
    @binaryDataArray
  
  end
  
end

class BinaryDataArray

  def initialize()
  
    @params
    @binary
    #required
    @encodeLength
    #optional
    @arrayLength
    @dataProcessingRef
  
  end
end

class Precursor
  
  def initialize()
  
    @isolationWindow
    @selectedIonList
    @activation
    #optional
    @externalSpectrumId
    @sourceFileRef
    @spectrumRef
  
  end
end

class IsolationWindow
  
  def initialize()
  
    @params
  
  end
end

class SelectedIonList
  
  def initialize()
  
    @selectedIons
    #required
    @count

  end
end

class SelectedIon
  
  def initialize()
  
    @params

  end
end

class Activation
  
  def initialize()
  
    @params

  end
end

class Product
    
  def initialize()
  
    @isolationWindow
  
  end
end

class IsolationWindow
  
  def initialize()
  
    @params
  
  end
end
