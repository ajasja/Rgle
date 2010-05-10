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

gle = RGleBuilder.new
gle.define_general_build_method :amethod
gle.amethod 1, 2, 3, :sy
#gle.beg(:graph) do {puts "some bla"}
puts gle.gle_string
puts gle.inspect

#gle = RGleBuilder.gle_layout do
#  define_general_build_method :amethod
#  amethod 1, 3, 4
#end
#
#puts gle.gle_string