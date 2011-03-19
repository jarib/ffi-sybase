$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'ffi-sybase'
require "pp"
unless ARGV.size == 3
  abort("USAGE: #{$PROGRAM_NAME} <db1,db2> <user> <pass>")
end

dbs, user, pass = *ARGV

Sybase::Context.new do |ctx|
  ctx.callbacks.library { |message| puts "library : #{message}"  }
  ctx.callbacks.client  { |message| puts "client  : #{message}"  }
  ctx.callbacks.server  { |message| puts "server  : #{message}"  }

  connections = []
  dbs.split(',').each do |db|
    connections << Sybase::Connection.new(ctx, :username => user, :password => pass).connect(db)
  end
  
  connections.each do |conn|
    p Sybase::Command.new(conn, "sp_who").execute.size
  end
end