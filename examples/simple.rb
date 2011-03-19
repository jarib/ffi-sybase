$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'ffi-sybase'
require "pp"

unless ARGV.size == 3
  abort("USAGE: #{$PROGRAM_NAME} <db> <user> <pass>")
end

db, user, pass = *ARGV

Sybase::Client.new(db, :username => user, :password => pass) do |client|
  pp client.execute "sp_who"
end
