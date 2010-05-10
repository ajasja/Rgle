
module RGle
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
      @gle_string << str + "\n"
    end
    def method_missing(sym, *args)      
      push_to_gle_string "#{sym} #{args.map{|a| a.to_s}.join(" ")}"
      
    end

    def to_s
      @gle_string
    end

    def begin(sym)
      puts "begin #{sym}"
      puts yield if block_given?
      puts "end #{sym}"
    end
  end
end
