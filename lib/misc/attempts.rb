# To change this template, choose Tools | Templates
# and open the template in the editor.
require './rgle'
include RGle
class JistAClass
  def self.build_arguments(*args)
    return " Built:" + args.map{|a| a.to_s}.join(" ")
  end
  def method_missing(symbol, *args)
    puts "This method #{symbol} is missing"
  end
end

#just = JistAClass.new

#puts just.class.build_arguments 1,2 ,:sym, "string"
#just.amethod

#gle = RGleBuilder.new
#gle.amethod 1, 2, 3, :sy
#gle.begin(:graph) do
#  "asdad"
#end
#puts gle
#puts gle.inspect

gle = RGleBuilder.build do
  layout 2, 3
  thumbsize 12, 8 
  beg :graph do
     xaxis :min => -1, :max => 1
     yaxis "min -1 max 1"
     xtitle "kot [deg]"
     xlabels :off

     let ""
     d2 ""
     data "file.name", "d1=c1,c3"
     data  :file => "file.name", :d1 => "c1,c3"
     data  :sql => "SELECT Chi, Phi FROM diehedrals WHERE resid=18 AND frame>1000 AND frame<3000",
           :file => "file.name", :plot => :all
     

     



  end
  raw ""
  beg :key do

  end
  raw ""
  beg :qsave do

  end
end

puts gle

#puts gle.gle_string