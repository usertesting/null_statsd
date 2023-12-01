# NullStatsd

NullStatsd is a [Null Object Pattern](https://en.wikipedia.org/wiki/Null_object_pattern)
implementation of a [Statsd](https://github.com/statsd/statsd) client, allowing for
conveniently stubbed Statsd objects in your development and testing environments.

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

Create a wrapper around your Statsd implementation:

```ruby
module MyStatsd
  def self.new
    if ENV["STATSD_HOST"] && ENV["STATSD_PORT"]
      Statsd.new(ENV["STATSD_HOST"], ENV["STATSD_PORT"])
    else
      NullStatsd::Statsd.new(host: "fake.host", port: 1234, logger: Logger.new($stderr))
    end
  end
end

# or perhaps

if Rails.env.production? || Rails.env.staging?
  $statsd = Datadog::Statsd.new(ENV["DD_HOST"], ENV["DD_PORT"])
else
  $statsd = NullStatsd::Statsd.new(host: "fa.ke", port: 42, logger: Rails.logger)
end
```

Create an instance and use it as normal:

```ruby
MyStatsd.new.increment(...)
$statsd.increment(...)
```

Notice that your `statsd` endpoint is _not_ receiving data, but your logs are.

```
[NullStatsD host:42] Incrementing media.book.consumed with opts {"genre":"science_fiction"}
[NullStatsD host:42] Decrementing media.book.on_hand
[NullStatsD host:42] Recording timing info in book.checkout -> 0.512917 sec
```

### Supported Calls

```ruby
statsd = NullStatsd::Statsd.new(host: "a.co" port: 42, logger: Logger.new($stdout))
# => [NullStatsD a.co:42] Connecting to fake Statsd, pretending to be on fake.com:4242

statsd.increment "media.book.consumed", genre: "horror"
# => [NullStatsD a.co:42] Incrementing media.book.consumed with opts {"genre":"horror"}

statsd.decrement "media.book.on_hand", genre: "science fiction"
# => [NullStatsD a.co:42] Decrementing media.book.on_hand with opts {"genre":"science fiction"}

statsd.count "responses", 3
# => [NullStatsD a.co:42] Increasing responses by 3

statsd.gauge "media.book.return_time", 12, measurement: "days"
# => [NullStatsD a.co:42] Setting gauge media.book.return_time to 12 with opts {"measurement":"days"}

statsd.histogram "media.book.lent.hour", 42
# => [NullStatsD a.co:42] Logging histogram media.book.lent.hour -> 42

statsd.timing "book checkout", 94, tags: "speedy"
# => [NullStatsD a.co:42] Timing book checkout at 94 ms with opts {"tags":"speedy"}

statsd.set "media.book.lent", 10_000_000
# => [NullStatsD a.co:42] Setting media.book.lent to 10000000

statsd.service_check "door.locked", "ok"
# => [NullStatsD a.co:42] Service check door.locked: ok

statsd.event "Leak", "The library roof has a leak on the west end. Please take care"
# => [NullStatsD a.co:42] Event Leak: The library roof has a leak on the west end. Please take care

statsd.time("media.movie.consume") do
  Movie.new().watch
end
# => [NullStatsD a.co:42] Recording timing info in media.movie.consumed -> 12323.23 sec

statsd.close
# => [NullStatsD a.co:42] Close called

statsd.batch do |s|
  s.increment "foo.bar"
  s.increment "baz"
end
# This just executes the block, yielding the statsd instance to it.
```

## Testing

`rake spec`

## License

This gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Contributing

Bug reports and pull requests are welcome on GitHub.
