#!/usr/bin/env ruby

require 'ffi'

module Sybase
  EX_CTLIB_VERSION = 15000
  CS_SUCCESS = 1
  CS_UNUSED = -99999
  CS_GET = 33
  CS_SET = 34
  CS_MESSAGE_CB = 9119
  CS_CLIENTMSG_CB = 3
  CS_SERVERMSG_CB = 2
  CS_NULLTERM = -9
  CS_MAX_MSG = 1024
  CS_MAX_CHAR = 256
  CS_SQLSTATE_SIZE = 8

  # connection properties
  CS_USERNAME = 9100
  CS_PASSWORD  = 9101
  CS_APPNAME = 9102
  CS_HOSTNAME = 9103
  CS_CHARSETCNV = 9106
  CS_SERVERNAME = 9146

  # server options
  CS_OPT_CHARSET = 5010
  CS_OPT_PARSEONLY = 5018

  # ct_command types

  CS_LANG_CMD = 148
  CS_RPC_CMD = 149
  CS_MSG_CMD = 150
  CS_SEND_DATA_CMD = 152
  CS_SEND_BULK_CMD = 153

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

  # typedef struct _cs_clientmsg
  # {
  #   CS_INT          severity;
  #   CS_MSGNUM       msgnumber;
  #   CS_CHAR         msgstring[CS_MAX_MSG];
  #   CS_INT          msgstringlen;
  #   CS_INT          osnumber;
  #   CS_CHAR         osstring[CS_MAX_MSG];
  #   CS_INT          osstringlen;
  #   CS_INT          status;
  #   CS_BYTE         sqlstate[CS_SQLSTATE_SIZE];
  #   CS_INT          sqlstatelen;
  # } CS_CLIENTMSG;


  class ClientMessage < Message
    layout :severity,     :int,
           :msgnumber,    :uint,
           :msgstring,    [:char, CS_MAX_MSG],
           :msgstringlen, :int,
           :osnumber,     :int,
           :osstring,     [:char, CS_MAX_MSG],
           :osstringlen,  :int,
           :status,       :int,
           :sqlstate,     [:uchar, CS_SQLSTATE_SIZE],
           :sqlstatelen,  :int

    def text
      self[:msgstring].to_s
    end

  end

  # typedef struct _cs_servermsg
  # {
  #   CS_MSGNUM msgnumber;
  #   CS_INT            state;
  #   CS_INT            severity;
  #   CS_CHAR           text[CS_MAX_MSG];
  #   CS_INT            textlen;
  #   CS_CHAR           svrname[CS_MAX_CHAR];
  #   CS_INT            svrnlen;
  #   CS_CHAR           proc[CS_MAX_CHAR];
  #   CS_INT            proclen;
  #   CS_INT            line;
  #   CS_INT            status;
  #   CS_BYTE           sqlstate[CS_SQLSTATE_SIZE];
  #   CS_INT            sqlstatelen;
  # } CS_SERVERMSG;

  class ServerMessage < Message
    layout :msgnumber,   :uint,
           :state,       :int,
           :severity,    :int,
           :text,        [:char, CS_MAX_MSG],
           :textlen,     :int,
           :svrname,     [:char, CS_MAX_CHAR],
           :svrnlen,     :int,
           :proc,        [:char, CS_MAX_CHAR],
           :proclen,     :int,
           :line,        :int,
           :status,      :int,
           :sqlstate,    [:uchar, CS_SQLSTATE_SIZE],
           :sqlstatelen, :int

    def text
      self[:text].to_s
    end
  end

  module Lib
    extend FFI::Library

    if FFI.type_size(:pointer) == 8
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

   def self.check_code(code, msg = "error")
     if code != CS_SUCCESS
       # TODO: error class
       raise msg
     end
   end
  end # Lib

  class Context 
    def initialize
      ptr = FFI::MemoryPointer.new(:pointer)
      Lib.check_code Lib.cs_ctx_alloc(EX_CTLIB_VERSION, ptr), "cs_ctx_alloc"
      @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:cs_ctx_drop))
    end

    def to_ptr
      @ptr
    end

    def init
      Lib.check_code Lib.ct_init(@ptr, EX_CTLIB_VERSION), "ct_init"
      self
    end

    def exit
      Lib.check_code Lib.ct_exit(@ptr, CS_UNUSED), "ct_exit"
    end
  end # Context

  class Connection
    def initialize(context)
      ptr = FFI::MemoryPointer.new(:pointer)
      Lib.check_code Lib.ct_con_alloc(context, ptr), "ct_con_alloc"
      @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:ct_con_drop))
    end

    def close
      Lib.check_code Lib.ct_close(@ptr, CS_UNUSED), "ct_close"
    end

    def username=(user)
      set_property CS_USERNAME, user.to_s
    end

    def password=(password)
      set_property CS_PASSWORD, password.to_s
    end

    def appname=(name)
      set_property CS_APPNAME, name.to_s
    end

    def connect(server)
      Lib.check_code Lib.ct_connect(@ptr, server,  server.length), "connect(#{server.inspect})"
    end

    def to_ptr
      @ptr
    end

    private

    def set_property(property, string)
      Lib.check_code Lib.ct_con_props(@ptr, CS_SET, property, string, CS_NULLTERM, nil), "ct_con_prop(#{property} => #{string.inspect})"
    end
  end # Connection

  class Command

    def initialize(connection)
      ptr = FFI::MemoryPointer.new(:pointer)
      Lib.check_code Lib.ct_cmd_alloc(connection, ptr), "ct_cmd_alloc"

      @ptr = FFI::AutoPointer.new(ptr.read_pointer, Lib.method(:ct_cmd_drop))
    end

    # not sure this is the right API
    def query=(str)
      Lib.check_code Lib.ct_command(@ptr, CS_LANG_CMD, str.to_s, CS_NULLTERM, CS_UNUSED)
    end

    def send
      Lib.check_code Lib.ct_send(@ptr), "ct_send"
    end

    # temporary
    def show_results
      intptr = FFI::MemoryPointer.new(:int)
      while Lib.ct_results(@ptr, intptr) == CS_SUCCESS # succeed vs success?
        p :result => intptr.read_int
      end
    end

    def to_ptr
      @ptr
    end
  end # Command


  def self.test
    context = Context.new.init
    begin
      cs_msg_callback = FFI::Function.new(:int, [:pointer, :pointer]) do |ctx, client_message|
        msg = ClientMessage.new(client_message)
        p :cs_msg_callback => [ctx, msg, msg.message]
        CS_SUCCESS
      end

      clientmsg_callback = Proc.new { |ctx, conn, msg|
        message = ClientMessage.new(msg)
        p :clientmsg_callback => [ctx, conn, message]
        CS_SUCCESS
      }

      servermsg_callback = Proc.new { |ctx, conn, msg|
        p :servermsg_callback => [ctx, conn, ServerMessage.new(msg)]
        CS_SUCCESS
      }

      Lib.check_code Lib.cs_config(context, CS_SET, CS_MESSAGE_CB, cs_msg_callback, CS_UNUSED, nil), "cs_config(CS_MESSAGE_CB)"
      Lib.check_code Lib.ct_callback(context, nil, CS_SET, CS_CLIENTMSG_CB, clientmsg_callback), "ct_callback for client messages"
      Lib.check_code Lib.ct_callback(context, nil, CS_SET, CS_SERVERMSG_CB, servermsg_callback), "ct_callback for server messages"

      connection = Connection.new(context)
      connection.username = "foo"
      connection.password = "bar"
      connection.connect "db1"

      cmd = Command.new(connection)
      cmd.query = "select * from foo where bar = 'foo'"
      cmd.send
      cmd.show_results

      connection.close
    ensure
      context.exit
    end
  end

end

if __FILE__ == $0
  Sybase.test
end
