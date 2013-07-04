module FluQ::Kafka::Store

  # @param [Symbol,String] type
  # @param [String] name
  # @param [Hash] opts options
  def self.new(type, name, opts = {})
    case type.to_s
    when "file"
      FluQ::Kafka::Store::File.new(name, opts)
    when "redis"
      FluQ::Kafka::Store::Redis.new(name, opts)
    else
      raise ArgumentError, "Invalid store type '#{type}'"
    end
  end

end

%w|base file redis|.each {|n| require "fluq/kafka/store/#{n}" }