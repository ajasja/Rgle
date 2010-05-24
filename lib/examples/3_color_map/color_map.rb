require 'rgle'
include RGle
#change working directory to current dir
Dir.chdir(File.dirname(__FILE__))
def create_xyz_file(dest_name)
  datax =[]
  datay =[]
  dataz =[]
  i = 0;
  Dir['data/*'].each do |file_name|
    File.open(file_name, "r") do |file|
      #skip first line
      file.gets
      y_val = /(\d\d)$/.match(file_name)[0].to_i
      file.each_line { |line|
        la = line.split
        datax[i]=la[0]
        datay[i]=y_val
        dataz[i]=la[1]
        i=i+1
      }
    end
  end
  File.open(dest_name, "w") { |f|
    0.upto(datax.size-1) { |j|  f.puts "#{datax[j]},#{datay[j]},#{dataz[j]}"}        
  }

end
create_xyz_file "saxs.dat" unless File.exists? "saxs.dat"


gle = RGleBuilder.build "saxs" do
 
  size 12, 12

  beg :fitz do
    data "saxs.dat"
    x "from 0.02388324 to 0.4858713 step 0.0001"
    y "from 1 to 23 step 1"
    ncontour  5
  end unless File.exists? "saxs.z"


  beg :graph do
    title "SAXS"
    xtitle "lambda^{-1}"
    ytitle "temperature series"
  
    colormap  "saxs.z", 500, 500, :color
  end
end

puts gle

#gle.preview!
gle.plot! :format => :png,  :options => "-resolution 600"
gle.plot! :format => :png,  :options => "-resolution 600"
