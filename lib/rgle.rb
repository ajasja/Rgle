
module RGle
  class String
    def ends_with?(val)
      self =~ /#{Regexp.escape val}\Z/
    end

    def starts_with?(val)
      self =~ /\A#{Regexp.escape val}/
    end
  end

  class RGleBuilder
    attr_accessor :gle_string, :indent_count, :indent_string

    def initialize
      @gle_string = ""
      @indent_string = "  "
      @indent_count = 0
      @layout = nil
      @thumbsize = nil
      @layout_hdir = :left_to_right
      @layout_vdir = :top_to_bottom
      @gle_command = 'gle'
    end

    def self.gle_layout &block
      gle_builder = new
      gle_builder.instance_eval &block
      return gle_builder
    end

    def make_gle_line(*args)
      args.map {|a| a.to_s}.join(" ")
    end
    
    def push_to_gle_string(str)
      @gle_string << (@indent_string*@indent_count) + str + "\n"
    end
    def do_indent
      @indent_count+=1
    end
    def do_unindent
      @indent_count-=1
      @indent_count=0 if @indent_count<0
    end
    def to_s
      @gle_string
    end
    
    def method_missing(sym, *args)      
      push_to_gle_string make_gle_line(sym, args)
    end

    def generic_begin_end_block(sym, *args, &block)
      push_to_gle_string("begin #{sym}")
      do_indent      
      yield if block_given?
      do_unindent
      push_to_gle_string("end #{sym}")
    end
    
    ######special building methods start here##################
    # layout direction can be specified as
    # :left => :right, :top => :bottom or
    # :left_to_right,  :top_to_bottom
    def layout x, y, *args
      @layout = [x, y]
      if (args.size == 1) and (args.is_a?(Hash)) then
        h = args[0]
        if h.has_key?(:right) then @layout_hdir=:right_to_left else @layout_hdir=:left_to_right end
        if h.has_key?(:bottom) then @layout_hdir=:bottom_to_top else @layout_hdir=:top_to_bottom end        
      end #if
      if (args.size == 2)  then
        @layout_hdir = args[0]
        @layout_vdir = args[1]
        @layout_hdir = :right_to_left if @layout_hdir==:rl
        @layout_hdir = :left_to_right if @layout_hdir==:lr
        @layout_vdir = :top_to_bottom if @layout_hdir==:tb
        @layout_vdir = :bottom_to_top if @layout_hdir==:bt
      end #if
    end
  

  def thumbsize x, y
    @thumbsize = [x, y]
  end



  def begin_graph(*args, &block)
    generic_begin_end_block(:graph, *args, &block)
  end

  # just a router. Graphs and such may need special handling
  def beg(sym, *args, &block)
    case sym
    when :graph then begin_graph(*args, &block)
    else
      generic_begin_end_block(sym, *args, &block)
    end #case
  end #beg


end #class
end #module
