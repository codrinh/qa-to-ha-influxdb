ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip

# Set working directory
WORKDIR /app

# Copy application files
COPY rootfs/app/ /app/

# Copy startup script
COPY rootfs/run.sh /

# Install Python requirements
RUN pip install --no-cache-dir -r requirements.txt && \
    chmod +x /run.sh

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Run via the startup script
CMD ["/run.sh"]
