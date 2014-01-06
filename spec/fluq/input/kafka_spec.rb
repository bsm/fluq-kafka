require 'spec_helper'

describe FluQ::Input::Kafka do

  let(:event)   { FluQ::Event.new("some.tag", 1313131313, {}) }
  let(:reactor) { FluQ::Reactor.new }
  let(:message) { ::Kafka::Message.new(event.to_msgpack) }

  def input(reactor)
    described_class.new(reactor, bind: "kafka://127.0.0.1:9092/mytopic/2", store: "file", store_options: { misc: 1 })
  end

  before :each do
    @mock_socket = double(TCPSocket)
    TCPSocket.stub(:new).and_return(@mock_socket) # don't use a real socket
  end

  subject { input(reactor) }

  it { should be_a(FluQ::Input::Base) }
  its(:name)   { should == "kafka (mytopic.2)" }
  its(:key)    { should == "mytopic.2" }
  its(:topic)  { should == "mytopic" }
  its(:port)  { should == 9092 }
  its(:partition)  { should == 2 }
  its(:config)   { should == {buffer: "file", feed: "msgpack", buffer_options: {}, max_size: 10485760, interval: 10, bind: "kafka://127.0.0.1:9092/mytopic/2", store: "file", store_options: { misc: 1 } } }
  its(:consumer) { should be_instance_of(::Kafka::Consumer) }
  its(:store)    { should be_instance_of(FluQ::Kafka::Store::File) }

  it 'should require bind option' do
    -> { described_class.new(reactor) }.should raise_error(ArgumentError, /No URL to bind/)
  end

  it 'should configure store name & options' do
    subject.store.name.should == 'mytopic.2'
    subject.store.opts.should == { misc: 1 }
  end

  describe "running" do

    def offset
      subject.store.offset
    end

    after do
      subject.stop
    end

    it 'should process events' do
      subject.consumer.stub(consume: [message, message], offset: 101)

      reactor.should_receive(:process)
      offset.should be(nil)
      thread = subject.run
      thread.should be_instance_of(Thread)
      10.times { sleep(0.05) if offset.nil? || offset < 101 }

      offset.should == 101
      thread.should be_alive
    end

    it 'should catch processing errors' do
      subject.consumer.stub(read_data_response: ::Kafka::Message.new("ABCD").encode, send_consume_request: nil, fetch_latest_offset: 101)

      raised = false
      reactor.should_not_receive(:process)
      subject.logger.should_receive(:crash).with {|c| raised = true }

      thread = subject.run
      10.times { sleep(0.05) unless raised }
      offset.should be(nil)
      thread.should be_alive
    end

    it 'should not stop loop on consumer errors' do
      subject.consumer.stub(:consume).once.and_raise
      subject.consumer.stub(:consume).once.and_return([message])
      subject.consumer.stub(:offset).and_return(101)
      thread = subject.run
      10.times { sleep(0.1) if offset.nil? }
      offset.should == 101
      thread.should be_alive
    end

  end

end
