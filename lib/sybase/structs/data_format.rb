module Sybase
  class DataFormat < FFI::Struct
    attr_accessor :ruby_type

    layout :name,       [:char, CS_MAX_CHAR],
           :namelen,    :int,
           :datatype,   :int,
           :format,     :int,
           :maxlength,  :int,
           :scale,      :int,
           :precision,  :int,
           :status,     :int,
           :count,      :int,
           :usertype,   :int,
           :locale,     :pointer

    INTS = [:namelen, :datatype, :format, :maxlength, :scale, :precision, :status, :count, :usertype]

    def reset!
      INTS.each { |key| self[key] = 0 }
    end

    def inspect
      "#<%s name=%s namelen=%d datatype=%d format=%d maxlength=%d scale=%d precision=%d status=%d count=%d usertype=%d locale=%s>" % [
        self.class.name,
        name.inspect,
        self[:namelen],
        self[:datatype],
        self[:format],
        self[:maxlength],
        self[:scale],
        self[:precision],
        self[:status],
        self[:count],
        self[:usertype],
        self[:locale].inspect
      ]
    end

    def name
      self[:name].to_s
    end

  end
end
