#!/usr/bin/with-contenv bashio
set -e

echo "[INFO] Starting Water Data Importer add-on..."

# Use bashio to get options from Home Assistant
# These match the keys in your config.yaml
# export INFLUX_HOST=$(bashio::config 'influx_host' 'influxdb')
# export INFLUX_PORT=$(bashio::config 'influx_port' '8086')
# export INFLUX_DB=$(bashio::config 'influx_db' 'homeassistant')
# export INFLUX_USER=$(bashio::config 'influx_user' 'homeassistant')
# export INFLUX_PASSWORD=$(bashio::config 'influx_password' 'homeassistant')
export FLASK_PORT=$(bashio::config 'flask_port' '5000')
export FLASK_HOST="0.0.0.0"

# echo ""
# echo "============================================================"
# echo "Configuration Summary:"
# echo "============================================================"
# echo "InfluxDB Host: $INFLUX_HOST"
# echo "InfluxDB Port: $INFLUX_PORT"
# echo "Database:      $INFLUX_DB"
# echo "Username:      $INFLUX_USER"
# echo "Flask Port:    $FLASK_PORT"
# echo "============================================================"
# echo ""

# Start the Flask application
cd /app
exec python3 main.py