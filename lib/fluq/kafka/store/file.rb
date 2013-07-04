class FluQ::Kafka::Store::File < FluQ::Kafka::Store::Base

  # Constructor
  def initialize(*)
    super
    FileUtils.mkdir_p path.dirname.to_s
  end

  # @return [Pathname] path
  def path
    @path ||= FluQ.root.join (@opts[:path] || "log/kafka"), "#{name}.offset"
  end

  # @see FluQ::Kafka::Store::Base#offset
  def offset
    value = path.read if path.file?
    value.to_i
  end

  # @see FluQ::Kafka::Store::Base#offset=
  def offset=(value)
    path.open("w") do |file|
      file.write(value)
    end
  end

end

