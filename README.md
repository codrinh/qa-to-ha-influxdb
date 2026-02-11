# Water Data Importer - Docker Compose Setup

A complete Docker Compose setup to simulate uploading water consumption data to InfluxDB and visualize it in Grafana.

## Quick Start

1. **Start the containers:**
   ```bash
   docker-compose up -d
   ```

2. **Wait for services to be ready** (about 10-15 seconds)
   - InfluxDB: http://localhost:8086
   - Flask App: http://localhost:5000
   - Grafana: http://localhost:3000

3. **Upload water data:**
   - Go to http://localhost:5000
   - Upload your JSON file with water consumption data

4. **View in Grafana:**
   - Go to http://localhost:3000
   - Login with credentials: `admin` / `admin123`
   - The "Water Consumption Dashboard" is automatically provisioned

## Services

### Flask App (port 5000)
- Upload JSON water consumption data
- Connected to InfluxDB with authentication
- Real-time validation and error handling

### InfluxDB (port 8086)
- Time-series database for storing water data
- Credentials: `admin` / `admin123`
- Database: `homeassistant`

### Grafana (port 3000)
- Visualization dashboard
- Pre-configured datasource for InfluxDB
- Pre-loaded Water Consumption Dashboard
- Credentials: `admin` / `admin123`

## Data Format

Upload a JSON file with this structure:

```json
{
  "data": [
    {
      "TIME": "11.02.2026 10:30:00",
      "METERSERIAL": "METER001",
      "GRUPMAS_ID": "GROUP001",
      "INDEX_CIT": 12345.67,
      "CONSUM": 123.45,
      "REAL_MEDIE": "ACTUAL"
    }
  ]
}
```

## Stop Services

```bash
docker-compose down
```

## Cleanup (remove volumes)

```bash
docker-compose down -v
```

## Troubleshooting

**InfluxDB connection refused:**
- Wait 10-15 seconds for InfluxDB to start
- Check logs: `docker-compose logs influxdb`

**Grafana won't authenticate:**
- Wait a moment and refresh the page
- Reset admin password: `docker-compose exec grafana grafana-cli admin reset-admin-password newpassword`

**Flask app can't reach InfluxDB:**
- Check logs: `docker-compose logs flask-app`
- Ensure `INFLUX_HOST` is set to `influxdb` (not `localhost`)
