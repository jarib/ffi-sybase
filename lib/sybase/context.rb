module Sybase
  class Context
    def initialize(version = DEFAULT_CTLIB_VERSION)
      @version = Integer(version)

      ptr = FFI::MemoryPointer.new(:pointer)
      Lib.check Lib.cs_ctx_alloc(@version, ptr), "cs_ctx_alloc failed"
      @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:cs_ctx_drop))
    end

    def to_ptr
      @ptr
    end

    def init
      Lib.check Lib.ct_init(@ptr, @version), "ct_init failed"
      self
    end

    def exit
      Lib.check Lib.ct_exit(@ptr, CS_UNUSED), "ct_exit failed"
    end
  end # Context
end # Sybase