require File.dirname(__FILE__)+'/../../rgle'
include RGle

gle = RGleBuilder.build do
  
  
  layout 2, 3
  #layout 2, 3, :direction => :down #try this as well
  thumbsize 12, 10
  1.upto(6) do |k|
    beg :graph do
      title "Parabola with k #{k}"
      xtitle :x
      ytitle "f(x) = (#{k}x)^2"

      let "d1 = (#{k}*x)^2 from -1 to 1 step 0.01"

      xaxis :min => -1, :max => 1
      yaxis "min 0 max 1"

      key "pos br compact"
     
      d1 :line, :color, :red
    end
  end
end

gle.preview! :file_name => "parabola.gle"

puts gle