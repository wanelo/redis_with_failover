# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis_with_failover/version'

Gem::Specification.new do |spec|
  spec.name          = "redis_with_failover"
  spec.version       = RedisWithFailover::VERSION
  spec.authors       = ['Konstantin Gredeskoul', 'Eric Saxby']
  spec.email         = %w(kig@wanelo.com sax@wanelo.com)
  spec.description   = %q{Simple failover for Redis clients}
  spec.summary       = %q{Simple failover for Redis clients}
  spec.homepage      = 'https://github.com/wanelo/redis_with_failover'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
