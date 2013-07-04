class FluQ::Kafka::Store::Base

  attr_reader :name

  # @param [String] name topic/partition name
  # @param [Hash] opts options
  def initialize(name, opts = {})
    @name = name
    @opts = opts.dup
  end

  # @abstract
  # @return [Integer] offset
  def offset
    0
  end

  # @abstract
  # @param [Integer] value offset value
  def offset=(value)
  end

end