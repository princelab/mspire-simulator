
class ReferenceableParamGroupList
  include Writer
  
  def initialize()
    #required
    @count
    @referenceableParamGroups
  
  end
end

class ReferenceableParamGroup
  include Writer
  
  def initialize()
    #required
    @cvParam
    @userParam
  
  end
end
