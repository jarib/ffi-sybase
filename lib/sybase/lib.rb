module Sybase
  module Lib
    extend FFI::Library

    if FFI.type_size(:pointer) == 8 && RUBY_PLATFORM !~ /darwin/i
      ffi_lib "sybct64"
    else
      ffi_lib "sybct"
    end

    # extern CS_RETCODE CS_PUBLIC cs_ctx_alloc PROTOTYPE((
    #     CS_INT version,
    #     CS_CONTEXT **outptr
    #     ));

    attach_function :cs_ctx_alloc, [:int, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC cs_ctx_drop PROTOTYPE((
    #     CS_CONTEXT *context
    #     ));

    attach_function :cs_ctx_drop, [:pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_init PROTOTYPE((
    #     CS_CONTEXT *context,
    #     CS_INT version
    #     ));

    attach_function :ct_init, [:pointer, :int], :int


    # extern CS_RETCODE CS_PUBLIC cs_config PROTOTYPE((
    #     CS_CONTEXT *context,
    #     CS_INT action,
    #     CS_INT property,
    #     CS_VOID *buf,
    #     CS_INT buflen,
    #     CS_INT *outlen
    #     ));

    attach_function :cs_config, [:pointer, :int, :int, :pointer, :int, :pointer], :int


    callback :cs_clientmsg_cb, [:pointer, :pointer, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_callback PROTOTYPE((
    #     CS_CONTEXT *context,
    #     CS_CONNECTION *connection,
    #     CS_INT action,
    #     CS_INT type,
    #     CS_VOID *func
    #     ));

    attach_function :ct_callback, [:pointer, :pointer, :int, :int, :cs_clientmsg_cb], :int

    # extern CS_RETCODE CS_PUBLIC ct_con_alloc PROTOTYPE((
    #     CS_CONTEXT *context,
    #     CS_CONNECTION **connection
    #     ));

    attach_function :ct_con_alloc, [:pointer, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_con_props PROTOTYPE((
    #     CS_CONNECTION *connection,
    #     CS_INT action,
    #     CS_INT property,
    #     CS_VOID *buf,
    #     CS_INT buflen,
    #     CS_INT *outlen
    #     ));

    attach_function :ct_con_props, [:pointer, :int, :int, :pointer, :int, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_connect PROTOTYPE((
    #     CS_CONNECTION *connection,
    #     CS_CHAR *server_name,
    #     CS_INT snamelen
    #     ));

    attach_function :ct_connect, [:pointer, :pointer, :int], :int

    # extern CS_RETCODE CS_PUBLIC ct_close PROTOTYPE((
    #     CS_CONNECTION *connection,
    #     CS_INT option
    #     ));

    attach_function :ct_close, [:pointer, :int], :int

    # extern CS_RETCODE CS_PUBLIC ct_cmd_alloc PROTOTYPE((
    #     CS_CONNECTION *connection,
    #     CS_COMMAND **cmdptr
    #     ));

    attach_function :ct_cmd_alloc, [:pointer, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_cmd_drop PROTOTYPE((
    #     CS_COMMAND *cmd
    #     ));

    attach_function :ct_cmd_drop, [:pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_cmd_props PROTOTYPE((
    #     CS_COMMAND *cmd,
    #     CS_INT action,
    #     CS_INT property,
    #     CS_VOID *buf,
    #     CS_INT buflen,
    #     CS_INT *outlen
    #     ));

    attach_function :ct_cmd_props, [:pointer, :int, :int, :pointer, :int, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_command PROTOTYPE((
    #     CS_COMMAND *cmd,
    #     CS_INT type,
    #     CS_CHAR *buf,
    #     CS_INT buflen,
    #     CS_INT option
    #     ));

    attach_function :ct_command, [:pointer, :int, :string, :int, :int], :int

    # extern CS_RETCODE CS_PUBLIC ct_send PROTOTYPE((
    #     CS_COMMAND *cmd
    #     ));

    attach_function :ct_send, [:pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_results PROTOTYPE((
    #     CS_COMMAND *cmd,
    #     CS_INT *result_type
    #     ));

    attach_function :ct_results, [:pointer, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_close PROTOTYPE((
    #     CS_CONNECTION *connection,
    #     CS_INT option
    #     ));

    attach_function :close, [:pointer, :int], :int

    # extern CS_RETCODE CS_PUBLIC ct_exit PROTOTYPE((
    #     CS_CONTEXT *context,
    #     CS_INT option
    #     ));

    attach_function :ct_exit, [:pointer, :int], :int

    # extern CS_RETCODE CS_PUBLIC ct_con_drop PROTOTYPE((
    #     CS_CONNECTION *connection
    #     ));

    attach_function :ct_con_drop, [:pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_cancel PROTOTYPE((
    #   CS_CONNECTION *connection,
    #   CS_COMMAND *cmd,
    #   CS_INT type
    #   ));

    attach_function :ct_cancel, [:pointer, :pointer, :int], :int

    # extern CS_RETCODE CS_PUBLIC ct_res_info PROTOTYPE((
    #   CS_COMMAND *cmd,
    #   CS_INT operation,
    #   CS_VOID *buf,
    #   CS_INT buflen,
    #   CS_INT *outlen
    #   ));

    attach_function :ct_res_info, [:pointer, :int, :pointer, :int, :pointer], :int


    # extern CS_RETCODE CS_PUBLIC ct_describe PROTOTYPE((
    #     CS_COMMAND *cmd,
    #     CS_INT item,
    #     CS_DATAFMT *datafmt
    #     ));

    attach_function :ct_describe, [:pointer, :int, :pointer], :int

    def self.check(code, msg = "error")
      if code != CS_SUCCEED
        raise Error, msg
      end
    end
  end # Lib
end # Sybase
