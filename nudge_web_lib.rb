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

class UserBookFile
  attr_reader :file_name

  def initialize(user_uuid:, book_uuid:)
    @user_uuid = user_uuid
    @book_uuid = book_uuid
    @file_name = full_file_name(user_uuid, book_uuid)
  end

  def contents
    # puts "About to read #{file_name} to write data #{File.read(file_name)}"
    JSON.parse(File.read(file_name)) rescue []
  end

  def write(nudges)
    # puts "About to open #{file_name} to write data #{nudges.inspect}"
    File.open(file_name, 'w') do |f|
      f.write(nudges.to_json)
    end
  end
end
