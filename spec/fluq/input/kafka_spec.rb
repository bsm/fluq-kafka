require 'spec_helper'

describe FluQ::Input::Kafka do

  let(:message) { Poseidon::Message.new value: %({"a":1,"b":2}) }
  let(:actors)  { [] }

  let :mock_consumer do
    double Poseidon::ConsumerGroup, claimed: [], fetch_loop: nil, close: true
  end

  def input(opts = {})
    actor = described_class.new [[FluQ::Handler::Test]], opts
    actors << actor
    actor
  end

  before  { Poseidon::ConsumerGroup.stub new: mock_consumer }
  after   { actors.each &:terminate }
  subject { input topic: "my-topic" }

  it { should be_a(FluQ::Input::Base) }
  its(:description) { should == "kafka:my-topic (fluq <- localhost:9092)" }
  its(:name)        { should == "kafka:my-topic" }
  its(:config)      { should == {format: "json", format_options: {}, group: "fluq", min_bytes: 0, max_bytes: 1048576, max_wait_ms: 100, brokers: ["localhost:9092"], zookeepers: ["localhost:2181"], topic: "my-topic"} }

  it 'should require a topic option' do
    -> { input }.should raise_error(ArgumentError, /No topic provided/)
  end

  it 'should fetch messages' do
    mock_consumer.should_receive(:fetch_loop).and_yield(3, [message]*10)
    subject.worker.should have(1).handlers
    subject.worker.handlers.first.should have(10).events
    event = subject.worker.handlers.first.events.first
    event.should == {"a"=>1,"b"=>2}
    event.meta.should == {topic: "my-topic", partition: 3}
  end

end
