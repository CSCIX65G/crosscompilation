#!/bin/sh
echo "Running test of echo server"
echo ""
echo "Output:"
curl -X "POST" "http://localhost:8080/clock" \
     -H 'Content-Type: text/plain; charset=utf-8' \
     -d $'{
  "clockState": "on"
}'
echo ""
sleep 5
curl -X "POST" "http://localhost:8080/clock" \
     -H 'Content-Type: text/plain; charset=utf-8' \
     -d $'{
  "clockState": "off"
}'
echo ""


