# NullStatsd

NullStatsd is a [Statsd](https://github.com/statsd/statsd) implementation which utilizes the [Null Object Pattern](https://en.wikipedia.org/wiki/Null_object_pattern), allowing for a fully stubbed Statsd object in your development and testing environments.

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
      Statsd.new(statsd_host, statsd_port, *additional_params)
    else
      NullStatsd::Statsd.new(host: statsd_host, port: statsd_port, logger: Rails.logger)
    end
  end
end
```

Create an instance and use it as normal:

```ruby
MyStatsd.new.increment(...)
```

Notice that your `statsd` endpoint is _not_ receiving data. Also notice that your _logs_ are receiving data.

```
[NullStatsD :-] Incrementing jobs.Distribution::InvitationWorker.success with opts by:1|tags:
[NullStatsD :-] Incrementing honeybadger.error with opts by:1|tags:class:Neo4j::Core::CypherSession::ConnectionFailedError,error:true
[NullStatsD :-] Recording timing info in jobs.Distribution::InvitationWorker.perform -> 0.512917 sec with opts tags:
```

### Supported API

```ruby
instance = NullStatsd::Statsd.new(host: "https://fakestatsd.com", port: 4242, logger: $stdout
```

#### increment(stat, opts = {})

```ruby
instance.increment "testers", country: "gb", from_referer: true
```

> [NullStatsD :-] Incrementing testers with opts country:gb|from_referer:true

#### decrement(stat, opts = {})

```ruby
instance.decrement "testers", country: "de"
```

> [NullStatsD :-] Decrementing testers with opts country:de

#### count(stat, opts = {})

```ruby
instance.count "responses", 3
```

> [NullStatsD :-] Increasing responses by 3

#### guage(stat, opts = {})

```ruby
instance.guage "time_to_complete_study", 83, measurement: "minutes"
```

> [NullStatsD :-] Setting guage time_to_complete_study to 83 with opts measurement:minutes

#### histogram(stat, opts = {})

```ruby
instance.histogram "matched_demographics", 42
```

> [NullStatsD :-] Logging histogram matched_demographics -> 42

#### timing(stat, ms, opts = {})

```ruby
instance.timing "time_to_first_tester", 94, tags: "speedy"
```

> [NullStatsD :-] Timing time_to_first_tester at 94 ms with opts tags:speedy

#### set(stat, opts = {})

```ruby
instance.set "customers_satisfied", 10_000
```

> [NullStatsD :-] Setting customers_satisfied to 10000

#### service_check(stat, opts = {})

```ruby
instance.service_check "live_conversation", "ok"
```

> [NullStatsD :-] Service check live_conversation: ok

#### event(stat, opts = {})

```ruby
instance.event "Slack Integration (degraded)", "Customers in the US may experience difficulty connecting"
```

> [NullStatsD :-] Event Slack Integration (degraded): Customers in the US may experience difficulty connecting

#### time(stat, opts = {})

```ruby
instance.time("invitation_duration") do
  Distribution::InviteTesters.perform!
end
```

> [NullStatsD :-] Recording timing info in invitation_duration -> 17 sec

#### close(stat, opts = {})

```ruby
instance.close
```

> [NullStatsD :-] Close called

## Development

## Testing

`rake spec`

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/usertesting/null_statsd](https://github.com/usertesting/null_statsd)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
