require File.dirname(__FILE__)+'/../../rgle'
include RGle

gle = RGleBuilder.build do
  size 12, 8
  beg :graph do
    title "Parabola"
    xtitle "x"
    ytitle '"f(x) = (x-2)^2"' #the string quoting is cumbersome...
    let "d1 = (x-2)^2 from 0 to 4 step 0.1"

    key "pos br compact"
    d1 "key \"parabola\"" 
    d1 :line, :color, :red
  end
end

gle.preview! :file_name => "parabola.gle"

puts gle