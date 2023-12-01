require "json"

module NullStatsd
  class Statsd
    attr_accessor :namespace, :host, :port, :logger

    def initialize(host:, port:, logger:)
      @host = host
      @port = port
      @namespace = ""
      @logger = logger
      notify "Connecting to fake Statsd, pretending to be on #{host}:#{port}"
    end

    def increment(stat, opts = {})
      notify "Incrementing #{stat}#{opts_string(opts)}"
    end

    def decrement(stat, opts = {})
      notify "Decrementing #{stat}#{opts_string(opts)}"
    end

    def count(stat, count, opts = {})
      notify "Increasing #{stat} by #{count}#{opts_string(opts)}"
    end

    def gauge(stat, value, opts = {})
      notify "Setting gauge #{stat} to #{value}#{opts_string(opts)}"
    end

    def histogram(stat, value, opts = {})
      notify "Logging histogram #{stat} -> #{value}#{opts_string(opts)}"
    end

    def timing(stat, ms, _sample_rate = 1, opts = {})
      notify "Timing #{stat} at #{ms} ms#{opts_string(opts)}"
    end

    def set(stat, value, opts = {})
      notify "Setting #{stat} to #{value}#{opts_string(opts)}"
    end

    def service_check(name, status, opts = {})
      notify "Service check #{name}: #{status}#{opts_string(opts)}"
    end

    def event(title, text, opts = {})
      notify "Event #{title}: #{text}#{opts_string(opts)}"
    end

    def close
      notify "Close called"
    end

    def batch
      yield self
    end

    def time(stat, opts = {})
      time_in_sec, result = benchmark { yield }
      notify "Recording timing info in #{stat} -> #{time_in_sec} sec#{opts_string(opts)}"
      result
    end

    def with_namespace(namespace)
      new_ns = dup
      if @namespace == "" || @namespace == nil
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
      if @namespace && @namespace != ""
        "[NullStatsD #{@host}:#{@port}-#{@namespace}]"
      else
        "[NullStatsD #{@host}:#{@port}]"
      end
    end

    def benchmark(&block)
      start = Time.now
      result = block.call
      elapsed_time = Time.now - start
      return elapsed_time, result
    end

    def notify(msg)
      logger.debug "#{identifier_string} #{msg}"
    end

    def opts_string(opts)
      opts.empty? ? nil : " with opts #{opts.to_json}"
    end
  end
end
