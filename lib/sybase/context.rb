module Sybase
  class Context
    def initialize(version = DEFAULT_CTLIB_VERSION)
      @version = Integer(version)

      FFI::MemoryPointer.new(:pointer) do |ptr|
        Lib.check Lib.cs_ctx_alloc(@version, ptr), "cs_ctx_alloc failed"
        @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:cs_ctx_drop))
      end

      Lib.check Lib.ct_init(@ptr, @version), "ct_init failed"

      if block_given?
        begin
          yield self
        ensure
          exit
        end
      end
    end

    def sync=(bool)
      FFI::MemoryPointer.new(:int) do |ptr|
        ptr.write_int(bool ? CS_SYNC_IO : CS_ASYNC_IO) # CS_DEFER_IO ?
        Lib.check Lib.ct_config(@ptr, CS_SET, CS_NETIO, ptr, CS_UNUSED, nil)
      end
    end

    def callbacks
      @callbacks ||= Callbacks.new self
    end

    def to_ptr
      @ptr
    end

    def exit
      Lib.check Lib.ct_exit(@ptr, CS_UNUSED), "ct_exit failed"
    end

    private

    class Callbacks
      def initialize(context)
        @context = context
      end

      def library(&cb)
        actual_callback = FFI::Function.new(:int, [:pointer, :pointer]) { |context, message|
          cb.call ClientMessage.new(message)
          CS_SUCCEED
        }
        Lib.check Lib.cs_config(@context, CS_SET, CS_MESSAGE_CB, actual_callback, CS_UNUSED, nil)
      end

      def client(&cb)
        Lib.check Lib.ct_callback(@context, nil, CS_SET, CS_CLIENTMSG_CB, lambda { |context, connection, message|
          cb.call ClientMessage.new(message)
          CS_SUCCEED
        })
      end

      def server(&cb)
        Lib.check Lib.ct_callback(@context, nil, CS_SET, CS_SERVERMSG_CB, lambda { |context, connection, message|
            cb.call ServerMessage.new(message)
            CS_SUCCEED
        })
      end
    end # Callbacks
  end # Context
end # Sybase