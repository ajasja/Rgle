class String
  def ends_with?(val)
    self =~ /#{Regexp.escape val}\Z/
  end

  def starts_with?(val)
    self =~ /\A#{Regexp.escape val}/
  end
end
  
#taken from
# http://blog.jayfields.com/2008/02/ruby-dynamically-define-method.html
class Class
  def def_each(method_names,*args, &block)
    method_names=method_names.to_a
    method_names.each do |method_name|
      define_method method_name do |*args|
        instance_exec method_name, *args, &block
      end
    end
  end
end
#class Object
#  module InstanceExecHelper; end
#  include InstanceExecHelper
#  def instance_exec(*args, &block)
#    begin
#      old_critical, Thread.critical = Thread.critical, true
#      n = 0
#      n += 1 while respond_to?(mname="__instance_exec#{n}")
#      InstanceExecHelper.module_eval{ define_method(mname, &block) }
#    ensure
#      Thread.critical = old_critical
#    end
#    begin
#      ret = send(mname, *args)
#    ensure
#      InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
#    end
#    ret
#  end
#end



module RGle


  class RGleBuilder
    attr_accessor :gle_string, :indent_count, :indent_string, :gle_file_name, :gle_executable
    attr_accessor :layout_start, :layout_direction, :layout_size
    attr_accessor :database_queries, :databse_skip_queries
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
      #database, SQL, output_file_name
      @database_client_command = 'sqlite3 -csv -header -separator "," -nullvalue "NaN"  %s "%s" > "%s"'
      @database_queries = []
      @database_file_name = nil
      @databse_skip_queries = nil
    end

    def self.build a_file_name=nil, &block
      gle_builder = new
      if !(a_file_name.nil? or a_file_name.empty?)
        a_file_name=a_file_name+'.gle' unless /\.[a-zA-Z]+$/ =~ a_file_name
        gle_builder.gle_file_name = a_file_name

      end
      
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
    
    def get_graph_grid_layout_position(pos)
      if @layout_direction==:horizontal then

        row = (pos-1)/@layout[0]+1
        col = pos - (row-1)*@layout[0]

      end

      if @layout_direction==:vertical then
        col = (pos-1)/@layout[1]+1
        row = pos - (col-1)*@layout[1]
      end

      return row, col
    end
    
    def make_and_push_graph_position(pos_number)
      if not layout_set?
        raise "layout has not been set"
      end
      
      ## for now only top_left is supported!
      row, col = get_graph_grid_layout_position(pos_number)
      x = (col-1)*@thumbsize[0]
      y = (@layout[1]-row)*@thumbsize[1]

      make_and_push_gle_line(:amove, x, y)
      
    end

    #returns true if the layout and thumb_size have been set.
    def layout_set?
      (@layout!=nil) and (@thumbsize!=nil)
      
    end
    def save_to_file a_file_name=nil
      @gle_file_name = a_file_name if a_file_name
      if not @gle_file_name then raise "Must specify script file name" end
      File.open(@gle_file_name, "w") { |f| f.write self.to_s}
    end
    #executes gle with the -p option
    def preview! opts={}
      execute_sql_queries!
      save_to_file opts[:file_name]
      
      `#{@gle_executable} -p #{@gle_file_name}`
      #system("#{@gle_executable} -p #{@gle_file_name}")
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
      execute_sql_queries!
      line = get_gle_plot_command_line(opts)
      save_to_file
      puts line
      `#{line}`
    end
    #Options
    #:database => name of database
    #:file => output file for data. If not specified
    def get_sql_command_line(sql_string, opts={})
      @database_file_name = opts[:database] unless opts[:database].nil?

      raise("Database not specified")  unless @database_file_name
      data_out_file_name = opts[:file]
      data_out_file_name ||= File.basename(@gle_file_name, '.gle')+'.csv'
      raise("File name not specified") unless data_out_file_name

      return sprintf(@database_client_command, @database_file_name, sql_string, data_out_file_name)
    end
    ######special building methods start here##################

    def database(name, opts = {})
      @database_file_name = name
      if opts.has_key?(:skip) then
         @databse_skip_queries =opts[:skip]
      end
    end

    #Just for testing
    def sql?(sql_string, opts={})
      return get_sql_command_line(sql_string, opts)
    end

    #executes query immediately
    def sql! (sql_string, opts={})
      cmd = get_sql_command_line(sql_string, opts)
      puts `#{cmd}`
    end

    #Adds query to list. It is executed with plot!
    def sql (sql_string, opts={})
      opts[:cmd] = get_sql_command_line(sql_string, opts)
      @database_queries << opts
    end

    def skip_query?(h)
      h[:skip] = @databse_skip_queries if @databse_skip_queries
      h[:skip]=:allways if h[:skip]==:all
      ((h[:skip]==:if_exists) and File.exists?(h[:file])) or (h[:skip]==:allways)
    end
    
    def execute_sql_queries!
      @database_queries.each {|h|
        #skip execution if either the skip => if exists is given and file exists or skip if some flags are set
        `#{h[:cmd]}` unless skip_query?(h)
        puts "#{h[:cmd]}"
      }
    end
    def raw str
      make_and_push_gle_line(str)
    end
    
    def layout x, y, *args
      @layout = [x, y]
     
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        hsh = args[0]
        @layout_start = hsh[:start] if hsh.has_key? :start
        @layout_direction = hsh[:direction] if hsh.has_key? :direction
      end #if

      if (args.size == 2)  then
        @layout_start     = args[0]
        @layout_direction = args[1]
      end #if

      #expand shortcut options
      case @layout_start
      when :tl then @layout_start=:top_left
      when :tr then @layout_start=:top_right
      when :bl then @layout_start=:bottom_left
      when :br then @layout_start=:bottom_right
      end

      case @layout_direction
      when :right, :left then @layout_direction=:horizontal
      when :top, :bottom, :down, :up then @layout_direction=:vertical
      end

      #if thumbsize has been set
      if @thumbsize then
        @layout_size = [@layout[0]*@thumbsize[0], @layout[1]*@thumbsize[1]]
        make_and_push_gle_line(:size, @layout_size[0], @layout_size[1])
      end
    end
  

    def thumbsize x, y
      @thumbsize = [x, y]
      if @layout then
        @layout_size = [@layout[0]*@thumbsize[0], @layout[1]*@thumbsize[1]]
        make_and_push_gle_line(:size, @layout_size[0], @layout_size[1])
      end
    end

    #special syntax handling for axis scale
    #all the methods are declared at the same time;)
    #    [:xaxis, :yaxis, :x2axis, :y2axis].each do |method_name|
    #      define_method(method_name) do |*args|
    #        if (args.size == 1) and (args[0].is_a?(Hash)) then
    #          h = args[0]
    #          make_and_push_gle_line(method_name, :min, h[:min], :max, h[:max])
    #        else
    #          make_and_push_gle_line(method_name, args)
    #        end
    #      end
    #    end
    #
    #special syntax handling for axis scale
    #all the methods are declared at the same time;)
    def_each [:xaxis, :yaxis, :x2axis, :y2axis] do |method_name, *args|
      if (args.size == 1) and (args[0].is_a?(Hash)) then
        h = args[0]
        make_and_push_gle_line(method_name, :min, h[:min], :max, h[:max])
      else
        make_and_push_gle_line(method_name, args)
      end
    end

    def_each [:title, :xtitle, :ytitle, :x2title, :y2title] do |method_name, *args|
      
      if (args.size >= 1) and (args[0].is_a?(String)) then
        #quote the string unless the first and last chars are allready quotes
        
        args[0]=args[0].dump unless (args[0][0,1]=='"') and (args[0][-1,1]=='"')
      end
      make_and_push_gle_line(method_name, args)
    end

    def begin_graph(*args, &block)
      @cur_graph_number += 1
      @cur_in_graph = true

      make_and_push_graph_position(@cur_graph_number) if layout_set?

      push_to_gle_string("begin graph")

      do_indent
      make_and_push_gle_line(:size, @thumbsize[0], @thumbsize[1]) if layout_set?
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