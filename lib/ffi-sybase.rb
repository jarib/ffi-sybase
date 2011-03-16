#!/usr/bin/env ruby

require 'ffi'

module Sybase
  class Error < StandardError; end

  DEFAULT_CTLIB_VERSION = 15000

  CS_CLIENTMSG_CB       = 3
  CS_GET                = 33
  CS_MAX_CHAR           = 256
  CS_MAX_MSG            = 1024
  CS_MESSAGE_CB         = 9119
  CS_NULLTERM           = -9
  CS_SERVERMSG_CB       = 2
  CS_SET                = 34
  CS_SQLSTATE_SIZE      = 8
  CS_SUCCEED            = 1
  CS_UNUSED             = -99999
  CS_CANCEL_CURRENT     = 6000

  # connection properties
  CS_USERNAME           = 9100
  CS_PASSWORD           = 9101
  CS_APPNAME            = 9102
  CS_HOSTNAME           = 9103
  CS_CHARSETCNV         = 9106
  CS_SERVERNAME         = 9146

  # server options
  CS_OPT_CHARSET        = 5010
  CS_OPT_PARSEONLY      = 5018

  # ct_command types
  CS_LANG_CMD           = 148
  CS_RPC_CMD            = 149
  CS_MSG_CMD            = 150
  CS_SEND_DATA_CMD      = 152
  CS_SEND_BULK_CMD      = 153

  # ct_results
  CS_ROW_RESULT         = 4040
  CS_CURSOR_RESULT      = 4041
  CS_PARAM_RESULT       = 4042
  CS_STATUS_RESULT      = 4043
  CS_MSG_RESULT         = 4044
  CS_COMPUTE_RESULT     = 4045
  CS_CMD_DONE           = 4046
  CS_CMD_SUCCEED        = 4047
  CS_CMD_FAIL           = 4048
  CS_ROWFMT_RESULT      = 4049
  CS_COMPUTEFMT_RESULT  = 4050
  CS_DESCRIBE_RESULT    = 4051

  # ct_res_info
  CS_ROW_COUNT = 800
  CS_MSGTYPE   = 806
  CS_NUMDATA   = 803
end

require "sybase/version"
require "sybase/structs/message"
require "sybase/structs/client_message"
require "sybase/structs/server_message"
require "sybase/lib"
require "sybase/context"
require "sybase/connection"
require "sybase/command"