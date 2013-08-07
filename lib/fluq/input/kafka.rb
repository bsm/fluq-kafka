require 'kafka'

class FluQ::Input::Kafka < FluQ::Input::Base

  # @attr_reader [URI] url the URL
  attr_reader :url

  # Constructor.
  # @option options [String] :bind the URL to bind to, format: kafka://HOST:PORT/TOPIC/PARTITION
  # @option options [String] :max_size the Kafka max message size, defaults to 1M
  # @option options [String] :interval the Kafka polling interval, defaults to 10s
  # @raises [ArgumentError] when no bind URL provided
  # @raises [URI::InvalidURIError] if invalid URL is given
  # @example
  #
  #   FluQ::Input::Kafka.new reactor, bind: "kafka://localhost:9092/my_topic/0",
  def initialize(*)
    super

    raise ArgumentError, 'No URL to bind to provided, make sure you pass :bind option' unless config[:bind]
    @url = FluQ::URL.parse(config[:bind], ["kafka", "tcp"])
  end

  # @return [String] descriptive name
  def name
    @name ||= "#{super} (#{key})"
  end

  # @return [String] unique topic name
  def key
    @key ||= [topic, partition].join(".")
  end

  # @return [String] topic name
  def topic
    @topic ||= @url.path.sub(/^\//, '').split("/").first || 'test'
  end

  # @return [Integer] partition
  def partition
    @partition ||= @url.path.split("/").last.to_i
  end

  # @return [Kafka::Consumer] the consumer instance
  def consumer
    @consumer ||= ::Kafka::Consumer.new \
      host: @url.host,
      port: @url.port,
      topic: topic,
      partition: partition,
      max_size: config[:max_size],
      polling: config[:interval],
      offset: store.offset
  end

  # @return [FluQ::Kafka::Store::Base] the store instance
  def store
    @store ||= FluQ::Kafka::Store.new(config[:store], key, config[:store_options])
  end

  # Start the loop
  def run
    consumer.loop do |messages|
      process(messages)
    end
  end

  protected

    def defaults
      super.merge max_size: ::Kafka::Consumer::MAX_SIZE, interval: 10, store: "file", store_options: {}
    end

  private

    def process(messages)
      events = messages.map do |msg|
        feed_klass.to_event(msg.payload)
      end.compact
      reactor.process(events) unless events.empty?
    rescue => ex
      logger.crash "#{self.class.name} #{self.name} failed: #{ex.class.name} #{ex.message}", ex
    ensure
      store.offset = consumer.offset
    end

end
