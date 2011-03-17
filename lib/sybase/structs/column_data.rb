module Sybase
  class ColumnData < FFI::Struct
    layout :indicator, :int,
           :value,     :pointer,
           :valuelen,  :int

    attr_accessor :read_method

    def value
      self[:value].__send__(read_method)
    end
  end
end
