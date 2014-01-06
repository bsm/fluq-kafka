require 'spec_helper'

describe FluQ::Kafka::Store::File do

  before  { FileUtils.rm_rf FluQ.root.join("log/kafka").to_s }
  subject { described_class.new "topic.1" }

  its(:path) { should == FluQ.root.join("log", "kafka", "topic.1.offset") }

  it "should read/write offset" do
    subject.offset.should be(nil)
    subject.offset = 5
    subject.offset.should == 5
    subject.offset = "60"
    subject.offset.should == 60
  end

end
