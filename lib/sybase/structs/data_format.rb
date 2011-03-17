module Sybase

  # typedef struct _cs_datafmt
  # {
  #   CS_CHAR   name[CS_MAX_NAME]; // CS_MAX_CHAR if >= Sybase 15
  #   CS_INT    namelen;
  #   CS_INT    datatype;
  #   CS_INT    format;
  #   CS_INT    maxlength;
  #   CS_INT    scale;
  #   CS_INT    precision;
  #   CS_INT    status;
  #   CS_INT    count;
  #   CS_INT    usertype;
  #   CS_LOCALE *locale;
  # } CS_DATAFMT;


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
