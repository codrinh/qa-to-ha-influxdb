#!/bin/sh

echo "Waiting for Flask app to be ready..."
# Wait for Flask app to be healthy
for i in {1..30}; do
  if curl -s http://flask-app:5000/ > /dev/null 2>&1; then
    echo "Flask app is ready!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 2
done

echo ""
echo "=========================================="
echo "DUPLICATE HANDLING TEST"
echo "=========================================="
echo ""

# Test 1: Upload first batch (10 entries)
echo "Step 1: Uploading first batch (10 entries)..."
RESPONSE1=$(curl -s -X POST -F "file=@/test_data/test_payload_batch1.json" \
  http://flask-app:5000/upload)
echo "$RESPONSE1" | grep -q "true"
if [ $? -eq 0 ]; then
  echo "✓ First batch uploaded successfully"
  echo "Response: $RESPONSE1"
else
  echo "✗ First batch upload failed"
  echo "Response: $RESPONSE1"
  exit 1
fi

echo ""
sleep 2

# Test 2: Upload second batch (15 entries - includes first 10 + 5 new)
echo "Step 2: Uploading second batch (15 entries, includes first 10 + 5 new)..."
RESPONSE2=$(curl -s -X POST -F "file=@/test_data/test_payload_batch2.json" \
  http://flask-app:5000/upload)
echo "$RESPONSE2" | grep -q "true"
if [ $? -eq 0 ]; then
  echo "✓ Second batch uploaded successfully"
  echo "Response: $RESPONSE2"
else
  echo "✗ Second batch upload failed"
  echo "Response: $RESPONSE2"
  exit 1
fi

echo ""
sleep 2

# Test 3: Query data to verify no duplicates
echo "Step 3: Querying InfluxDB to check for duplicates..."
echo ""

# We need to check via influxdb-cli or using curl to query
# Let's check the actual count by querying the database
INFLUX_QUERY=$(curl -s "http://influxdb:8086/query?u=admin&p=admin123&db=homeassistant" \
  --data-urlencode "q=SELECT COUNT(*) FROM water_consumption" | grep -o '"value":[0-9]*')

echo "InfluxDB Response: $INFLUX_QUERY"
echo ""

if echo "$INFLUX_QUERY" | grep -q "15"; then
  echo "✓✓✓ SUCCESS! No duplicates detected!"
  echo "   - First batch: 10 entries"
  echo "   - Second batch: 15 entries (10 duplicates + 5 new)"
  echo "   - Final count: 15 entries (duplicates were handled correctly)"
  echo ""
  echo "=========================================="
  echo "TEST PASSED: Duplicate handling is working!"
  echo "=========================================="
else
  echo "⚠ Final count: $INFLUX_QUERY"
  echo ""
  echo "Expected: 15 records"
  echo "If count is 25, duplicates were NOT removed (test FAILED)"
  echo "If count is less than 15, some records were lost (test FAILED)"
fi

echo ""
echo "Note: The timestamp is the unique key for each record."
echo "When the same timestamp is written again, it overwrites the previous value."
