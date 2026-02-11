#!/bin/bash

echo "=== Starting Flask App ==="
echo "Configuration:"
echo "  INFLUX_HOST: $INFLUX_HOST"
echo "  INFLUX_PORT: $INFLUX_PORT"
echo "  INFLUX_DB: $INFLUX_DB"
echo "  INFLUX_USER: $INFLUX_USER"
echo ""

# Start the Flask application
exec python3 /app/main.py
