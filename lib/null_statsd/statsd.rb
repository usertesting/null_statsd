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
      notify "Incrementing #{key(stat, _opts)}"
    end

    def decrement(stat, _opts = {})
      notify "Decrementing #{key(stat, _opts)}"
    end

    def count(stat, count, _opts = {})
      notify "Increasing #{key(stat, _opts)} by #{count}"
    end

    def gauge(stat, value, _opts = {})
      notify "Setting gauge #{key(stat, _opts)} to #{value}"
    end

    def histogram(stat, value, _opts = {})
      notify "Logging histrogram #{key(stat, _opts)} -> #{value}"
    end

    def timing(stat, ms, _sample_rate = 1)
      notify "Timing #{stat} at #{ms} ms"
    end

    def set(stat, value, _opts = {})
      notify "Setting #{key(stat, _opts)} to #{value}"
    end

    def service_check(name, status, _opts = {})
      notify "Service check #{key(name, _opts)}: #{status}"
    end

    def event(title, text, _opts = {})
      notify "Event #{key(title, _opts)}: #{text}"
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

    # returns string looking like one of:
    # - arg1
    # - arg1|arg2
    # - arg|optkey1:optval1|optkey2:optval2
    # - arg1|arg2|optkey1:optval1
    # - arg|optkey1:optval1;optval2
    def key *args
      args.compact.map do |arg|
        # map hashes to nicer formatting for logging - key1:val1|key2:val2
        if arg.respond_to?(:key)
          stringify_hash(arg)
        else
          arg
        end
      end.join('|')
    end

    def stringify_hash h
      h.map do |key, val|
        value = val.respond_to?(:map) ? stringify_array(val) : val
        "#{key}:#{value}"
      end.join('|')
    end

    def stringify_array a
      a.join(',')
    end
  end
end
