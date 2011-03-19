module Sybase
  class Connection
    PROPERTIES = {
      :username    => [ CS_USERNAME,    :string ],
      :password    => [ CS_PASSWORD,    :string ],
      :appname     => [ CS_APPNAME,     :string ],
      :tds_version => [ CS_TDS_VERSION, :int    ],
      :hostname    => [ CS_HOSTNAME,    :string ]
    }


    def initialize(context, opts ={})
      @context = context

      FFI::MemoryPointer.new(:pointer) { |ptr|
        Lib.check Lib.ct_con_alloc(context, ptr), "ct_con_alloc"
        @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:ct_con_drop))
      }

      opts.each do |key, value|
        self[key] = value
      end

      unless opts.has_key?(:hostname)
        self[:hostname] = Socket.gethostname
      end
    end

    def debug!
      Lib.check Lib.ct_debug(@context, to_ptr, CS_SET_FLAG, CS_DBG_ALL, nil, CS_UNUSED)
    end

    def close
      Lib.check Lib.ct_close(@ptr, CS_UNUSED), "ct_close"
    end

    def [](key)
      property, type = property_type_for(key)
      case type
      when :string
        get_string_property property
      when :int
        get_int_property property
      end
    end

    def []=(key, value)
      property, type = property_type_for(key)

      case type
      when :string
        set_string_property property, value
      when :int
        set_int_property property, value
      else
        raise Error, "invalid type: #{type.inspect}"
      end
    end

    def property_type_for(key)
      PROPERTIES.fetch(key) { |key|
        raise ArgumentError, "invalid option: #{key.inspect}, expected one of #{PROPERTIES.keys.inspect}"
      }
    end

    def username=(user)
      set_string CS_USERNAME, user
    end

    def username
      get_string CS_USERNAME
    end

    def password=(password)
      set_string CS_PASSWORD, password
    end

    def password
      get_string CS_PASSWORD
    end

    def appname=(name)
      set_string CS_APPNAME, name
    end

    def appname
      get_string CS_APPNAME, name
    end

    def connect(server)
      server = server.to_s
      Lib.check Lib.ct_connect(@ptr, server,  server.bytesize), "connect(#{server.inspect}) failed"
    end

    def to_ptr
      @ptr
    end

    private

    def set_string_property(property, string)
      Lib.check Lib.ct_con_props(@ptr, CS_SET, property, string.to_s, CS_NULLTERM, nil), "ct_con_prop(#{property} => #{string.inspect}) failed"
    end

    def get_string_property(property)
      FFI::MemoryPointer.new(:string) { |ptr| get_property(property, ptr) }.read_string
    end

    def get_int_property(property)
      FFI::MemoryPointer.new(:int) { |ptr| get_property(property, ptr) }.read_int
    end

    def set_int_property(property, int)
      ptr = FFI::MemoryPointer.new(:int)
      ptr.write_int(int)

      Lib.check Lib.ct_con_props(@ptr, CS_SET, property, ptr, CS_UNUSED, nil), "ct_con_prop(#{property} => #{int.inspect}) failed"
    end

    def get_property(property, ptr)
      Lib.check Lib.ct_con_props(@ptr, CS_GET, property, ptr, CS_UNUSED, nil), "ct_con_prop(CS_GET, #{property}) failed"
    end
  end # Connection
end # Sybase