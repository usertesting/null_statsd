# NullStatsd

NullStatsd is a Statsd implementation which utilizes the [Null Object Pattern](https://en.wikipedia.org/wiki/Null_object_pattern), allowing for a fully stubbed Statsd object in your development and testing environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'null_statsd'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install null_statsd

## Usage

Create a thin wrapper around your Statsd implementation:

```ruby
class MyStatsd
    def self.new
        if ENV["STATSD_URL"] # OR if Rails.development || Rails.staging ...
            Datadog::Statsd.new(statsd_host, statsd_port, *additional_params)
        else
            NullStatsd::Statsd.new(host: statsd_host, port: statsd_port, logger: Rails.logger)
        end
    end
end
```

Create an instance and use it as normal
```ruby
MyStatsd.new.increment(...)
```

Notice that your `statsd` endpoint is _not_ receiving data. Also notice that your _logs_ are.

```
[NullStatsD :-] Incrementing jobs.Distribution::InvitationWorker.success with opts by:1|tags:
[NullStatsD :-] Incrementing honeybadger.error with opts by:1|tags:class:Neo4j::Core::CypherSession::ConnectionFailedError,error:true
[NullStatsD :-] Recording timing info in jobs.Distribution::InvitationWorker.perform -> 0.512917 sec with opts tags:
```

## Development

## Testing

`rake spec`

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/usertesting/null_statsd](https://github.com/usertesting/null_statsd)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
