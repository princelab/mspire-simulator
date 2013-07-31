
require 'obo/ontology'

module Mspire
  module Simulator ; end
end

class Mspire::Simulator::Modifications

  attr_accessor :modifications

  def initialize(mods)
    @modifications = mods
    @modifications = @modifications.split(/_/)
    if @modifications[0] != "false"
      get_mods
    else
      @modifications = nil
    end
    return @modifications
  end

  def get_mods()
    mods = {}
    obo = Obo::Ontology.new(Obo::Ontology::DIR + '/mod.obo')
    @modifications.each do |mod|
      diff = nil
      variable = false
      if mod[-1] == "v"
        mod = mod[0..-2]
        variable = true
      end
      residue = mod[9..-1]
      element = obo.id_to_element[mod[0..8]]
      raise ArgumentError, "a modification does not seem to appear in the PSI-MOD.obo!" unless element
      mod = element.tagvalues
      xref = mod['xref']
      xref.each do |x|
        if x =~ /DiffFormula/
          diff = (x.split(/"/))[1]
        end
      end
      if mods[residue] == nil
        mods[residue] = [[mod['id'][0],diff,variable]]
      else
        mds = mods[residue]
        mds<<[mod['id'][0],diff]
        mods[residue] = mds
      end
    end
    @modifications = mods
  end

end
