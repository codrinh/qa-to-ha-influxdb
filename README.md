# Water Data Importer

A complete solution for importing water consumption data from JSON files to InfluxDB with visualization options. Works both as a Home Assistant add-on and as a standalone Docker Compose setup.

## Installation Methods

### Option 1: Home Assistant Add-on (Recommended)

**Easiest installation if you have Home Assistant:**

1. Go to **Settings → Add-ons → Create Add-on**
2. Click the **Repository** button (top right)
3. Add the repository URL: `https://github.com/codrinh/qa-to-ha-influxdb`
4. Click **Create**
5. The "Water Data Importer" add-on should now appear in your add-on store
6. Click it and select **Install**
7. Configure the InfluxDB connection settings in the add-on options
8. Start the add-on and access via Home Assistant

For detailed instructions, see [water-importer/README.md](water-importer/README.md)

### Option 2: Docker Compose (Standalone)

**For testing or standalone use without Home Assistant:**

1. **Start the containers:**
   ```bash
   docker-compose up -d
   ```

2. **Wait for services to be ready** (about 10-15 seconds)
   - Flask App: http://localhost:5000
   - InfluxDB: http://localhost:8086
   - Grafana: http://localhost:3000

3. **Upload water data:**
   - Go to http://localhost:5000
   - Upload your JSON file with water consumption data

4. **View in Grafana:**
   - Go to http://localhost:3000
   - Login with `admin` / `admin123`
   - The "Water Consumption Dashboard" is automatically provisioned

## Quick Start (Docker Compose)

```bash
# Start all services (InfluxDB, Flask, Grafana)
docker-compose up -d

# Upload test data
curl -X POST -F "file=@test_payload_batch1.json" http://localhost:5000/upload

# Stop services
docker-compose down
```

## Services

### Flask App (port 5000)
- Web UI for uploading JSON water data
- REST API endpoint at `/upload`
- Health check at `/health`
- Automatic deduplication based on timestamp

### InfluxDB (port 8086)
- Time-series database for water consumption data
- Default credentials: `admin` / `admin123`
- Database: `homeassistant`

### Grafana (port 3000)
- Visualization dashboards (Docker Compose only)
- Pre-configured datasource for InfluxDB
- Pre-loaded Water Consumption Dashboard
- Credentials: `admin` / `admin123`

## Expected Data Format

Upload a JSON file with this structure:

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
- `TIME`: Datetime in German format - used as unique identifier for deduplication
- `METERSERIAL`: Meter serial number (stored as tag)
- `GRUPMAS_ID`: Group/master ID (stored as tag)
- `INDEX_CIT`: Index value (numeric field)
- `CONSUM`: Consumption value (numeric field)
- `REAL_MEDIE`: Type or description (text field)

## Key Features

✅ **Web-based Upload UI** - Clean, modern interface for JSON file uploads  
✅ **API Endpoint** - Programmatic JSON import via REST API  
✅ **Automatic Deduplication** - Prevents duplicate entries using timestamp matching  
✅ **Time-Series Database** - InfluxDB for efficient data storage and queries  
✅ **Grafana Integration** - Pre-built dashboards for visualization  
✅ **HA Integration** - Works as official Home Assistant add-on  
✅ **Flexible Configuration** - Via options or environment variables  

## Usage Examples

### Web Interface
Navigate to the application (Home Assistant panel or `http://localhost:5000`) and drag-and-drop your JSON file.

### API Upload
```bash
curl -X POST -F "file=@water-data.json" http://localhost:5000/upload
```

### Health Check
```bash
curl http://localhost:5000/health
```

### Query Data in InfluxDB
```bash
docker exec water-influxdb influx -database homeassistant \
  -execute "SELECT * FROM water_consumption LIMIT 10"
```

## Configuration (Docker Compose)

Edit `docker-compose.yml` to customize:

- **INFLUX_HOST** - InfluxDB hostname
- **INFLUX_PORT** - InfluxDB port (default: 8086)
- **INFLUX_DB** - Database name (default: homeassistant)
- **INFLUX_USER** - Username (default: admin)
- **INFLUX_PASSWORD** - Password (default: admin123)
- **FLASK_PORT** - Flask app port (default: 5000)

## Testing

A test setup with duplicate handling verification is included:

```bash
# Run the duplicate handling test (Docker Compose only)
docker-compose --profile test up test-duplicate

# Expected result: 15 records in database (not 30)
# Uploading 10 + 10 duplicates = 15 total records
```

## Troubleshooting (Docker Compose)

### InfluxDB Connection Refused
```bash
# Wait for InfluxDB to start (10-15 seconds)
docker-compose logs influxdb

# Verify connection
docker exec water-influxdb influx ping
```

### Flask App Can't Reach InfluxDB
```bash
# Check Flask logs
docker-compose logs flask-app

# Verify network connectivity
docker exec flask-app ping influxdb
```

### Grafana Dashboard Empty
```bash
# Verify data exists in InfluxDB
docker exec water-influxdb influx -database homeassistant \
  -execute "SELECT * FROM water_consumption"

# Reload Grafana datasource provisioning
docker-compose restart grafana
```

### Clear All Data
```bash
# Remove all containers and volumes
docker-compose down -v

# Rebuild and restart
docker-compose up -d
```

## Project Structure

```
qa-to-ha-influxdb/
├── water-importer/              # Home Assistant add-on
│   ├── addon.yaml               # HA add-on manifest
│   ├── Dockerfile               # HA-compatible image
│   ├── README.md                # HA setup instructions
│   └── rootfs/
│       ├── run.sh               # Startup script (reads HA options)
│       └── app/
│           ├── main.py          # Flask application
│           ├── requirements.txt  # Python dependencies
│           └── templates/
│               └── index.html    # Web upload UI
│
├── water-data-importer/         # Original Docker Compose app
│   ├── app/
│   │   ├── main.py
│   │   ├── requirements.txt
│   │   └── templates/
│   │       └── index.html
│   ├── Dockerfile
│   ├── run.sh
│   └── config.yaml
│
├── grafana/                     # Grafana provisioning (Docker Compose only)
│   └── provisioning/
│       ├── dashboards/
│       └── datasources/
│
├── docker-compose.yml           # Docker Compose orchestration
├── test_payload_batch1.json     # Test data
├── test_payload_batch2.json     # Test data with duplicates
└── README.md                    # This file
```

## Deduplication Details

**How it works:**
- The `TIME` field (datetime) serves as the unique identifier
- When the same timestamp is written again, InfluxDB overwrites the previous entry
- This prevents duplicate records when re-importing partial batches

**Verification:**
- Upload 10 records (Batch 1)
- Re-upload same 10 records + 5 new records (Batch 2)
- Result: 15 total records (not 20)
- Deduplication works correctly ✓

## Environment Variables

Both Docker Compose and Home Assistant add-on support these environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `INFLUX_HOST` | localhost | InfluxDB server hostname |
| `INFLUX_PORT` | 8086 | InfluxDB port |
| `INFLUX_DB` | homeassistant | InfluxDB database name |
| `INFLUX_USER` | admin | InfluxDB username |
| `INFLUX_PASSWORD` | admin123 | InfluxDB password |
| `FLASK_HOST` | 0.0.0.0 | Flask bind address |
| `FLASK_PORT` | 5000 | Flask port |

## Health Check

The application provides a health check endpoint:

```bash
curl http://localhost:5000/health
```

Returns `200 OK` when the service is healthy.

## License

This project is open source and available on GitHub.

## Support

For issues and feature requests: https://github.com/codrinh/qa-to-ha-influxdb/issues

---

**Need help?**
- HA Add-on: Read [water-importer/README.md](water-importer/README.md)
- Docker Compose: Check service logs with `docker-compose logs [service-name]`
- Data format issues: Review the JSON examples above
