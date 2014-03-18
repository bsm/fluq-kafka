require 'poseidon_cluster'

class Poseidon::Connection
  TCPSocket = Celluloid::IO::TCPSocket
end

module FluQ
  module Kafka
    class Consumer < Poseidon::ConsumerGroup
      include FluQ::Mixins::Loggable

      def rebalance!
        super
        logger.info "kafka:#{topic}: claimed #{claimed.inspect}"
      end

    end
  end
end

