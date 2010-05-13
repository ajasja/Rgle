require './rgle'
include RGle

graphs = RGleBuilder.build do
   include "polarplot.gle"
   include "polarplotdata.gle"
    
   size 24, 24
   layout 2, 3 
   thumbsize 12, 8 
   
   database "diedrals.db"
   make_query  :sql => "SELECT Chi, Phi FROM diehedrals WHERE resid=18 AND frame>1000 AND frame<3000", 
               :file => "file.name"
   
   font :texcmr
   raw ""
   
   print?
   
#   sub "polardata ds$ color$ fill$ lwidth type$" do
#      default :color, :black
#      default :fill => :clear
#
#
#   end
   
   qsave
   amove 15.3, 19.4
   qrestore
   beg :graph do
     center
     hscale 0.75
     vscale 0.75
     size 10, 10
     
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


   beg :key do
   
   end
   
   beg :qsave do
   
   end
end

#graphs.plot!

#graphs.plot :output => "some", :format => :csv, :options => "-p"
#graphs.plot :output => "some.png", :raw => "-p"
puts graphs.to_s