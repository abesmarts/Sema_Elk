#!/bin/bash

echo "Setting up Kibana index patterns and dashboards..."

# Wait for Kibana to be ready
until curl -s http://localhost:5601/api/status | grep -q "available"; do
    echo "Waiting for Kibana to be available..."
    sleep 5
done

# Create index pattern
curl -X POST "localhost:5601/api/saved_objects/index-pattern/semaphore-logs-*" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -d '{
    "attributes": {
      "title": "semaphore-logs-*",
      "timeFieldName": "@timestamp"
    }
  }'

echo "Kibana index pattern created successfully!"
echo "You can now access Kibana at http://localhost:5601"
echo "Go to Discover to start exploring your Semaphore logs"
