# nudge-web

The nudge web consumer is a tiny web server that reads json files
for /USER_UUID/BOOK_UUID

This tiny web server consists of two parts:
1) a ruby daemon that listens to a kafka broker thru a consumer
group and writes these json files
2) a sinatra endpoint that fetches them by /user_uuid/book_uuid


