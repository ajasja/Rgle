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
    attr_accessor :layout_start, :layout_direction
    #attr_reader :layout, :thumbsize
    def initialize
      @gle_string = ""
      @indent_string = "  "
      @indent_count = 0
      @layout = nil
      @thumbsize = nil
      @layout_start = :top_left
      @layout_direction   = :horizontal
      
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


    def save_to_file a_file_name=nil
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

    def get_gle_plot_command_line opts={}
      #defaults = {:format => :png, :output => "temp"}
      #opts =  defaults.merge(opts)
      #raise an error if the format and the output are not specified
      
      extension = nil
      extension = File.extname(opts[:output]) if opts[:output]
      unless opts[:format] or extension then
        raise "Either the format or the extension must be specified."
      end
      #set the format according to the file name extension if no format is given
      if not opts[:format] then
        opts[:format] = extension[1..-1].to_sym
      end
      if extension.nil? or extension.empty? then
        extension = '.'+opts[:format].to_s
      end
      gle_format = "-device #{opts[:format]}"

      unless opts[:output] or @gle_file_name then
        raise "Either the output file name or the script file name must be set."
      end

      #if output has no extension and format is given then
      if opts[:output]  and File.extname(opts[:output]).empty? then
        opts[:output]=opts[:output]+extension
      end
      #set the script file name from output name if script file name is not specified
      if (not @gle_file_name) and opts[:output] then
        @gle_file_name = File.basename(opts[:output], extension)+'.gle'
      end

      
      
      if (not opts[:output]) and @gle_file_name then
        opts[:output] = File.basename(@gle_file_name, '.gle')+extension
      end

      gle_command_string = [@gle_executable,"-output",
        opts[:output],gle_format, opts[:options], @gle_file_name].compact.join(" ")
    end
    def plot! opts = {}
      line = get_gle_plot_command_line(opts)
      save_to_file
      puts line
      `#{line}`
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
     
    
      #if thumbsize has been set
      if @thumbsize then
        make_and_push_gle_line(:size,@layout[0]*@thumbsize[0], @layout[1]*@thumbsize[1])
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