# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'sys/proctable'
include Sys
ProcTable.ps{ |proc_struct|
    p proc_struct
}
