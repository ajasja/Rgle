#require File.dirname(__FILE__)+'/../../rgle'
require 'rgle'
include RGle

def get_number_of_columns(afile, header=true, comment_char='!', separator=',', nan_string='NaN')
  raise "file does not exist" unless File.exist?(afile)
  File.open(afile, "r") { |f| 
    #ignore comment lines
    line = f.gets
    while line[0..0]==comment_char do
      line = f.gets  
    end
    if header
      line = f.gets
    end
    while line[0..0]==comment_char do
      line = f.gets
    end

    puts line
    puts line.split(separator).reject {|a| (a.strip==nan_string) or a.empty?}
    return line.split(separator).reject {|a| (a.strip==nan_string) or a.empty?}.count
  }

end

Dir.chdir(File.dirname(__FILE__))
gle = RGleBuilder.build "sql_rgle" do
  layout 3, 2
  thumbsize 10, 10
  database 'test_db'
  
  resid=16
  #execute query immediately, so that one can read the number of columns that have a non NaN value
  sql! "Select frame, phi, psi, chi1,chi2,chi3,chi4,chi5  from dihedrals where resid=#{resid}"
  numcols = get_number_of_columns "sql_rgle.csv"
  #puts numcols
  gsave
  amove 15.5, 19.4
  set "hei 0.8 color silver just center"
  write  "resid=#{resid}"
  grestore

  beg :graph do
    center
    hscale 0.75
    vscale 0.75
    
    
    xtitle "frame"
    ytitle "Angle"
   
    data "sql_rgle.csv"

    d1 "color blue marker dot mscale 0.8"
    d2 "color red marker dot mscale 0.8"
  end

  1.upto(numcols-3) { |i|
    beg :graph do
      center
      hscale 0.75
      vscale 0.75
      

      xtitle "frame"
      ytitle "Angle"

      data "sql_rgle.csv d1=c1,c#{i+3} d2=c1,c#{i+3}"

      d1 "color red marker dot mscale 0.9"
      d2 "deresolve 5 average line color red"
    end
  }
end

gle.preview! 

#puts gle