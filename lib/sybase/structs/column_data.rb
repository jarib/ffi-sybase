module Sybase
  class ColumnData < FFI::Struct
    layout :indicator, :int,
           :value,     :pointer,
           :valuelen,  :int

     def value
       self[:value].read_string
     end
  end
end