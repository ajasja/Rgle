class Module

end
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

    #adda a method which jiust joins all its arguments as string
    def define_general_build_method(*symbols)
      symbols.each do |sym|
        puts "#{self.inspect} definign #{sym}"
        class_eval %{
        def #{sym}(*args)

          puts #{sym}
        end
        }
      end # symbols
    end

    def method_missing(sym, *args)
      puts "Method #{sym} is missing with args #{args.map{|a| a.to_s}.join(" ")}"
      self.define_general_build_method sym
      #send(sym, *args)
    end

    def to_s
      @gle_string
    end

    def beg(sym)
      puts "begin #{sym}"
      yield
      puts "end #{sym}"
    end
  end
end
