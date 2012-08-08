require 'rubyvis'

class Fit_plot
  def self.plot(pts,pts2,file,labels = ["",""])
    xlab = labels[0]
    ylab = labels[1]
  
    w = 600
    h = 300

    xmin = pts.min_by{|arr| arr[0]}[0]
    xmax = pts.max_by{|arr| arr[0]}[0]
    ymin = pts.min_by{|arr| arr[1]}[1]
    ymax = pts.max_by{|arr| arr[1]}[1]

    line1 = []
    pts.each do |pt| 
      line1<<OpenStruct.new({:x=> pt[0], :y=> pt[1]})
    end

    line2 = []
    pts2.each do |pt| 
      line2<<OpenStruct.new({:x=> pt[0], :y=> pt[1]})
    end

    x = pv.Scale.linear(xmin, xmax).range(0, w)
    y = pv.Scale.linear(ymin, ymax).range(0, h)


    vis = pv.Panel.new()
      .width(w)
      .height(h)
      .bottom(50)
      .left(40)
      .right(30)
      .top(5);
     
    vis.add(pv.Dot).
      stroke_style('blue').
      data(line1).
      line_width(2).
      left(lambda {|d| x.scale(d.x)}).
      bottom(lambda {|d| y.scale(d.y)}).
      shape_size(1).
      anchor("bottom");
      
    vis.add(pv.Line).
      stroke_style('red').
      data(line2).
      line_width(2).
      left(lambda {|d| x.scale(d.x)}).
      bottom(lambda {|d| y.scale(d.y)}).
      anchor("bottom");
      
    vis.add(pv.Label)
        .data(x.ticks())
        .left(lambda {|d| x.scale(d)})
        .bottom(0)
        .text_baseline("top")
        .text_margin(5);
        
    vis.add(pv.Label)
      .bottom(-30)
      .text(xlab);
      
    vis.add(pv.Label)
      .text_angle(-Math::PI/2.0)
      .left(-10)
      .text(ylab);

    vis.add(pv.Rule)
        .data(y.ticks())
        .bottom(lambda {|d| y.scale(d)})
        .stroke_style(lambda {|i|  i!=0 ? pv.color("#ccc") : pv.color("black")})
      .anchor("right").add(pv.Label)
      .visible(lambda { (self.index & 1)==0})
        .text_margin(6);
        vis.render();
    
    file_out = File.open(file,"w")
    file_out.puts vis.to_svg
    file_out.close
  end
end
