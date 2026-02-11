# Water Data Importer Home Assistant Add-on

This is a Home Assistant add-on that imports water consumption data from JSON files into InfluxDB, allowing you to visualize and track water usage through Grafana dashboards or Home Assistant integrations.

## Installation

### Method 1: Add Custom Repository to Home Assistant

1. Go to **Settings → Add-ons → Create Add-on**
2. Click the **Repository** button (top right)
3. Add the repository URL: `https://github.com/codrinh/qa-to-ha-influxdb`
4. Click **Create**
5. The "Water Data Importer" add-on should now appear in your add-on store
6. Click it and select **Install**

### Method 2: Manual Installation (Docker Compose)

See the [Docker Compose Setup](#docker-compose-setup) section below.

## Features

- **JSON Upload Interface**: Web-based UI for uploading water consumption data
- **Automatic Deduplication**: Prevents duplicate entries based on timestamp
- **InfluxDB Integration**: Writes data to InfluxDB for time-series analysis
- **Tags & Fields**: Organizes data with meter serial and group ID tags for easy filtering
- **REST API**: `/upload` endpoint for programmatic data import

## Configuration

After installation, configure the add-on with these options:

- **Influx Host**: InfluxDB server hostname (default: `localhost`)
- **Influx Port**: InfluxDB port (default: `8086`)
- **Influx DB**: Database name (default: `homeassistant`)
- **Influx User**: InfluxDB username (default: `admin`)
- **Influx Password**: InfluxDB password (default: `admin123`)

## Expected JSON Format

Upload JSON files with the following structure:

```json
{
  "data": [
    {
      "TIME": "DD.MM.YYYY HH:MM:SS",
      "METERSERIAL": "meter_id_string",
      "GRUPMAS_ID": "group_id_string",
      "INDEX_CIT": 1234.56,
      "CONSUM": 12.34,
      "REAL_MEDIE": "real_time"
    }
  ]
}
```

**Field Descriptions:**
- `TIME`: Datetime in German format (DD.MM.YYYY HH:MM:SS) - used as unique key for deduplication
- `METERSERIAL`: Meter serial number (stored as tag)
- `GRUPMAS_ID`: Group/master ID (stored as tag)
- `INDEX_CIT`: Index value (field)
- `CONSUM`: Consumption value (field)
- `REAL_MEDIE`: Type/description (field)

## Usage

### Web Interface

1. Open the add-on's web interface (usually at `http://<homeassistant-ip>:5000`)
2. Drag and drop or browse to select your JSON file
3. Click **Upload** to import the data

### API Usage

```bash
curl -X POST -F "file=@data.json" http://<homeassistant-ip>:5000/upload
```

### Health Check

```bash
curl http://<homeassistant-ip>:5000/health
```

## Docker Compose Setup

For development or standalone Docker Compose deployment without Home Assistant:

```bash
# Start all services
docker-compose up -d

# Access the web UI
open http://localhost:5000

# Check InfluxDB
docker exec water-influxdb influx -database water_data -execute "SELECT * FROM water_consumption"

# View Grafana dashboards
open http://localhost:3000
```

## Data Deduplication

The add-on uses InfluxDB's timestamp-based deduplication:
- When you upload the same data again (same timestamp), it overwrites the previous entry
- This prevents duplicate records when re-importing data
- Verified with test: uploading 10 entries + re-uploading same 10 entries results in 10 total records (not 20)

## Troubleshooting

### Connection Errors

If you get connection errors to InfluxDB:
1. Verify the host and port are correct in the configuration
2. Ensure InfluxDB is running and accessible
3. Check network connectivity between containers

### Empty JSON Error

Make sure your JSON file has the exact structure shown above with all required fields.

### Port Already in Use

If port 5000 is busy, configure a different port in the add-on options.

## Development

To modify the source code:

1. Clone the repository
2. Edit files in `water-importer/rootfs/app/`
3. Testing in Docker Compose: `docker-compose up --build`
4. Testing in Home Assistant:
   - Mount the local directory in the add-on
   - Rebuild in the add-on settings

## Architecture

```
┌─────────────────────────────────┐
│  Water Data Importer Add-on     │
│  (Flask + Python 3.11)          │
└──────────┬──────────────────────┘
           │
           ├─→ InfluxDB (Time-Series DB)
           │   └─→ Store water_consumption data
           │
           └─→ Web UI (HTML/JS)
               └─→ JSON upload interface
```

## License

This project is open source and available on GitHub.

## Support

For issues and feedback: https://github.com/codrinh/qa-to-ha-influxdb/issues
