require 'spec_helper'

describe FluQ::Kafka::Store::Redis do

  subject { described_class.new "topic.1" }
  after   { subject.redis.del subject.key }

  its(:redis) { should be_instance_of(Redis) }
  its(:key) { should == "fluq:kafka:topic:1" }

  it "should read/write offset" do
    subject.offset.should be(nil)
    subject.offset = 5
    subject.offset.should == 5
    subject.offset = "60"
    subject.offset.should == 60
  end

end
