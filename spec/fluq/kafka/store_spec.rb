require 'spec_helper'

describe FluQ::Kafka::Store do

  it "should create new instances" do
    described_class.new(:file, "name").should be_instance_of(described_class::File)
    described_class.new("file", "name").should be_instance_of(described_class::File)
    described_class.new(:redis, "name").should be_instance_of(described_class::Redis)
  end

  it "should fail on invalid types" do
    -> { described_class.new("unknown", "name") }.should raise_error(ArgumentError)
  end

end
