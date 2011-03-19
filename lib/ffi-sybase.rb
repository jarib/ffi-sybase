#!/usr/bin/env ruby

require 'socket'
require 'ffi'

module Sybase
  class Error < StandardError; end
end

require "sybase/version"
require "sybase/constants"
require "sybase/structs/message"
require "sybase/structs/client_message"
require "sybase/structs/server_message"
require "sybase/structs/column_data"
require "sybase/structs/data_format"
require "sybase/lib"
require "sybase/context"
require "sybase/connection"
require "sybase/command"
