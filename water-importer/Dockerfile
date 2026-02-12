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
COPY rootfs/run.sh /run.sh

# Install Python requirements
RUN python3 -m pip install --no-cache-dir --break-system-packages -r requirements.txt && \
    chmod +x /run.sh

# No USER appuser here - keep as root for HA compatibility
CMD ["/run.sh"]