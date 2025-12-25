# Docker Containerization and Deployment

## Summary

Create Docker configuration for easy deployment of homebase-app.

## Current State

- No Docker configuration
- Manual build and run process
- No deployment scripts
- Dependent on local Lean installation

## Requirements

### Dockerfile

```dockerfile
# Dockerfile

# Build stage
FROM ghcr.io/leanprover/lean4:v4.12.0 AS builder

WORKDIR /app

# Copy lake configuration
COPY lakefile.lean lake-manifest.json ./

# Download dependencies
RUN lake update

# Copy source code
COPY . .

# Build the application
RUN lake build

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libcurl4 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy built binary
COPY --from=builder /app/.lake/build/bin/homebaseApp /app/homebaseApp

# Copy static assets
COPY --from=builder /app/public /app/public

# Create data directory
RUN mkdir -p /app/data /app/logs

# Set environment variables
ENV PORT=3000
ENV DATABASE_PATH=/app/data/homebase.jsonl
ENV LOG_PATH=/app/logs/homebase.log
ENV ENVIRONMENT=production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Run as non-root user
RUN useradd -r -s /bin/false appuser
RUN chown -R appuser:appuser /app
USER appuser

# Start the application
CMD ["/app/homebaseApp"]
```

### Docker Compose

```yaml
# docker-compose.yml

version: '3.8'

services:
  homebase:
    build: .
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - SESSION_SECRET=${SESSION_SECRET}
      - DATABASE_PATH=/app/data/homebase.jsonl
      - LOG_LEVEL=info
      - LOG_FORMAT=json
      - ENVIRONMENT=production
    volumes:
      - homebase-data:/app/data
      - homebase-logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 3s
      retries: 3

volumes:
  homebase-data:
  homebase-logs:
```

### Development Docker Compose

```yaml
# docker-compose.dev.yml

version: '3.8'

services:
  homebase:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - DATABASE_PATH=/app/data/homebase-dev.jsonl
      - LOG_LEVEL=debug
      - ENVIRONMENT=development
    volumes:
      - .:/app
      - homebase-dev-data:/app/data
    command: ["lake", "build", "&&", "./run.sh"]

volumes:
  homebase-dev-data:
```

### Health Check Endpoint

Add to application:

```lean
-- Add to Main.lean routes
app.get "/health" Health.check

-- Actions/Health.lean (new file, not the tracker)
def check : ActionM Unit := do
  -- Check database connection
  let dbOk ← checkDatabaseHealth ctx.db

  if dbOk then
    respondJson { status := "healthy", timestamp := now }
  else
    respondWithStatus 503 { status := "unhealthy", error := "database" }
```

### Deployment Scripts

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

echo "Building Docker image..."
docker build -t homebase-app:latest .

echo "Running database backup..."
./scripts/backup.sh

echo "Stopping current container..."
docker-compose down

echo "Starting new container..."
docker-compose up -d

echo "Waiting for health check..."
sleep 5
curl -f http://localhost:3000/health || exit 1

echo "Deployment complete!"
```

```bash
#!/bin/bash
# scripts/backup.sh

BACKUP_DIR="/backups/homebase"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec homebase cat /app/data/homebase.jsonl > \
    $BACKUP_DIR/homebase_$TIMESTAMP.jsonl

# Keep only last 30 backups
ls -t $BACKUP_DIR/homebase_*.jsonl | tail -n +31 | xargs -r rm

echo "Backup complete: $BACKUP_DIR/homebase_$TIMESTAMP.jsonl"
```

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml

name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to server
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_KEY }}
          script: |
            cd /opt/homebase
            docker-compose pull
            docker-compose up -d
```

### Production Checklist

```markdown
## Pre-Deployment Checklist

- [ ] SESSION_SECRET set (not default value)
- [ ] Database path writable
- [ ] Logs directory writable
- [ ] HTTPS configured (via reverse proxy)
- [ ] Backups configured
- [ ] Monitoring configured
- [ ] Resource limits set

## Environment Variables Required

- SESSION_SECRET: Strong random string (32+ chars)
- DATABASE_PATH: Path to JSONL database file
- LOG_PATH: Path to log file
- PORT: HTTP port (default 3000)
```

### Reverse Proxy (nginx)

```nginx
# /etc/nginx/sites-available/homebase

server {
    listen 80;
    server_name homebase.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name homebase.example.com;

    ssl_certificate /etc/letsencrypt/live/homebase.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/homebase.example.com/privkey.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # SSE support
    location /events/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Connection '';
        proxy_buffering off;
        proxy_cache off;
        chunked_transfer_encoding off;
    }
}
```

## Acceptance Criteria

- [ ] Dockerfile builds successfully
- [ ] Docker image runs application
- [ ] docker-compose configuration works
- [ ] Health check endpoint implemented
- [ ] Deployment script functional
- [ ] Backup script functional
- [ ] CI/CD pipeline configured
- [ ] Documentation for deployment

## Technical Notes

- Multi-stage build reduces image size
- Non-root user for security
- Volume mounts for persistence
- Health checks for orchestration
- Consider Kubernetes config (future)

## Priority

Low - Needed for production deployment

## Estimate

Medium - Docker setup + CI/CD + documentation
