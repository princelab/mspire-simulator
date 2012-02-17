require 'ms/cvlist'
require 'nokogiri'

class Params
  
  def initialize(builder,cv,user = nil,ref = nil)
  
    @referenceableParamGroupRef
    @cvParam = MS::CV::Param.new(cv)
    @userParam
    @builder = builder
      
  end
  
  def get_builder
    b = Nokogiri::XML::Builder.with(@builder.doc.at('fileContent')) do |xml|
      xml.cvParam(:cvRef=>@cvParam.cv_ref, :accession=>@cvParam.accession ,:name=>@cvParam.name)
      
      #user TODO
      if(@userParam != nil)
          xml.userParam(:cvRef=>@cvParam.cv_ref, :accession=>@cvParam.accession ,:name=>@cvParam.name)
      end
      #referenceableParamGroupRef TODO
      if(@referenceableParamGroupRef != nil)
          xml.referenceableParamGroupRef(:cvRef=>@cvParam.cv_ref, :accession=>@cvParam.accession ,:name=>@cvParam.name)
      end
    end
    
    return b
    
  end
end

class ReferenceableParamGroupRef
  
  def initialize()
  
    @ref
  
  end
end

class CvParam
  
  def initialize()
  
    #optional
    @unitCvRef
    @unitName
    @unitAccession
    @value
    #required
    @name
    @accession
    @cvRef
  
  end
end

class UserParam
  
  def initialize()
  
    #optional
    @unitCvRef
    @unitName
    @unitAccession
    @value
    @type
    #required
    @name
  
  end
end
