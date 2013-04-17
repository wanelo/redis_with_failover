module RedisWithFailover
  class Error < StandardError;
  end

  class Client
    attr_accessor :servers, :failure_callback

    EXCEPTIONS_TO_HANDLE = [Errno::ECONNREFUSED, Errno::ECONNRESET, Redis::BaseConnectionError]

    def initialize(options = {}, &block)
      self.failure_callback = block if block
      self.servers = options[:servers]
      raise ArgumentError.new if self.servers.nil? || self.servers.empty?
    end

    def method_missing(method, *args, &block)
      response = error = nil
      self.servers.each do |server|
        begin
          error = nil
          response = server.send(method, *args, &block)
          break
        rescue *EXCEPTIONS_TO_HANDLE => e
          failure_callback.call(server) if failure_callback
          error = e
        end
      end
      raise(error) if error
      response
    end
  end
end
