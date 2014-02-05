require 'poseidon_cluster'

class Poseidon::Connection
  TCPSocket = Celluloid::IO::TCPSocket
end

module FluQ
  module Kafka
    class Consumer < Poseidon::ConsumerGroup
    end
  end
end

