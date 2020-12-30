require 'daemons'
require 'ruby-kafka'
require 'json'

# Process.daemon()

file_shared_volume = '/tmp/'
kafka = Kafka.new(['localhost:9092'])
consumer = kafka.consumer(group_id: 'nudged-consumer')
consumer.subscribe('nudged')

trap("TERM") { consumer.stop }
trap("SIGINT") { exit! }

loop do
  begin
    consumer.each_message() do |message|
      puts "Reading message from consumer: #{message.inspect}"
      # determine user and book uuids from message
      user_uuid = 'foo'
      book_uuid = 'bar'
      file_name = file_shared_volume + "#{user_uuid}_#{book_uuid}.json"

      File.open(file_name, 'a') do |file|
        file.puts(message.to_json)
      end
    end
  rescue Kafka::ProcessingError => ex
    puts ex
    puts ex.cause
    retry
  end
  # sleep(10)  # 10 second breather
end
