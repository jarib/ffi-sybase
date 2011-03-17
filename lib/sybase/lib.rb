module Sybase
  module Lib
    extend FFI::Library

    suffix = RUBY_VERSION < '1.9' ? '' : '_r'

    if FFI.type_size(:pointer) == 8
      ffi_lib "sybct64#{suffix}"
    else
      ffi_lib "sybct#{suffix}"
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

    # extern CS_RETCODE CS_PUBLIC ct_bind PROTOTYPE((
    #   CS_COMMAND *cmd,
    #   CS_INT item,
    #   CS_DATAFMT *datafmt,
    #   CS_VOID *buf,
    #   CS_INT *outputlen,
    #   CS_SMALLINT *indicator
    #   ));

    attach_function :ct_bind, [:pointer, :int, :pointer, :pointer, :pointer, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_fetch PROTOTYPE((
    #   CS_COMMAND *cmd,
    #   CS_INT type,
    #   CS_INT offset,
    #   CS_INT option,
    #   CS_INT *count
    #   ));

    attach_function :ct_fetch, [:pointer, :int, :int, :int, :pointer], :int

    # extern CS_RETCODE CS_PUBLIC ct_debug PROTOTYPE((
    #     CS_CONTEXT *context,
    #     CS_CONNECTION *connection,
    #     CS_INT operation,
    #     CS_INT flag,
    #     CS_CHAR *filename,
    #     CS_INT fnamelen
    #     ));

    attach_function :ct_debug, [:pointer, :pointer, :int, :int, :pointer, :int], :int

    def self.check(code, msg = "error")
      if code != CS_SUCCEED
        raise Error, msg
      end
    end

    def self.display_length(data_format)
      len = case data_format[:datatype]
            when CS_CHAR_TYPE, CS_LONGCHAR_TYPE, CV_VARCHAR_TYPE, CS_TEXT_TYPE, CS_IMAGE_TYPE
              [data_format[:maxlength], MAX_CHAR_BUF].min
            when CS_UNICHAR_TYPE
              [data_format[:maxlength] / 2, MAX_CHAR_BUF].min
            when CS_BINARY_TYPE, CS_VARBINARY_TYPE
              [(2 * data_format[:maxlength]) + 2, MAX_CHAR_BUF].min
            when CS_BIT_TYPE, CS_TINYINT_TYPE
              3
            when CS_SMALLINT_TYPE
              6
            when CS_INT_TYPE
              11
            when CS_REAL_TYPE, CS_FLOAT_TYPE
              20
            when CS_MONEY_TYPE, CS_MONEY4_TYPE
              24
            when CS_DATETIME_TYPE, CS_DATETIME4_TYPE
              30
            when CS_NUMERIC_TYPE, CS_DECIMAL_TYPE
              CS_MAX_PREC + 2
            else
              12
            end


      [data_format[:name].size + 1, len].max
    end
  end # Lib
end # Sybase
