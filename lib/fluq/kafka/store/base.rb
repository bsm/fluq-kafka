class FluQ::Kafka::Store::Base

  attr_reader :name, :opts

  # @param [String] name topic/partition name
  # @param [Hash] opts options
  def initialize(name, opts = {})
    @name = name
    @opts = opts.dup
  end

  # @abstract
  # @return [Integer,nil] offset (nil if offset is not set)
  def offset
    nil
  end

  # @abstract
  # @param [Integer] value offset value
  def offset=(value)
  end

end
