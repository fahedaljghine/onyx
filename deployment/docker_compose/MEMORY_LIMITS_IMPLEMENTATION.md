# Memory Limits Implementation for Onyx Indexing Service

## Overview

This document describes the implementation of memory limits for the Onyx indexing service (Vespa) to prevent excessive RAM usage. The indexing service is now capped at **4GB of RAM** by default.

## What Was Changed

### 1. Docker Compose Files Updated

The following Docker Compose files have been updated with memory limits for the indexing service:

- `docker-compose.dev.yml`
- `docker-compose.prod.yml`
- `docker-compose.prod-cloud.yml`
- `docker-compose.prod-no-letsencrypt.yml`
- `docker-compose.search-testing.yml`
- `docker-compose.multitenant-dev.yml`
- `docker-compose.gpu-dev.yml`

### 2. Resource Configuration

Each indexing service now includes:

```yaml
deploy:
  resources:
    limits:
      cpus: ${VESPA_CPU_LIMIT:-2}
      memory: ${VESPA_MEM_LIMIT:-4g}
    reservations:
      cpus: ${VESPA_CPU_RESERVATION:-1}
      memory: ${VESPA_MEM_RESERVATION:-2g}
```

### 3. Environment Variables

The following environment variables can be configured in your `.env` file:

| Variable | Default | Description |
|----------|---------|-------------|
| `VESPA_MEM_LIMIT` | `4g` | Maximum memory limit for the indexing service |
| `VESPA_CPU_LIMIT` | `2` | Maximum CPU limit for the indexing service |
| `VESPA_MEM_RESERVATION` | `2g` | Memory reservation for the indexing service |
| `VESPA_CPU_RESERVATION` | `1` | CPU reservation for the indexing service |

## How It Works

### Memory Limits
- **Hard Limit**: The indexing service cannot use more than 4GB of RAM
- **Reservation**: 2GB of RAM is reserved for the service
- **Enforcement**: Docker enforces these limits at the container level

### CPU Limits
- **Hard Limit**: Maximum of 2 CPU cores
- **Reservation**: 1 CPU core is reserved
- **Throttling**: Docker will throttle CPU usage if the limit is exceeded

## Benefits

1. **Prevents Host System Crashes**: The indexing service can no longer consume all available RAM
2. **Predictable Resource Usage**: You know exactly how much memory the service will use
3. **Better System Stability**: Other services and the host system remain responsive
4. **Configurable**: Limits can be adjusted based on your system's capabilities

## Applying the Changes

### Option 1: Automatic Script
Use the provided script to apply the changes:

```bash
cd deployment/docker_compose
./apply-memory-limits.sh
```

### Option 2: Manual Restart
Restart your services manually:

```bash
# Stop services
docker compose -f docker-compose.dev.yml -p onyx-stack stop

# Start services with new configuration
docker compose -f docker-compose.dev.yml -p onyx-stack up -d
```

## Verification

After applying the changes, verify the memory limits are working:

```bash
# Check container status
docker compose -f docker-compose.dev.yml -p onyx-stack ps

# Monitor resource usage
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
```

## Customization

### Increasing Memory Limits
If you have more RAM available and want to increase the limit:

```bash
# In your .env file
VESPA_MEM_LIMIT=8g
VESPA_MEM_RESERVATION=4g
```

### Decreasing Memory Limits
If you need to be more conservative with memory:

```bash
# In your .env file
VESPA_MEM_LIMIT=2g
VESPA_MEM_RESERVATION=1g
```

## Troubleshooting

### Service Won't Start
If the indexing service fails to start, it might be due to insufficient memory:

1. Check available system memory: `free -h`
2. Ensure the reservation is less than available memory
3. Consider reducing the memory reservation

### Performance Issues
If you experience performance degradation:

1. Monitor memory usage: `docker stats`
2. Consider increasing the memory limit
3. Check if other services are competing for resources

### Container OOM (Out of Memory)
If the container hits the memory limit:

1. Check logs: `docker logs <container_name>`
2. Consider increasing the memory limit
3. Optimize the indexing configuration if possible

## Support

If you encounter issues with the memory limits:

1. Check the Docker logs for error messages
2. Verify your system has sufficient resources
3. Review the environment variable configuration
4. Open an issue in the Onyx repository

## Future Enhancements

Potential improvements for future versions:

1. **Dynamic Scaling**: Automatic adjustment of limits based on system load
2. **Resource Monitoring**: Built-in monitoring and alerting for resource usage
3. **Profile-based Limits**: Different limit profiles for different deployment scenarios
4. **Graceful Degradation**: Automatic service throttling when approaching limits
