module NullStatsd
  class Statsd
    attr_accessor :namespace, :host, :port, :logger

    def initialize(host:, port:, logger:)
      @host = host
      @port = port
      @namespace = ""
      @logger = logger
      @logger.debug "Connecting to fake Statsd, pretending to be on #{host}:#{port}"
    end

    def increment(stat, _opts = {})
      logger.debug "#{identifier_string} Incrementing #{stat}"
    end

    def decrement(stat, _opts = {})
      logger.debug "[#{identifier_string} Deccrementing #{stat}"
    end

    def count(stat, count, _opts = {})
      logger.debug "#{identifier_string} Increasing #{stat} by #{count}"
    end

    def gauge(stat, value, _opts = {})
      logger.debug "#{identifier_string} Setting gauge #{stat} to #{value}"
    end

    def histogram(stat, value, _opts = {})
      logger.debug "#{identifier_string} Logging histrogram #{stat} -> #{value}"
    end

    def timing(stat, ms, _sample_rate = 1)
      logger.debug "#{identifier_string} Timing #{stat} at #{ms} ms"
    end

    def set(stat, value, _opts = {})
      logger.debug "#{identifier_string} Setting #{stat} to #{value}"
    end

    def service_check(name, _status, _opts = {})
      logger.debug "#{identifier_string} Service check #{name}: #{status}"
    end

    def event(title, text, _opts = {})
      logger.debug "#{identifier_string} Event #{title}: #{text}"
    end

    def close
      logger.debug "Close called"
    end

    def batch
      yield self
    end

    def time(stat, _opts = {})
      time_in_sec, result = benchmark { yield }
      logger.debug "#{identifier_string} Recording timing info in #{stat} -> #{time_in_sec} sec"
      result
    end

    def with_namespace(namespace)
      new_ns = dup
      if @namespace.blank?
        new_ns.namespace = namespace
      else
        new_ns.namespace = "#{@namespace}.#{namespace}"
      end
      if block_given?
        yield new_ns
      else
        new_ns
      end
    end

    private

    def identifier_string
      "[NullStatsD #{@host}:#{@port}-#{@namespace}]"
    end

    def benchmark(&block)
      start = Time.now
      result = block.call
      elapsed_time = Time.now - start
      return elapsed_time, result
    end
  end
end
