require 'fluq'
require 'fluq/kafka/version'
require 'em-kafka'
require 'fluq/kafka/store'
require 'fluq/input/kafka'

EM::Kafka.logger.level = Logger::WARN
