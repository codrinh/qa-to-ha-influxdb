#!/bin/bash
set -e

# Home Assistant Add-on startup script for Water Data Importer

# Default values
INFLUX_HOST="${INFLUX_HOST:-localhost}"
INFLUX_PORT="${INFLUX_PORT:-8086}"
INFLUX_DB="${INFLUX_DB:-homeassistant}"
INFLUX_USER="${INFLUX_USER:-admin}"
INFLUX_PASSWORD="${INFLUX_PASSWORD:-admin123}"
FLASK_PORT="${FLASK_PORT:-5000}"
FLASK_HOST="${FLASK_HOST:-0.0.0.0}"

echo "[INFO] Starting Water Data Importer add-on..."

# If running as HA add-on, read options from /data/options.json
if [ -f /data/options.json ]; then
    echo "[INFO] Reading Home Assistant add-on options from /data/options.json..."
    
    # Use Python for robust JSON parsing (safer than grep/sed)
    CONFIG=$(python3 << 'EOF'
import json
import sys

try:
    with open('/data/options.json', 'r') as f:
        options = json.load(f)
    
    # Extract values with defaults
    host = options.get('influx_host', 'localhost')
    port = options.get('influx_port', 8086)
    db = options.get('influx_db', 'homeassistant')
    user = options.get('influx_user', 'admin')
    password = options.get('influx_password', 'admin123')
    flask_port = options.get('flask_port', 5000)
    
    # Output in format: KEY=VALUE
    print(f"HOST={host}")
    print(f"PORT={port}")
    print(f"DB={db}")
    print(f"USER={user}")
    print(f"PASSWORD={password}")
    print(f"FLASK_PORT={flask_port}")
    
except Exception as e:
    print(f"ERROR: Failed to parse options.json: {e}", file=sys.stderr)
    sys.exit(1)
EOF
    )
    
    if [ $? -eq 0 ]; then
        eval "$CONFIG"
        INFLUX_HOST="$HOST"
        INFLUX_PORT="$PORT"
        INFLUX_DB="$DB"
        INFLUX_USER="$USER"
        INFLUX_PASSWORD="$PASSWORD"
        FLASK_PORT="$FLASK_PORT"
        echo "[INFO] ✓ Successfully loaded options from /data/options.json"
    else
        echo "[WARN] Failed to parse options.json, using defaults"
    fi
else
    echo "[INFO] No /data/options.json found, using environment variables or defaults"
fi

# Export variables for Flask app
export INFLUX_HOST
export INFLUX_PORT
export INFLUX_DB
export INFLUX_USER
export INFLUX_PASSWORD
export FLASK_PORT
export FLASK_HOST

echo ""
echo "============================================================"
echo "Configuration Summary:"
echo "============================================================"
echo "InfluxDB Host: $INFLUX_HOST"
echo "InfluxDB Port: $INFLUX_PORT"
echo "Database: $INFLUX_DB"
echo "Username: $INFLUX_USER"
echo "Flask Port: $FLASK_PORT"
echo "Flask Host: $FLASK_HOST"
echo "============================================================"
echo ""

# Start the Flask application
cd /app
exec python main.py
