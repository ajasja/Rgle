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

      assert_equal "xaxis min -1 max -1\n", gle.to_s

      gle = RGleBuilder.build do
        xaxis :min => -1, :max => -1
      end
      assert_equal "xaxis min -1 max -1\n", gle.to_s
    end

    def test_layout_direction
      gle = RGleBuilder.build do
        layout 2, 4, :left => :right, :top => :bottom
      end
      assert_equal :left_to_right, gle.layout_hdir
      assert_equal :top_to_bottom, gle.layout_vdir

      gle = RGleBuilder.build do
        layout 2, 4, :right => :left, :bottom => :top
      end
      assert_equal :right_to_left, gle.layout_hdir
      assert_equal :bottom_to_top, gle.layout_vdir

      gle = RGleBuilder.build do
        layout 2, 4, :lr, :tb
      end
      assert_equal :left_to_right, gle.layout_hdir
      assert_equal :top_to_bottom, gle.layout_vdir

      gle = RGleBuilder.build do
        layout 2, 4, :rl, :bt
      end
      assert_equal :right_to_left, gle.layout_hdir
      assert_equal :bottom_to_top, gle.layout_vdir
    end
    
    def test_layout_size
      gle = RGleBuilder.build do
        layout 2, 3
        thumbsize 12, 10
      end

      assert_match "size 24 30", gle.to_s
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

    def test_get_graph_position
      gle = RGleBuilder.build do
        layout 2, 4, :rl, :bt
        thumbsize 10, 12
      end
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
  end
end
