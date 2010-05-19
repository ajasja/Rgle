# To change this template, choose Tools | Templates
# and open the template in the editor.

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
      #name sould be modifed
      assert_equal "test.gle",  unnamed.gle_file_name
    end
  end
end
