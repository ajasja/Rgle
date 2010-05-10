
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
      class_eval &block
      return gle_builder
    end



    def method_missing(sym, *args)
      
      @gle_string << "#{sym} #{args.map{|a| a.to_s}.join(" ")}\n"
      #send(sym, *args)
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
