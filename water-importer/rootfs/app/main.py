import os
import json
from datetime import datetime
from flask import Flask, render_template, request, jsonify
from influxdb import InfluxDBClient

app = Flask(__name__)

# Get configuration from environment variables (set by Home Assistant add-on options or docker-compose)
INFLUX_HOST = os.getenv('INFLUX_HOST', 'localhost')
INFLUX_PORT = int(os.getenv('INFLUX_PORT', 8086))
INFLUX_DB = os.getenv('INFLUX_DB', 'homeassistant')
INFLUX_USER = os.getenv('INFLUX_USER', 'homeassistant')
INFLUX_PASSWORD = os.getenv('INFLUX_PASSWORD', 'homeassistant')

def get_influx_client():
    """Create and return an InfluxDB client."""
    return InfluxDBClient(
        host=INFLUX_HOST,
        port=INFLUX_PORT,
        username=INFLUX_USER,
        password=INFLUX_PASSWORD,
        database=INFLUX_DB
    )

def process_water_data(json_payload):
    """
    Process water consumption data and write to InfluxDB.
    
    Uses timestamp as unique key to prevent duplicates:
    When the same timestamp is written again, it overwrites the previous entry.
    """
    client = get_influx_client()
    points = []
    
    try:
        data_entries = json_payload.get('data', [])
        
        for entry in data_entries:
            try:
                # Parse datetime in German format: DD.MM.YYYY HH:MM:SS
                dt = datetime.strptime(entry['TIME'], "%d.%m.%Y %H:%M:%S")
                
                # Build InfluxDB point with tags and fields
                point = {
                    "measurement": "water_consumption",
                    "tags": {
                        "meter_serial": str(entry.get('METERSERIAL', '')),
                        "grupmas_id": str(entry.get('GRUPMAS_ID', ''))
                    },
                    "time": dt.isoformat(),
                    "fields": {
                        "index_cit": float(entry.get('INDEX_CIT', 0)),
                        "consumption": float(entry.get('CONSUM', 0)) if entry.get('CONSUM') else 0.0,
                        "type": str(entry.get('REAL_MEDIE', ''))
                    }
                }
                points.append(point)
            except (KeyError, ValueError) as e:
                print(f"Error processing entry: {e}, skipping entry: {entry}")
                continue
        
        if points:
            # Write to InfluxDB
            success = client.write_points(points)
            if success:
                print(f"Successfully wrote {len(points)} points to InfluxDB")
                return True, len(points)
            else:
                print("Failed to write points to InfluxDB")
                return False, 0
        else:
            print("No valid data points to write")
            return False, 0
            
    except Exception as e:
        print(f"Error in process_water_data: {e}")
        raise
    finally:
        client.close()

@app.route('/', methods=['GET'])
def index():
    """Serve the upload page."""
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload():
    """Handle JSON file upload and write to InfluxDB."""
    try:
        # Check if file is in request
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'success': False, 'error': 'No file selected'}), 400
        
        if not file.filename.endswith('.json'):
            return jsonify({'success': False, 'error': 'File must be JSON format'}), 400
        
        # Parse JSON
        try:
            json_data = json.load(file)
        except json.JSONDecodeError as e:
            return jsonify({'success': False, 'error': f'Invalid JSON: {str(e)}'}), 400
        
        # Process and write to InfluxDB
        success, count = process_water_data(json_data)
        
        if success:
            return jsonify({
                'success': True,
                'message': f'Successfully imported {count} water consumption records',
                'records_count': count
            }), 200
        else:
            return jsonify({
                'success': False,
                'error': 'Failed to write data to InfluxDB'
            }), 500
            
    except Exception as e:
        print(f"Upload error: {e}")
        return jsonify({
            'success': False,
            'error': f'Server error: {str(e)}'
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    try:
        client = get_influx_client()
        client.ping()
        client.close()
        return jsonify({'status': 'healthy'}), 200
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

if __name__ == '__main__':
    # Startup: Log configuration and verify InfluxDB connection
    print("\n" + "="*60)
    print("Water Data Importer - Startup")
    print("="*60)
    print(f"InfluxDB Host: {INFLUX_HOST}:{INFLUX_PORT}")
    print(f"Database: {INFLUX_DB}")
    print(f"Username: {INFLUX_USER}")
    
    # Try to connect to InfluxDB
    try:
        client = get_influx_client()
        client.ping()
        client.close()
        print("✓ InfluxDB connection: SUCCESS")
    except Exception as e:
        print(f"✗ InfluxDB connection: FAILED - {str(e)}")
        print("  Warning: Make sure InfluxDB is running and accessible")
    
    print("="*60)
    print("Starting Flask app on 0.0.0.0:5000...")
    print("="*60 + "\n")
    
    # Run Flask app on port 5000
    app.run(host='0.0.0.0', port=5000, debug=False)
