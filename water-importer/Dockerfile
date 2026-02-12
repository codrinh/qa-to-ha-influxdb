ARG BUILD_FROM=homeassistant/aarch64-base:latest
FROM $BUILD_FROM

# Install dependencies and build tools (needed for some Python packages)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    build-base \
    libffi-dev \
    openssl-dev \
    python3-dev

# Set working directory
WORKDIR /app

# Copy application files
COPY rootfs/app/ /app/

# Copy startup script
COPY rootfs/run.sh /

# Install Python requirements (use python -m pip and allow system-package installs)
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --disable-pip-version-check --break-system-packages -r requirements.txt && \
    chmod +x /run.sh

# Create non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Run via the startup script
CMD ["/run.sh"]
