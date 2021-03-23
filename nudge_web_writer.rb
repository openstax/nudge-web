require 'daemons'
require 'ruby-kafka'
require 'avro_turf'
require 'avro_turf/messaging'
require 'json'

# Process.daemon()
KAFKA_HOST = 'localhost:9092'
COMPACT_FORM = /(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})/i
FILE_SHARED_VOLUME = '/tmp/'
SCHEMA_REGISTRY_URL = 'http://localhost:8081/'
NUDGED_SCHEMA_NAME = 'org.openstax.ec.nudged_v1'

trap('TERM') do
  kafka_consumer.stop
end
trap('SIGINT') do
  kafka_consumer.stop
  exit!
end

def unpack(packed_uuid)
  unpacked_nohypens = packed_uuid.unpack1('H*')
  parts = unpacked_nohypens.match(COMPACT_FORM)
  parts.captures.join('-')
rescue
  "Unable to unpack #{packed_uuid}"
end

def kafka_consumer
  @kafka_consumer ||= begin
    consumer = kafka.consumer(group_id: 'nudged-consumer')
    consumer.subscribe('nudged')
    consumer
  end
end

def kafka
  @kafka ||= Kafka.new([KAFKA_HOST])
end

def avroturf
  @avro ||= AvroTurf::Messaging.new(registry_url: SCHEMA_REGISTRY_URL)
end

def full_file_name(user_uuid, book_uuid)
  FILE_SHARED_VOLUME + "#{user_uuid}_#{book_uuid}.json"
end

loop do
  begin
    kafka_consumer.each_message() do |message|
      begin
        nudge = avroturf.decode(message.value, schema_name: NUDGED_SCHEMA_NAME)

        nudge['device_uuid'] = unpack(nudge['device_uuid'])
        nudge['session_uuid'] = unpack(nudge['session_uuid'])
        user_uuid = nudge['user_uuid'] = unpack(nudge['user_uuid'])
        book_uuid = nudge['context'] = nudge['context']   #book id isnt compacted

        file_name = full_file_name(user_uuid, book_uuid)

        puts "Opening file #{file_name} for content #{nudge.to_s}"

        file = File.open(file_name,'a+')
        data = JSON.parse(file.read) rescue []
        data.append(nudge)
        File.write(file_name, JSON.dump(data))
      rescue => ex
        puts ex.inspect
        next
      end
    end
  rescue Kafka::ProcessingError => ex
    puts ex.cause.inspect
  end
end
