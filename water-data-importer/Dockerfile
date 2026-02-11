FROM python:3.11-alpine

# Install dependencies
RUN apk add --no-cache \
    curl

# Set working directory
WORKDIR /app

# Copy application files
COPY app/ /app/

# Install Python requirements
RUN pip install --no-cache-dir -r requirements.txt

# Set environment variables with defaults
ENV INFLUX_HOST=localhost \
    INFLUX_PORT=8086 \
    INFLUX_DB=homeassistant \
    INFLUX_USER=admin \
    INFLUX_PASSWORD=admin123

# Run the Flask application
CMD ["python3", "/app/main.py"]
