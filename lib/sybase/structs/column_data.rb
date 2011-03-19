module Sybase
  class ColumnData
    attr_reader :pointer, :type, :format

    def initialize
      @pointer = nil
      @type = nil
      @format = DataFormat.new
    end

    def inspect
      "#<#{self.class}:0x#{(hash*2).to_s(16)} type=#{type.inspect} valuelen=#{valuelen} indicator=#{indicator}>"
    end

    def char_pointer!(size = 256)
      @type = :char
      @pointer = FFI::MemoryPointer.new(@type, size)
    end

    def int_pointer!
      @type = :int
      @pointer = FFI::MemoryPointer.new(@type)
    end

    def double_pointer!
      @type = :double
      @pointer = FFI::MemoryPointer.new(@type)
    end

    def valuelen_pointer
      @valuelen_ptr ||= FFI::MemoryPointer.new(:int)
    end

    def indicator_pointer
      @indicator_ptr ||= FFI::MemoryPointer.new(:int)
    end

    def valuelen
      valuelen_pointer.read_int
    end

    def indicator
      indicator_pointer.read_int
    end

    def value
      case @type
      when :int
        @pointer.read_int
      when :char
        @pointer.get_bytes(0, valuelen - 1)
      when :double
        @pointer.read_double
      else
        raise Error, "uknown type #{type}"
      end
    end

  end
end
