ENV['FLUQ_ENV']  ||= "test"
ENV['FLUQ_ROOT'] ||= File.expand_path("../scenario/", __FILE__)

require 'bundler/setup'
require 'rspec'
require 'fluq/kafka'
require 'fluq/testing'

FluQ.logger = Logger.new(FluQ.root.join("log", "fluq.log").to_s)
Random.srand(1234)