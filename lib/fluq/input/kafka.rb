class FluQ::Input::Kafka < FluQ::Input::Base

  # Constructor.
  # @option options [String] :topic the name of the topic to consume
  # @option options [String] :group
  #   The unique consumer group name. Each topic message is consumed only once by members of the same group.
  #   If you have multiple thread/process instances running, make sure you assign them the same group name to
  #   ensure events are not duplicated.
  # @option options [String] :brokers an array of "HOST:PORT" broker addresses, e.g. ["localhost:9092"]
  # @option options [String] :zookeepers an array of "HOST:PORT" zookeeper addresses, e.g. ["localhost:2181"]
  # @option options [Integer] :max_bytes maximum number of bytes to fetch
  #   Default: 1048576 (1MB)
  # @option options [Integer] :max_wait_ms how long to block until the server sends us data.
  #   Default: 100 (100ms)
  # @option options [Integer] :min_bytes smallest amount of data the server should send us.
  #   Default: 0 (send us data as soon as it is ready)
  # @option options [Class] :consumer_class the consumer class to use.
  #   Ddefault: FluQ::Kafka::Consumer
  #
  # @raises [ArgumentError] when no topic provided
  #
  # @example
  #
  #   FluQ::Input::Kafka.new handlers,
  #     topic: "page-views",
  #     group: "fluq",
  #     brokers: ["localhost:9092"],
  #     zookeepers: ["localhost:2181"]
  def initialize(*)
    super
  end

  # @return [String] short name
  def name
    "kafka:#{config[:topic]}"
  end

  # @return [String] descriptive name
  def description
    "#{name} (#{config[:group]} <- #{config[:brokers].join(',')})"
  end

  # Start the loop
  def run
    super

    consumer.fetch_loop do |partition, bulk|
      process partition, bulk
    end
  end

  # Processes messages
  # @param [Integer] partition
  # @param [Array<Poseidon::Message>] messages
  def process(partition, messages)
    events = []
    messages.each do |m|
      events.concat format.parse(m.value)
    end
    events.each do |event|
      event.meta.update topic: config[:topic], partition: partition
    end
    worker.process events
  end

  protected

    def consumer
      @consumer ||= config[:consumer_class].new config[:group], config[:brokers], config[:zookeepers], config[:topic],
        min_bytes: config[:min_bytes],
        max_bytes: config[:max_bytes],
        max_wait_ms: config[:max_wait_ms]
    end

    def configure
      raise ArgumentError, 'No topic provided, make sure you pass a :topic option' unless config[:topic]
    end

    def defaults
      super.merge \
        group: "fluq",
        min_bytes: 0,
        max_bytes: (1024 * 1024),
        max_wait_ms: 100,
        brokers: ["localhost:9092"],
        zookeepers: ["localhost:2181"],
        consumer_class: ::FluQ::Kafka::Consumer

    end

    def before_terminate
      @consumer.close if @consumer
    rescue ThreadError
    ensure
      @consumer = nil
    end

end

