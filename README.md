# RedisWithFailover

[![Build status](https://secure.travis-ci.org/wanelo/redis_with_failover.png)](http://travis-ci.org/wanelo/redis_with_failover)

Simple wrapper around Redis Client that attempts each operation on a set of 
backup redis servers before giving up. Can be used with sidekiq to ensure 
clients can always enqueue to at least one of the provided Redis servers.

## Installation

Add this line to your application's Gemfile:

    gem 'redis_with_failover'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis_with_failover

## Usage

```ruby
redis = RedisWithFailover::Client.new(servers: [
            Redis.new(url: "redis://127.0.0.1:6379"),
            Redis.new(url: "redis://127.0.0.1:6380"),
            Redis.new(url: "redis://127.0.0.1:6381")])

redis.set("key", "value")
```

An optional proc can be defined, which will be called when a failover occurs:

```ruby
redis = RedisWithFailover::Client.new(servers: [
            Redis.new(url: "redis://127.0.0.1:6379"),
            Redis.new(url: "redis://127.0.0.1:6380"),
            Redis.new(url: "redis://127.0.0.1:6381")]) do |failed_redis, error|

   Rails.logger.warn("Redis command raised #{error.class} #{error.message} on #{failed_redis.inspect}, failing over to the next one")
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
