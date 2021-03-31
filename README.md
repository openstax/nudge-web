# nudge-web

The nudge web consumer is a tiny web server that reads json files
for /USER_UUID/BOOK_UUID

This tiny web server consists of two parts:
1) a ruby daemon that listens to a kafka broker thru a consumer
group and writes these json files

   `ruby ruby nudge_web_writer.rb`  
 
2) a sinatra endpoint that fetches them by /user_uuid/book_uuid
    `ruby nudge_web_api.rb`

Each JSON file of nudges looks like this

`-rw-r--r--  1 steveburkett  wheel  708 Mar 31 11:56 ac27f48d-8a54-49ad-a361-cab9c09e8181_124b8a39-fb66-4d04-bf38-c6dd276beadc.json`

```bigquery
[
  {
    "device_uuid": "6a814ffb-d650-4ad7-89e8-bc13ecfd3e35",
    "user_uuid": "ac27f48d-8a54-49ad-a361-cab9c09e8181",
    "session_uuid": "6bf48c7a-5973-4b8f-a4c5-a85b72ad0186",
    "session_order": 1,
    "app": "red cows",
    "target": "study_guides",
    "context": "124b8a39-fb66-4d04-bf38-c6dd276beadc",
    "flavor": "full-screen-v2",
    "medium": "in-app",
    "occurred_at": "1970-01-19 17:13:36 UTC"
  },
  {
    "device_uuid": "6a814ffb-d650-4ad7-89e8-bc13ecfd3e35",
    "user_uuid": "ac27f48d-8a54-49ad-a361-cab9c09e8181",
    "session_uuid": "6bf48c7a-5973-4b8f-a4c5-a85b72ad0186",
    "session_order": 1,
    "app": "purple cows",
    "target": "study_guides",
    "context": "124b8a39-fb66-4d04-bf38-c6dd276beadc",
    "flavor": "full-screen-v2",
    "medium": "in-app",
    "occurred_at": "1970-01-19 17:13:36 UTC"
  }
]
```

### To test
1) Comment out daemonizing.  like this
   `# Process.daemon()`
2) run the producer script as shown above
