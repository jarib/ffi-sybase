module Sybase
  class Client
    
    attr_reader :messages
    
    #
    # Create a new client for the given database name
    # 
    
    def initialize(db, opts = {})
      @context = Context.new
      
      @messages = Messages.new # TODO: listener?
      @context.callbacks.library { |msg| @messages.on_message :library, msg }
      @context.callbacks.client  { |msg| @messages.on_message :client,  msg }
      @context.callbacks.server  { |msg| @messages.on_message :server,  msg }
      
      
      @connection = Connection.new(@context,
        :username => opts.fetch(:username) { raise ArgumentError, "no :username given" },
        :password => opts.fetch(:password) { raise ArgumentError, "no :password given" },
        :appname  => opts.fetch(:appname)  { "#{self.class} #{RUBY_DESCRIPTION}"       },
        :hostname => opts.fetch(:hostname) { Socket.gethostname }
      )
      
      @connection.connect db.to_s
      
      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end
    
    def execute(sql)
      results = Command.new(@connection, sql).execute
      results.find { |e| e.type == :row }.as_json
    end
    
    def close
      @connection.close if @connection
      @context.exit
    end
    
    class Messages
      def initialize
        @messages = Hash.new { |hash, key| hash[key] = [] }
      end
      
      def on_message(type, msg)
        @messages[type] << msg
      end
      
      def messages_for(type)
        @messages[type]
      end
      
      def messages
        @messages.values.flatten
      end
      
      def reset!
        @messages.clear
      end
    end # Messages
  end # Client
end # Sybase