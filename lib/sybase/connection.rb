module Sybase
  class Connection
    def initialize(context)
      ptr = FFI::MemoryPointer.new(:pointer)
      Lib.check Lib.ct_con_alloc(context, ptr), "ct_con_alloc"
      @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:ct_con_drop))
    end

    def close
      Lib.check Lib.ct_close(@ptr, CS_UNUSED), "ct_close"
    end

    def username=(user)
      set_property CS_USERNAME, user
    end

    def password=(password)
      set_property CS_PASSWORD, password
    end

    def appname=(name)
      set_property CS_APPNAME, name
    end

    def connect(server)
      Lib.check Lib.ct_connect(@ptr, server,  server.bytesize), "connect(#{server.inspect})"
    end

    def to_ptr
      @ptr
    end

    private

    def set_property(property, string)
      Lib.check Lib.ct_con_props(@ptr, CS_SET, property, string.to_s, CS_NULLTERM, nil), "ct_con_prop(#{property} => #{string.inspect})"
    end
  end # Connection
end # Sybase