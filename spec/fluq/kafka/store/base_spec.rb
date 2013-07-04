require 'spec_helper'

describe FluQ::Kafka::Store::Base do

  subject { described_class.new "base" }

  its(:name) { should == "base" }
  its(:offset) { should == 0 }
  it { should respond_to(:offset=) }

end
