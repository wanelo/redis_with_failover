module RedisWithFailover
  class Error < StandardError;
  end

  class Client
    attr_accessor :servers, :failover_callback

    EXCEPTIONS_TO_HANDLE = [Errno::ECONNREFUSED, Errno::ECONNRESET, Redis::BaseConnectionError]

    def initialize(options = {}, &block)
      self.failover_callback = block if block
      self.servers = options[:servers]
      raise ArgumentError.new if self.servers.nil? || self.servers.empty?
    end

    def method_missing(method, *args, &block)
      response = nil
      error = nil
      self.servers.each do |server|
        begin
          response = server.send(method, *args, &block)
          break
        rescue *EXCEPTIONS_TO_HANDLE => e
          failover_callback.call(server) if failover_callback
          error = e
        end
      end
      raise(error) unless response
      response
    end
  end
end
