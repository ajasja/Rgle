# To change this template, choose Tools | Templates
# and open the template in the editor.
# TODO add tests for xtitle, ytitle itd...
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'rgle'

module RGle
  
  class RGleBuilderTests < Test::Unit::TestCase
    def test_xaxis
      gle = RGleBuilder.build do
        xaxis :min, -1, :max, -1
      end

      assert_match "xaxis min -1 max -1", gle.to_s

      gle = RGleBuilder.build do
        xaxis :min => -1, :max => -1
      end
      assert_match "xaxis min -1 max -1", gle.to_s
    end

    
    def test_layout_size
      gle = RGleBuilder.build do
        layout 2, 3
        thumbsize 12, 10
      end   
      assert_match "size 24 30", gle.to_s

      gle = RGleBuilder.build do
        thumbsize 12, 10
        layout 2, 3
      end
      assert_match "size 24 30", gle.to_s
    end

    def test_layout_set
      gle = RGleBuilder.build do
        thumbsize 12, 10
        layout 2, 3
      end
      assert_equal(true, gle.layout_set?)

      gle = RGleBuilder.build do
        thumbsize 12, 10

      end
      assert_equal(false, gle.layout_set?)

      gle = RGleBuilder.build do
        layout 2, 3
      end
      assert_equal(false, gle.layout_set?)

    end

    def test_layout_direction
      #test defaults
      gle = RGleBuilder.build do
        layout 2, 3
      end
      assert_equal(gle.layout_start, :top_left)
      assert_equal(gle.layout_direction, :horizontal)

      gle = RGleBuilder.build do
        layout 2, 3, :start => :top_right, :direction => :down
      end
      assert_equal(:top_right, gle.layout_start)
      assert_equal(:vertical, gle.layout_direction)

      gle = RGleBuilder.build do
        layout 2, 3, :start => :top_right, :direction => :left
      end
      assert_equal(:top_right, gle.layout_start)
      assert_equal(:horizontal, gle.layout_direction)

      gle = RGleBuilder.build do
        layout 2, 3, :start => :br, :direction => :up
      end
      assert_equal(:bottom_right, gle.layout_start)
      assert_equal(:vertical, gle.layout_direction)
    end

    def test_begin_graph
      gle = RGleBuilder.build do
        beg :graph do
          size 2, 2
        end
      end
      assert_match "begin graph", gle.to_s
      assert_match "end graph", gle.to_s

      gle = RGleBuilder.build do
        begin_graph do
          size 2, 2
        end
      end
      assert_match "begin graph", gle.to_s
      assert_match "end graph", gle.to_s

    end

    def test_make_and_push_graph_position
      gle = RGleBuilder.build do
        layout 2, 3, :top_left, :right
        thumbsize 12, 10
      end
      gle.make_and_push_graph_position(1)
      assert_match("amove 0 20", gle.to_s)
      gle.make_and_push_graph_position(2)
      assert_match("amove 12 20", gle.to_s)
      gle.make_and_push_graph_position(3)
      assert_match("amove 0 10", gle.to_s)
      gle.make_and_push_graph_position(4)
      assert_match("amove 12 10", gle.to_s)
      gle.make_and_push_graph_position(5)
      assert_match("amove 0 0", gle.to_s)
      gle.make_and_push_graph_position(6)
      assert_match("amove 12 0", gle.to_s)

      gle = RGleBuilder.build do
        layout 2, 3, :top_left, :down
        thumbsize 12, 10
      end
      gle.make_and_push_graph_position(1)
      assert_match("amove 0 20", gle.to_s)
      gle.make_and_push_graph_position(2)
      assert_match("amove 0 10", gle.to_s)
      gle.make_and_push_graph_position(3)
      assert_match("amove 0 0", gle.to_s)
      gle.make_and_push_graph_position(4)
      assert_match("amove 12 20", gle.to_s)
      gle.make_and_push_graph_position(5)
      assert_match("amove 12 10", gle.to_s)
      gle.make_and_push_graph_position(6)
      assert_match("amove 12 0", gle.to_s)
    end

    def test_graph_layouting
      gle = RGleBuilder.build do
        layout 2, 3, :top_left, :right
        thumbsize 12, 10
        1.upto 6 do
          beg :graph do            
          end
        end
      end
      
      assert_match(/amove 0 20\s*begin\sgraph\s*size 12 10/,gle.to_s)
      assert_match(/amove 12 20\s*begin\sgraph\s*size 12 10/,gle.to_s)
      assert_match(/amove 0 10\s*begin\sgraph\s*size 12 10/,gle.to_s)
      assert_match(/amove 12 10\s*begin\sgraph\s*size 12 10/,gle.to_s)
      assert_match(/amove 0 0\s*begin\sgraph\s*size 12 10/,gle.to_s)
      assert_match(/amove 12 0\s*begin\sgraph\s*size 12 10/,gle.to_s)
    end

    def test_build_with_file_name
      gle = RGleBuilder.build do
        layout 2, 4, :rl, :bt
        thumbsize 10, 12
      end
      assert_equal nil,gle.gle_file_name

      gle = RGleBuilder.build "my.gle" do
        layout 2, 4, :rl, :bt
        thumbsize 10, 12
      end
      assert_equal "my.gle",gle.gle_file_name
    end

    def test_append
      gle = RGleBuilder.build "my.gle" do
        size 1, 2
      end
      assert_match "size 1 2", gle.to_s

      gle.append do
        size 2, 2
      end
      assert_match "size 1 2", gle.to_s
      assert_match "size 2 2", gle.to_s
    end

    def test_get_gle_plot_command_line
      gle = RGleBuilder.build "my.gle" do
        beg :graph do
          size "1 2"
        end

      end
      
      
      line = gle.get_gle_plot_command_line :format => :png
      assert_equal gle.gle_executable + " -output my.png -device png my.gle", line

      line = gle.get_gle_plot_command_line :output => "test.psf"
      assert_equal gle.gle_executable + " -output test.psf -device psf my.gle", line

      line = gle.get_gle_plot_command_line :output => "test.image", :format => :svg
      assert_equal gle.gle_executable + " -output test.image -device svg my.gle", line

      unnamed = RGleBuilder.build  do
        beg :graph do
          size "1 2"
        end
      end

      #test unnamed script
      line = unnamed.get_gle_plot_command_line :output => "test.psf"
      assert_equal gle.gle_executable + " -output test.psf -device psf test.gle", line
      #name should be modified
      assert_equal "test.gle",  unnamed.gle_file_name
    end

    def test_xtitle
      #Test automatic quoting
      gle = RGleBuilder.build "my.gle" do
        beg :graph do
          a = "title"
          xtitle "My #{a}"
        end
      end
      assert_match(/"My title"/, gle.to_s)

      #With existing quotes
      gle = RGleBuilder.build "my.gle" do
        beg :graph do
          a = "title"
          xtitle "\"My #{a}\""
        end
      end
      assert_match(/"My title"/, gle.to_s)
    end

    def test_get_sql_command_line
      sql_string = ""
      gle = RGleBuilder.build "my.gle" do
        sql_string = sql? "Select * from table;", :database => 'test_db', :file => 'my.dat'
      end
      #puts sql_string
      assert_match('Select * from table;', sql_string)
      assert_match('test_db', sql_string)
      assert_match('my.dat', sql_string)

      #Test without specifying output file (it should take the name form the gle and change extension to csv)
      sql_string = ""
      gle = RGleBuilder.build "my.gle" do
        sql_string = sql? "Select * from table;", :database => 'test_db'
      end
      #puts sql_string
      assert_match('Select * from table;', sql_string)
      assert_match('test_db', sql_string)
      assert_match('my.csv', sql_string)

      #specify database separately
      sql_string = ""
      gle = RGleBuilder.build "my.gle" do
        database 'test_db'
        sql_string = sql? "Select * from table;"
      end
      #puts sql_string
      assert_match('Select * from table;', sql_string)
      assert_match('test_db', sql_string)
      assert_match('my.csv', sql_string)

    end

    def test_database_queries

      gle = RGleBuilder.build "my.gle" do
        database 'test_db'
        sql "Select * from table;"
        sql "Select * from table1;", :database => 'test_db1', :file => 'my1.dat'
        sql "Select * from table2;", :database => 'test_db1', :file => 'my2.dat'
      end
      assert_equal(3, gle.database_queries.size)
      #puts sql_string
      sql_string = gle.database_queries[0][:cmd]
      assert_match('Select * from table;', sql_string)
      assert_match('test_db', sql_string)
      assert_match('my.csv', sql_string)

      sql_string = gle.database_queries[1][:cmd]
      assert_match('Select * from table1;', sql_string)
      assert_match('test_db1', sql_string)
      assert_match('my1.dat', sql_string)

      sql_string = gle.database_queries[2][:cmd]
      assert_match('Select * from table2;', sql_string)
      assert_match('test_db1', sql_string)
      assert_match('my2.dat', sql_string)


    end

    def test_skip_query
      gle = RGleBuilder.build "my.gle" do
        database 'test_db'
        sql "Select * from table;", :file => __FILE__, :skip => :if_exists
        sql "Select * from table1;", :database => 'test_db1', :file => 'my1.dat', :skip => :allways
        sql "Select * from table2;", :database => 'test_db1', :file => 'my2.dat'
      end
      
      assert gle.skip_query?(gle.database_queries[0])
      assert gle.skip_query?(gle.database_queries[1])
      assert !gle.skip_query?(gle.database_queries[2])

      gle = RGleBuilder.build "my.gle" do
        database 'test_db', :skip => :all
        sql "Select * from table;", :file => __FILE__
        sql "Select * from table1;", :database => 'test_db1', :file => 'my1.dat'
        #database level overrides individual sql queries
        sql "Select * from table2;", :database => 'test_db1', :file => 'my2.dat', :skip => :never
      end

      assert gle.skip_query?(gle.database_queries[0])
      assert gle.skip_query?(gle.database_queries[1])
      assert gle.skip_query?(gle.database_queries[2])

      gle = RGleBuilder.build "my.gle" do
        database 'test_db', :skip => :never
        sql "Select * from table;", :file => __FILE__
        sql "Select * from table1;", :database => 'test_db1', :file => 'my1.dat'
        #database level overrides individual sql queries
        sql "Select * from table2;", :database => 'test_db1', :file => 'my2.dat', :skip => :all
      end

      assert !gle.skip_query?(gle.database_queries[0])
      assert !gle.skip_query?(gle.database_queries[1])
      assert !gle.skip_query?(gle.database_queries[2])

      gle = RGleBuilder.build "my.gle" do
        database 'test_db', :skip => :if_exists
        sql "Select * from table;", :file => __FILE__
        sql "Select * from table1;", :database => 'test_db1', :file => 'my1.dat'
        #database level overrides individual sql queries
        sql "Select * from table2;", :database => 'test_db1', :file => 'my2.dat', :skip => :all
      end

      assert gle.skip_query?(gle.database_queries[0])
      assert !gle.skip_query?(gle.database_queries[1])
      assert !gle.skip_query?(gle.database_queries[2])
    end


  end
end
