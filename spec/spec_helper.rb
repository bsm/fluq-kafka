ENV['FLUQ_ROOT'] ||= File.expand_path("../scenario/", __FILE__)

require 'bundler/setup'
require 'rspec'
require 'coveralls'
Coveralls.wear_merged!

require 'fluq/kafka'
require 'fluq/testing'

FluQ.logger = Logger.new(FluQ.root.join("log", "fluq.log").to_s)
RSpec.configure do |c|
  c.after do
    FileUtils.rm_rf FluQ.root.join('log/kafka').to_s
  end
end
