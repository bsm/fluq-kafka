require 'spec_helper'

describe FluQ::Kafka do

  it 'should force celluloid sockets' do
    sock = double(Celluloid::IO::TCPSocket)
    ::TCPSocket.should_not_receive(:new)
    Celluloid::IO::TCPSocket.should_receive(:new).and_return(sock)

    conn = Poseidon::Connection.new "localhost", 9092, "client-id"
    conn.send(:ensure_connected).should == sock
  end

end
