$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'pp'
require 'ffi-sybase'

unless ARGV.size == 3
  abort("USAGE: #{$PROGRAM_NAME} <db> <user> <pass>")
end

db, user, pass = *ARGV

Sybase::Context.new do |ctx|
  ctx.callbacks.library { |message| puts "library : #{message}"  }
  ctx.callbacks.client  { |message| puts "client  : #{message}"  }
  ctx.callbacks.server  { |message| puts "server  : #{message}"  }

  Sybase::Connection.new(ctx, :username => user, :password => pass) do |conn|
    conn.connect db
    pp Sybase::Command.new(conn, "sp_who").execute
  end
end