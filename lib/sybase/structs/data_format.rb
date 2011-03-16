module Sybase
  class DataFormat < FFI::Struct
     layout :name,       [:char, CS_MAX_CHAR],
            :namelen,    :int,
            :datatype,   :int,
            :format,    :int,
            :maxlength,  :int,
            :scale,      :int,
            :precision,  :int,
            :status,     :int,
            :count,      :int,
            :usertype,   :int,
            :locale,     :pointer

     def name
       self[:name].to_s
     end
   end
end