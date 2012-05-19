
module RThelper
  
  module_function
  def normalized_gaussian(x,mu,sd)
    x = x.to_f
    mu = mu.to_f
    sd = sd.to_f
    return ((1/(Math.sqrt(2*(Math::PI)*(sd**2))))*(Math.exp(-(((x-mu)**2)/((2*sd)**2)))))
  end
  
  module_function
  def gaussian(x,mu,sd,h)
    x = x.to_f
    mu = mu.to_f
    sd = sd.to_f
    h = h.to_f
    return h*(Math.exp(-(((x-mu)**2)/(sd**2))))
  end
  
  module_function
  def RandomFloat(a,b)
    a = a.to_f
    b = b.to_f
    random = rand(2147483647.0) / 2147483647.0
    diff = b - a
    r = random * diff
    return a + r
  end
end

