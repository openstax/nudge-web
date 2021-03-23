# nudge-web

The nudge web consumer is a tiny web server that reads json files
for /USER_UUID/BOOK_UUID

This tiny web server consists of two parts:
1) a ruby daemon that listens to a kafka broker thru a consumer
group and writes these json files
   
2) a sinatra endpoint that fetches them by /user_uuid/book_uuid

Each JSON file looks like this
```bigquery
[ruby-2.4.5](git:):tmp $ cat ac27f48d-8a54-49ad-a361-cab9c09e8181_37323462-3861-3339-2d66-6236362d3464.json 
{"device_uuid":"6a814ffb-d650-4ad7-89e8-bc13ecfd3e35","user_uuid":"ac27f48d-8a54-49ad-a361-cab9c09e8181","session_uuid":"6bf48c7a-5973-4b8f-a4c5-a85b72ad0186","session_order":1,"app":"green cows","target":"study_guides","context":"37323462-3861-3339-2d66-6236362d3464","flavor":"full-screen-v2","medium":"in-app","occurred_at":"1970-01-19 15:02:51 UTC"}
```

### To test
1) Comment out daemonizing.  like this
   `# Process.daemon()`
2) run the producer script like this
   `ruby `
