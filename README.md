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
[NullStatsD :-] Incrementing media.book.consumed with opts genre:science fiction
[NullStatsD :-] Decrementing media.book.on_hand
[NullStatsD :-] Recording timing info in book checkout -> 0.512917 sec
```

### Supported API

```ruby
instance = NullStatsd::Statsd.new(host: "https://fakestatsd.com", port: 4242, logger: $stdout
```

#### increment(stat, opts = {})

```ruby
instance.increment "media.book.consumed", genre: "horror"
```

> [NullStatsD :-] Incrementing media.book.consumed with opts genre:horror

#### decrement(stat, opts = {})

```ruby
instance.decrement "media.book.on_hand", genre: "science fiction"
```

> [NullStatsD :-] Decrementing media.book.on_hand with opts genre:science fiction

#### count(stat, opts = {})

```ruby
instance.count "responses", 3
```

> [NullStatsD :-] Increasing responses by 3

#### guage(stat, opts = {})

```ruby
instance.guage "media.book.return_time", 12, measurement: "days"
```

> [NullStatsD :-] Setting guage media.book.return_time to 12 with opts measurement:days

#### histogram(stat, opts = {})

```ruby
instance.histogram "media.book.lent.hour", 42
```

> [NullStatsD :-] Logging histogram media.book.lent.hour -> 42

#### timing(stat, ms, opts = {})

```ruby
instance.timing "book checkout", 94, tags: "speedy"
```

> [NullStatsD :-] Timing book checkout at 94 ms with opts tags:speedy

#### set(stat, opts = {})

```ruby
instance.set "media.book.lent", 10_000_000
```

> [NullStatsD :-] Setting media.book.lent to 10000000

#### service_check(stat, opts = {})

```ruby
instance.service_check "door.locked", "ok"
```

> [NullStatsD :-] Service check door.locked: ok

#### event(stat, opts = {})

```ruby
instance.event "Leak", "The library roof has a leak on the west end. Please take care"
```

> [NullStatsD :-] Event Leak: The library roof has a leak on the west end. Please take care

#### time(stat, opts = {})

```ruby
instance.time("media.movie.consume") do
  Movie.new().watch
end
```

> [NullStatsD :-] Recording timing info in media.movie.consumed -> 12323 sec

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
