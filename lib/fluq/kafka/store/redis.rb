class FluQ::Kafka::Store::Redis < FluQ::Kafka::Store::Base

  def initialize(*)
    super
    require 'redis'
  end

  # @return [Redis] path
  def redis
    @redis ||= @opts[:url] ? Redis.new(url: @opts[:url]) : Redis.new
  end

  # @return [String] storage key
  def key
    @key ||= [(@opts[:prefix] || 'fluq:kafka'), *name.split('.')].join(":")
  end

  # @see FluQ::Kafka::Store::Base#offset
  def offset
    val = redis.get(key)
    val ? val.to_i : nil
  end

  # @see FluQ::Kafka::Store::Base#offset=
  def offset=(value)
    redis.set(key, value.to_i)
  end

end
