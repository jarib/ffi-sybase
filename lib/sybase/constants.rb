module Sybase
  DEFAULT_CTLIB_VERSION = 15000

  MAX_CHAR_BUF          = 1024

  CS_CONV_ERR           = -100
  CS_EXTERNAL_ERR       = -200
  CS_INTERNAL_ERR       = -300

  CS_TDS_40             = 7360
  CS_TDS_42             = 7361
  CS_TDS_46             = 7362
  CS_TDS_495            = 7363
  CS_TDS_50             = 7364

  CS_SET_FLAG           = 1700
  CS_CLEAR_FLAG         = 1701
  CS_DBG_ALL            = 1
  CS_DBG_ASYNC          = 2
  CS_DBG_ERROR          = 4

  CS_CLIENTMSG_CB       = 3
  CS_GET                = 33
  CS_MAX_CHAR           = 256
  CS_MAX_NAME           = 255
  CS_MAX_MSG            = 1024
  CS_MESSAGE_CB         = 9119
  CS_NULLTERM           = -9
  CS_SERVERMSG_CB       = 2
  CS_SET                = 34
  CS_SQLSTATE_SIZE      = 8
  CS_SUCCEED            = 1
  CS_FAIL               = 0
  CS_UNUSED             = -99999
  CS_CANCEL_CURRENT     = 6000
  CS_FMT_NULLTERM       = 1

  # server options
  CS_OPT_CHARSET        = 5010
  CS_OPT_PARSEONLY      = 5018

  # ct_command types
  CS_LANG_CMD           = 148
  CS_RPC_CMD            = 149
  CS_MSG_CMD            = 150
  CS_SEND_DATA_CMD      = 152

  # connection properties
  CS_USERNAME           = 9100
  CS_PASSWORD           = 9101
  CS_APPNAME            = 9102
  CS_HOSTNAME           = 9103
  CS_LOGIN_STATUS       = 9104
  CS_TDS_VERSION        = 9105
  CS_CHARSETCNV         = 9106
  CS_PACKETSIZE         = 9107
  CS_USERDATA           = 9108
  CS_COMMBLOCK          = 9109
  CS_NETIO              = 9110
  CS_NOINTERRUPT        = 9111
  CS_TEXTLIMIT          = 9112
  CS_HIDDEN_KEYS        = 9113
  CS_VERSION            = 9114
  CS_IFILE              = 9115
  CS_LOGIN_TIMEOUT      = 9116
  CS_TIMEOUT            = 9117
  CS_MAX_CONNECT        = 9118
  CS_EXPOSE_FMTS        = 9120
  CS_EXTRA_INF          = 9121
  CS_TRANSACTION_NAME   = 9122
  CS_ANSI_BINDS         = 9123
  CS_BULK_LOGIN         = 9124
  CS_LOC_PROP           = 9125
  CS_CUR_STATUS         = 9126
  CS_CUR_ID             = 9127
  CS_CUR_NAME           = 9128
  CS_CUR_ROWCOUNT       = 9129
  CS_PARENT_HANDLE      = 9130
  CS_EED_CMD            = 9131
  CS_DIAG_TIMEOUT       = 9132
  CS_DISABLE_POLL       = 9133
  CS_NOTIF_CMD          = 9134
  CS_SEC_ENCRYPTION     = 9135
  CS_SEC_CHALLENGE      = 9136
  CS_SEC_NEGOTIATE      = 9137
  CS_MEM_POOL           = 9138
  CS_USER_ALLOC         = 9139
  CS_USER_FREE          = 9140
  CS_ENDPOINT           = 9141
  CS_NO_TRUNCATE        = 9142
  CS_CON_STATUS         = 9143
  CS_VER_STRING         = 9144
  CS_ASYNC_NOTIFS       = 9145
  CS_SERVERNAME         = 9146

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
  CS_END_RESULTS        = CS_EXTERNAL_ERR - 5

  # ct_res_info
  CS_ROW_COUNT          = 800
  CS_NUMDATA            = 803
  CS_MSGTYPE            = 806
  CS_TRANS_STATE        = 808

  # ct_fetch
  CS_ROW_FAIL           = CS_EXTERNAL_ERR - 3
  CS_END_DATA           = CS_EXTERNAL_ERR - 4

  # data types
  CS_ILLEGAL_TYPE       = -1
  CS_CHAR_TYPE          = 0
  CS_BINARY_TYPE        = 1
  CS_LONGCHAR_TYPE      = 2
  CS_LONGBINARY_TYPE    = 3
  CS_TEXT_TYPE          = 4
  CS_IMAGE_TYPE         = 5
  CS_TINYINT_TYPE       = 6
  CS_SMALLINT_TYPE      = 7
  CS_INT_TYPE           = 8
  CS_REAL_TYPE          = 9
  CS_FLOAT_TYPE         = 10
  CS_BIT_TYPE           = 11
  CS_DATETIME_TYPE      = 12
  CS_DATETIME4_TYPE     = 13
  CS_MONEY_TYPE         = 14
  CS_MONEY4_TYPE        = 15
  CS_NUMERIC_TYPE       = 16
  CS_DECIMAL_TYPE       = 17
  CS_VARCHAR_TYPE       = 18
  CS_VARBINARY_TYPE     = 19
  CS_LONG_TYPE          = 20
  CS_SENSITIVITY_TYPE   = 21
  CS_BOUNDARY_TYPE      = 22
  CS_VOID_TYPE          = 23
  CS_USHORT_TYPE        = 24
  CS_UNICHAR_TYPE       = 25
  CS_BLOB_TYPE          = 26
  CS_DATE_TYPE          = 27
  CS_TIME_TYPE          = 28
  CS_UNITEXT_TYPE       = 29
  CS_BIGINT_TYPE        = 30
  CS_USMALLINT_TYPE     = 31
  CS_UINT_TYPE          = 32
  CS_UBIGINT_TYPE       = 33
  CS_XML_TYPE           = 34
end
