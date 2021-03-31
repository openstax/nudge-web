require 'daemons'
require_relative 'nudge_web_lib'

Process.daemon()

trap('TERM') do
  kafka_consumer.stop
end
trap('SIGINT') do
  kafka_consumer.stop
  exit!
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

        user_book_file = UserBookFile.new(user_uuid: user_uuid, book_uuid: book_uuid)
        data = user_book_file.contents
        data.append(nudge)

        user_book_file.write(data)
      rescue => ex
        puts ex.inspect
        next
      end
    end
  rescue Kafka::ProcessingError => ex
    puts ex.cause.inspect
  end
end
