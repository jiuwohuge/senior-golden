#!/usr/bin/env bash
# Cloud Agent start phase: bring up PostgreSQL + Redis (idempotent, returns).
set -euo pipefail

log() { echo "[cloud-start] $*"; }

# PostgreSQL on port 65432
PGVER="$(ls /etc/postgresql 2>/dev/null | sort -V | tail -1 || true)"
if [ -n "$PGVER" ]; then
  sudo pg_ctlcluster "$PGVER" main start 2>/dev/null || true
  for _ in $(seq 1 30); do sudo -u postgres pg_isready -p 65432 -q && break; sleep 1; done
  if sudo -u postgres pg_isready -p 65432 -q; then
    log "PostgreSQL up on 127.0.0.1:65432"
  else
    log "WARNING: PostgreSQL did not become ready on :65432"
  fi
fi

# Redis on port 6379 (AOF data under /var/lib/redis, not the repo tree)
if ! redis-cli ping >/dev/null 2>&1; then
  sudo redis-server --daemonize yes --appendonly yes --dir /var/lib/redis
fi
if redis-cli ping >/dev/null 2>&1; then
  log "Redis up on 127.0.0.1:6379"
else
  log "WARNING: Redis did not respond to ping"
fi

log "Start complete."
