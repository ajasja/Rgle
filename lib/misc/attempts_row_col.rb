# To change this template, choose Tools | Templates
# and open the template in the editor.


def get_row(pos, layout)
  (pos-1)/(layout[0])+1
end

def get_col(pos, layout)
  row = get_row(pos, layout)
  return pos - (row-1)*layout[0]
end
layout=[2,3]
1.upto(6) { |i| puts "#{i}: #{get_col(i, layout)} #{get_row(i, layout)}" }
