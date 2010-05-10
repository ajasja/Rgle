
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
      @indent_count = 0;
    end

    def self.gle_layout &block
      gle_builder = new
      gle_builder.instance_eval &block
      return gle_builder
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
    def method_missing(sym, *args)      
      push_to_gle_string "#{sym} #{args.map{|a| a.to_s}.join(" ")}"      
    end

    def to_s
      @gle_string
    end

    def begin(sym, &block)
      
        push_to_gle_string("begin #{sym}")
        do_indent
        #instance_eval(&block) if block_given?
        yield if block_given?
        do_unindent
        push_to_gle_string("end #{sym}")
      end
    end
  end
