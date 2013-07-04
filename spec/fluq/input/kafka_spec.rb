require 'spec_helper'

describe FluQ::Input::Kafka do

  let(:event)   { FluQ::Event.new("some.tag", 1313131313, {}) }
  let(:reactor) { FluQ::Reactor.new }
  let(:message) { ::Kafka::Message.new(event.to_msgpack) }

  def input(reactor)
    described_class.new(reactor, bind: "kafka://127.0.0.1:9092/mytopic/2")
  end

  before :each do
    @mock_socket = mock(TCPSocket)
    TCPSocket.stub!(:new).and_return(@mock_socket) # don't use a real socket
  end

  subject { input(reactor) }

  it { should be_a(FluQ::Input::Base) }
  its(:name)   { should == "kafka (mytopic.2)" }
  its(:key)    { should == "mytopic.2" }
  its(:topic)  { should == "mytopic" }
  its(:partition)  { should == 2 }
  its(:config)   { should == {buffer: "file", feed: "msgpack", buffer_options: {}, max_size: 1048576, interval: 10, bind: "kafka://127.0.0.1:9092/mytopic/2", store: "file", store_options: {}} }
  its(:consumer) { should be_instance_of(::Kafka::Consumer) }
  its(:store)    { should be_instance_of(FluQ::Kafka::Store::File) }

  it 'should require bind option' do
    -> { described_class.new(reactor) }.should raise_error(ArgumentError, /No URL to bind/)
  end

  describe "running" do
    before do
      subject.consumer.stub!(:loop).and_yield([message, message])
      subject.consumer.stub! offset: 2
    end

    it 'should process events' do
      reactor.should_receive(:process).with do |events|
        events.should have(2).items
        events[0].should == event
        events[1].should == event
      end
      -> { subject.run }.should change { subject.store.offset }.from(0).to(2)
    end

  end

end
