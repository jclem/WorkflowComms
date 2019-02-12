#!/usr/bin/env bash

set -e

text="${@:-1}"
callback_id=$(uuid -v4)

poll_response() {
  retries=12

  until [ $retries -eq 0 ]; do
    echo "Polling for user response ($((retries--)) attempts remain)."

    response=$(get_response $1)

    if [[ "$response" == "confirm" ]]; then
      echo "Got a \"confirm\" response, continuing workflow."
      exit 0;
    fi

    if [[ "$response" == "cancel" ]]; then
      echo "Got a \"cancel\" response, halting workflow."
      exit 78;
    fi

    sleep 5
  done

  echo "Got no response, halting workflow."
  exit 1;
}

get_response() {
  response=$(curl -s "$SLACK_ACTIONS_URL/callbacks/$1" -H 'Accept: application/json')
  echo $response | jq -r '.actions[0].name'
}

post_message() {
  curl -s -f -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
    -H 'Content-type: application/json; charset=utf-8' \
    -d @- <<EOF
  {
    "channel": "$SLACK_BOT_CHANNEL",
    "text": "$text",
    "attachments": [
      {
        "text": "Choose 'Yes' to continue or 'Cancel' to cancel.",
        "fallback": "Confirmation request failed.",
        "callback_id": "$1",
        "actions": [
          {
            "name": "cancel",
            "text": "Cancel",
            "type": "button"
          },
          {
            "name": "confirm",
            "text": "Yes",
            "style": "danger",
            "type": "button"
          }
        ]
      }
    ]
  }
EOF
}

post_message $callback_id | jq -e .ok
poll_response $callback_id
