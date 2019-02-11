#!/usr/bin/env bash

set -e

data="{\"text\": \"${@:-1}\"}"

curl -f -X POST "$WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "$data"
