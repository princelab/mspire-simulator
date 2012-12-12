#!/usr/bin/env ruby 
# http://isoelectric.ovh.org/files/practise-isoelectric-point.html#mozTocId496531
# Taken from Ryan's github repo

Precision = 0.001
ResidueTable = {
  :K => [2.18,8.95,10.53], 
  :E => [2.19,9.67,4.25], 
  :D => [1.88,9.60,3.65], 
  :H => [1.82,9.17,6.00],
  :R => [2.17,9.04,12.48],
  :Q => [2.17,9.13,nil],
  :N => [2.02,8.80,nil],
  :C => [1.96,10.28,8.18],
  :T => [2.11,9.62,nil],
  :S => [2.21,9.15,nil],
  :W => [2.38,9.39,nil],
  :Y => [2.20,9.11,10.07],
  :F => [1.83,9.13,nil],
  :M => [2.28,9.21,nil],
  :I => [2.36,9.68,nil],
  :L => [2.36,9.60,nil],
  :V => [2.32,9.62,nil],
  :P => [1.99,10.96,nil],
  :A => [2.34,9.69,nil],
  :G => [2.34,9.60,nil],
  # These are the fringe cases... B and Z... Jerks, these are harder to calculate pIs
  :B => [1.95,9.20,3.65],
  :Z => [2.18,9.40,4.25],
  :X => [2.20,9.40,nil],
  :U => [1.96,10.28,5.20] # Unfortunately, I've only found the pKr for this... so I've used Cysteine's values.
}
PepCharges = Struct.new(:seq, :n_term, :c_term, :y_num, :c_num, :k_num, :h_num, :r_num, :d_num, :e_num, :u_num, :polar_num, :hydrophobic_num, :pi)
def identify_potential_charges(str)
  string = str.upcase
  first = string[0]; last = string[-1]
  puts string if first.nil? or last.nil?
  begin
    out = PepCharges.new(string, ResidueTable[first.to_sym][0], ResidueTable[last.to_sym][1], 0, 0, 0 ,0 ,0 ,0, 0, 0, 0, 0, 0)
  rescue NoMethodError
    abort string
  end
  string.chars.each do |letter|
    case letter
    when "Y" 
      out.y_num += 1 
    when "C"
      out.c_num += 1
    when "K"
      out.k_num += 1 
    when "H"
      out.h_num += 1
    when "R"
      out.r_num += 1
    when "D"
      out.d_num += 1
    when "E"
      out.e_num += 1
    when "U"
      out.u_num += 1
    when "S", "T", "N", "Q"
      out.polar_num += 1
    when "A", "V", "I", "L", "M", "F", "W", "G", "P"
      out.hydrophobic_num += 1
    end
  end
  out
end # Returns the PepCharges structure

def charge_at_pH(pep_charges, pH)
  charge = 0
  charge += -1/(1+10**(pep_charges.c_term-pH))
  charge += -pep_charges.d_num/(1+10**(ResidueTable[:D][2]-pH))
  charge += -pep_charges.e_num/(1+10**(ResidueTable[:E][2]-pH))
  charge += -pep_charges.c_num/(1+10**(ResidueTable[:C][2]-pH))
  charge += -pep_charges.y_num/(1+10**(ResidueTable[:Y][2]-pH))
  charge += 1/(1+10**(pH - pep_charges.n_term))
  charge += pep_charges.h_num/(1+10**(pH-ResidueTable[:H][2]))
  charge += pep_charges.k_num/(1+10**(pH-ResidueTable[:K][2]))
  charge += pep_charges.r_num/(1+10**(pH-ResidueTable[:R][2]))
  charge
end


def calc_PI(pep_charges)
  pH = 8; pH_prev = 0.0; pH_next = 14.0
  charge = charge_at_pH(pep_charges, pH)
  while pH-pH_prev > Precision and pH_next-pH > Precision
    if charge < 0.0
      tmp = pH
      pH = pH - ((pH-pH_prev)/2)
      charge = charge_at_pH(pep_charges, pH)
      pH_next = tmp
    else
      tmp = pH
      pH = pH + ((pH_next - pH)/2)
      charge = charge_at_pH(pep_charges, pH)
      pH_prev = tmp
    end
    #	puts "charge: #{charge.round(2)}\tpH: #{pH.round(2)}\tpH_next: #{pH_next.round(2)}\tpH_prev: #{pH_prev.round(2)}"
  end
  pH
end
def distribution_from_charge(charge, normalization=100)
  threshold = normalization.to_f
  f = charge.floor
  c = charge.ceil
  charge_ratio = charge - f
  num = charge_ratio*normalization
  denom = normalization
  while num + denom > threshold
    factor = threshold/(num+denom)
    num = num * factor
    denom = denom * factor 
  end
  [["+#{f}" + ", " + "%5f" % num],["+#{c}" + ", " + "%5f" % denom]]
end


#pepcharges =[]
if $0 == __FILE__
  VERBOSE = false
  def putsv(object)
    puts object if VERBOSE
  end
  def out(line, object)
    line + ":\t" + object.to_s
  end
  require 'optparse'

  options = {pi: true, distribution: false, ph: 7.0}
  parser = OptionParser.new do |opts|
    opts.banner = "Takes strings and outputs the PI, or charge distribution"

    opts.on('-h','--help', "Displays this help message") do |h|
      puts opts
      exit
    end
    opts.on('-v','--verbose') {|v| VERBOSE = v}
    opts.on("--[no]-pi", "Turns on (default) or off the pI output") do |p|
      options[:pi] = p
    end
    opts.on("-d", "--distribution", "Output a string representation of the charge state distribution array") do |d|
      options[:distribution] = true
      options[:pi] = false
    end
    opts.on('--pH N', Float, "Takes a float value representing a pH at which to make the distribution. DEFAULT: 7.0") do |ph|
      options[:ph] = ph
    end
    opts.on('-f', "--file FILENAME", String, "Takes an input file for parsing") do |f|
      options[:in_file] = f
    end
  end
  parser.parse!

  #  RUN
  pi = []
  lines = []
  if options[:in_file]
    file_lines = File.readlines(options[:in_file]).map(&:chomp) 
    lines = file_lines.map {|line| line[/^([A-Z]+).*/] }.compact
    outfile = File.join(File.dirname(options[:in_file]), 'pi_output_file.txt')
    outputter = File.open(outfile,'w')
  else 
    lines = ARGV
    outputter = STDOUT
  end
  if options[:pi]
    lines.each {|line| outputter.puts out(line, calc_PI(identify_potential_charges(line)) ) }
  elsif options[:distribution]
    lines.each do |line| 
      charge = charge_at_pH(identify_potential_charges(line), options[:ph])
      charge_dist = distribution_from_charge(charge)
      outputter.puts out(line + " @ pH #{options[:ph]}", charge_dist.join("; ")) 
    end
  end
  if outfile
    outputter.close 
    puts "OUTPUT in #{outfile}"
  end
end
