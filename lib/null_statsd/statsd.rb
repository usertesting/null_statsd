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

    def increment(stat, opts = {})
      notify "Incrementing #{stat} with #{stringify_hash(opts)}"
    end

    def decrement(stat, opts = {})
      notify "Decrementing #{stat} with #{stringify_hash(opts)}"
    end

    def count(stat, count, opts = {})
      notify "Increasing #{stat} by #{count} with #{stringify_hash(opts)}"
    end

    def gauge(stat, value, opts = {})
      notify "Setting gauge #{stat} to #{value} with #{stringify_hash(opts)}"
    end

    def histogram(stat, value, opts = {})
      notify "Logging histogram #{stat} -> #{value} with #{stringify_hash(opts)}"
    end

    def timing(stat, ms, _sample_rate = 1, opts = {})
      notify "Timing #{stat} at #{ms} ms with #{stringify_hash(opts)}"
    end

    def set(stat, value, opts = {})
      notify "Setting #{stat} to #{value} with #{stringify_hash(opts)}"
    end

    def service_check(name, status, opts = {})
      notify "Service check #{name}: #{status} with #{stringify_hash(opts)}"
    end

    def event(title, text, opts = {})
      notify "Event #{title}: #{text} with #{stringify_hash(opts)}"
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

    def notify msg
      logger.debug "#{identifier_string} #{msg}"
    end

    def stringify_hash h
      h.map do |key, val|
        value = val.respond_to?(:map) ? val.join(',') : val
        "#{key}:#{value}"
      end.join('|')
    end
  end
end
