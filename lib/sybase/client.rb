module Sybase
  class Client

    attr_reader :context, :connection, :messages

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
      build_result { |res| res << Command.new(@connection, sql).execute }
    end

    def close
      @connection.close if @connection
      @context.exit
    end

    private

    def build_result
      res = ResultBuilder.new
      @messages.reset!

      res.start
      begin
        yield res
      ensure
        res.stop
        res.messages = @messages.messages
      end

      res
    end

    class ResultBuilder
      attr_accessor :messages

      def start
        @started_at = Time.now
      end

      def stop
        @elapsed = Time.now - @started_at
      end

      def <<(res)
        (@results ||= []) << res
      end

      def result_set

      end
    end

    class Messages
      def initialize
        # TODO: order is important
        @messages = Hash.new { |hash, key| hash[key] = [] }
      end

      def any?
        @messages.any?
      end

      def on_message(type, msg)
        @messages[type] << msg.to_s
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

      def to_s
        messages.join("\n")
      end

    end # Messages
  end # Client
end # Sybase