module Sybase
  class Message < FFI::Struct
    def severity
      (self[:severity] >> 8) & 0xff
    end

    def number
      self[:msgnumber] & 0xff
    end

    def origin
      (self[:msgnumber]) >> 16 & 0xff
    end

    def layer
      (self[:msgnumber] >> 24) & 0x44
    end

    def inspect
      "#<%s text=%s severity=%d number=%d origin=%d layer=%d>" % [self.class.name, text.inspect, severity, number, origin, layer]
    end

    def to_s
      "%s (severity=%d number=%d origin=%d layer=%d)" % [text, severity, number, origin, layer]
    end
  end
end