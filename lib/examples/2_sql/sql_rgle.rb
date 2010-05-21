require File.dirname(__FILE__)+'/../../rgle'
include RGle
Dir.chdir(File.dirname(__FILE__))
gle = RGleBuilder.build "sql_rgle" do
  layout 3, 2
  thumbsize 10, 10
  database 'test_db'
  
  sql "Select frame, phi, psi, chi1,chi2,chi3,chi4,chi5  from dihedrals where resid=18"
  beg :graph do
    center
    hscale 0.75
    vscale 0.75
    
    
    xtitle "frame"
    ytitle "Angle"
   
    data "sql_rgle.csv"

    d1 "color red marker dot mscale 0.8"
    d2 "color blue marker dot mscale 0.8"
  end

  1.upto(5) { |i|
    beg :graph do
      center
      hscale 0.75
      vscale 0.75
      

      xtitle "frame"
      ytitle "Angle"

      data "sql_rgle.csv d1=c1,c#{i+3} d2=c1,c#{i+3}"

      d1 "color red marker dot mscale 0.8"
      d2 "deresolve 10 average line color red"
    end
  }
end

gle.preview! 

puts gle