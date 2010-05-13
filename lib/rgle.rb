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
    attr_accessor :gle_string, :indent_count, :indent_string, :gle_file_name, :gle_executable
    attr_accessor :layout_hdir, :layout_vdir, :gle_command
    #attr_reader :layout, :thumbsize
    def initialize
      @gle_string = ""
      @indent_string = "  "
      @indent_count = 0
      @layout = nil
      @thumbsize = nil
      @layout_hdir = :left_to_right
      @layout_vdir = :top_to_bottom
      @gle_command = 'gle'
      @cur_graph_number = 0;
      @cur_in_graph = false
      @gle_executable = "gle"
      @gle_options = "-p"
      @gle_file_name =  nil
    end

    def self.build a_file_name=nil, &block
      gle_builder = new
      gle_builder.gle_file_name = a_file_name unless (a_file_name.nil? or a_file_name.empty?)
      gle_builder.instance_eval &block
      return gle_builder
    end

    def append &block
      self.instance_eval &block
      return self
    end
    
    def make_gle_line(*args)
      args.flatten.map{|a| a.to_s}.join(" ")
    end
    
    def push_to_gle_string(str)
      @gle_string = @gle_string + (@indent_string*@indent_count) + str + "\n"
    end

    def make_and_push_gle_line(*args)
      push_to_gle_string make_gle_line(*args)
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
      make_and_push_gle_line(sym,*args)
    end

    def generic_begin_end_block(sym, *args, &block)
      push_to_gle_string("begin #{sym}")
      do_indent      
      yield if block_given?
      do_unindent
      push_to_gle_string("end #{sym}")
    end

    #returns the position of the graph depending on the position and layout
    def get_graph_position(pos_number)
      
    end


    def save_to_file a_file_name
      @gle_file_name = a_file_name if a_file_name
      if not @gle_file_name then raise "Must specify script file name" end
      File.open(@gle_file_name, "w") { |f| f.write self.to_s}
    end
    #executes gle with the -p option
    def preview! opts
      save_to_file opts[:file_name]
      
      #`#{@gle_executable} -p #{@gle_file_name}`
      system("#{@gle_executable} -p #{@gle_file_name}")
    end
    ######special building methods start here##################
    # layout direction can be specified as
    # :left => :right, :top => :bottom or
    # :left_to_right,  :top_to_bottom or
    # :lr, :tb
    def raw str
      make_and_push_gle_line(str)
    end
    
    def layout x, y, *args
      @layout = [x, y]
     
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        h = args[0]
        if h.has_key?(:right) then @layout_hdir=:right_to_left else @layout_hdir=:left_to_right end
        if h.has_key?(:bottom) then @layout_vdir=:bottom_to_top else @layout_vdir=:top_to_bottom end
      end #if

      if (args.size == 2)  then
        @layout_hdir = args[0]
        @layout_vdir = args[1]
        @layout_hdir = :right_to_left if @layout_hdir==:rl
        @layout_hdir = :left_to_right if @layout_hdir==:lr
        @layout_vdir = :top_to_bottom if @layout_vdir==:tb
        @layout_vdir = :bottom_to_top if @layout_vdir==:bt
      end #if

      #if thumbsize has been set
      if @thumbsize then
        make_and_push_gle_line(:size,@layout[0]*@thumbsize[0], @layout1*@thumbsize[1])
      end
    end
  

    def thumbsize x, y
      @thumbsize = [x, y]
      if @layout then
        make_and_push_gle_line(:size, @layout[0]*@thumbsize[0], @layout[1]*@thumbsize[1])
      end
    end

  

    def xaxis *args
     
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        h = args[0]
        make_and_push_gle_line(:xaxis, :min, h[:min], :max, h[:max])
      else
        make_and_push_gle_line(:xaxis, args)
      end
    end

    def yaxis *args
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        h = args[0]
        make_and_push_gle_line(:yaxis, :min, h[:min], :max, h[:max])
      else
        make_and_push_gle_line(:yaxis, args)
      end
    end
    def x2axis *args
      puts "#{args.size} #{args.class}"
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        h = args[0]
        make_and_push_gle_line(:xaxis, :min, h[:min], :max, h[:max])
      else
        make_and_push_gle_line(:xaxis, args)
      end
    end

    def y2axis *args
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        h = args[0]
        make_and_push_gle_line(:yaxis, :min, h[:min], :max, h[:max])
      else
        make_and_push_gle_line(:yaxis, args)
      end
    end

    def begin_graph(*args, &block)
      @cur_graph_number += 1
      @cur_in_graph = true

      push_to_gle_string("begin graph")
      if @layout and @thumbsize then
        make_and_push_gle_line(:amove, get_graph_position(@cur_graph_number))
      end
      do_indent
      yield if block_given?
      do_unindent
      push_to_gle_string("end graph")
    

      @cur_in_graph = false
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