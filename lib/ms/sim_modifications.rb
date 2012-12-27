
require 'obo/ontology'

class Modifications
  def initialize(mods)
    @modifications = mods
    @modifications = @modifications.split(/_/)
    if @modifications[0] != "false"
      get_mods
    end
    return @modifications
  end

  def get_mods()
    mods = {}
    obo = Obo::Ontology.new(Obo::Ontology::DIR + '/mod.obo')
    @modifications.each do |mod|
      diff = nil
      residue = mod[9..mod.size-1]
      mod = (obo.id_to_element[mod[0..8]]).tagvalues
      xref = mod['xref']
      xref.each do |x|
        if x =~ /DiffFormula/
          diff = (x.split(/"/))[1]
        end
      end
      if mods[residue] == nil
        mods[residue] = [[mod['id'][0],diff]]
      else
        mds = mods[residue]
        mds<<[mod['id'][0],diff]
        mods[residue] = mds
      end
    end
    @modifications = mods
  end
  
  attr_reader :modifications
  attr_writer :modifications
end
