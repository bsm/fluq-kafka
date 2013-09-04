# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "fluq/kafka/version"

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.0.0'
  s.required_rubygems_version = ">= 1.8.0"

  s.name        = File.basename(__FILE__, '.gemspec')
  s.summary     = "FluQ Kafka"
  s.description = "Kafka plugin for FluQ"
  s.version     = FluQ::Kafka::VERSION.dup

  s.authors     = ["Black Square Media"]
  s.email       = "info@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/fluq-kafka"

  s.require_path = 'lib'
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency "fluq", "~> #{s.version}"
  s.add_dependency "kafka-rb"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
  s.add_development_dependency "redis"
end
