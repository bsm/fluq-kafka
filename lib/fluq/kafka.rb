require 'fluq'
require 'fluq/kafka/version'
require 'poseidon_cluster'
require 'fluq/input/kafka'

class Poseidon::Connection
  TCPSocket = Celluloid::IO::TCPSocket
end
