#!/bin/bash
set -e

# Home Assistant Add-on startup script for Water Data Importer

# Default values
INFLUX_HOST="${INFLUX_HOST:-localhost}"
INFLUX_PORT="${INFLUX_PORT:-8086}"
INFLUX_DB="${INFLUX_DB:-water_data}"
INFLUX_USER="${INFLUX_USER:-admin}"
INFLUX_PASSWORD="${INFLUX_PASSWORD:-admin123}"
FLASK_PORT="${FLASK_PORT:-5000}"
FLASK_HOST="${FLASK_HOST:-0.0.0.0}"

# If running as HA add-on, read options from /data/options.json
if [ -f /data/options.json ]; then
    echo "[INFO] Reading Home Assistant add-on options..."
    
    # Extract values from JSON using grep and sed (no jq dependency needed)
    INFLUX_HOST=$(grep -o '"influx_host":"[^"]*' /data/options.json | cut -d'"' -f4 2>/dev/null || echo "$INFLUX_HOST")
    INFLUX_PORT=$(grep -o '"influx_port":[0-9]*' /data/options.json | cut -d':' -f2 2>/dev/null || echo "$INFLUX_PORT")
    INFLUX_DB=$(grep -o '"influx_db":"[^"]*' /data/options.json | cut -d'"' -f4 2>/dev/null || echo "$INFLUX_DB")
    INFLUX_USER=$(grep -o '"influx_user":"[^"]*' /data/options.json | cut -d'"' -f4 2>/dev/null || echo "$INFLUX_USER")
    INFLUX_PASSWORD=$(grep -o '"influx_password":"[^"]*' /data/options.json | cut -d'"' -f4 2>/dev/null || echo "$INFLUX_PASSWORD")
    FLASK_PORT=$(grep -o '"flask_port":[0-9]*' /data/options.json | cut -d':' -f2 2>/dev/null || echo "$FLASK_PORT")
fi

# Export variables for Flask app
export INFLUX_HOST
export INFLUX_PORT
export INFLUX_DB
export INFLUX_USER
export INFLUX_PASSWORD
export FLASK_PORT
export FLASK_HOST

echo "[INFO] Starting Water Data Importer add-on..."
echo "[INFO] InfluxDB Host: $INFLUX_HOST:$INFLUX_PORT"
echo "[INFO] Database: $INFLUX_DB"
echo "[INFO] Flask listening on $FLASK_HOST:$FLASK_PORT"

# Start the Flask application
cd /app
python main.py
