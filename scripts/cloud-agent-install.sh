#!/usr/bin/env bash
# Cloud Agent install phase for senior-golden (senior-post).
# Idempotent: safe to run repeatedly. Installs system dependencies, prepares a
# local PostgreSQL + Redis, installs admin-panel deps, and builds the backend jar.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JDK17="/usr/lib/jvm/java-17-openjdk-amd64"

log() { echo "[cloud-install] $*"; }

# --- 1. System packages (JDK 17, Maven, PostgreSQL, Redis) -------------------
MISSING=()
for pkg in openjdk-17-jdk maven postgresql postgresql-contrib redis-server; do
  dpkg -s "$pkg" >/dev/null 2>&1 || MISSING+=("$pkg")
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  log "Installing system packages: ${MISSING[*]}"
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${MISSING[@]}"
else
  log "System packages already present."
fi

# --- 2. PostgreSQL cluster: port 65432 + database/credentials ----------------
# Matches senior-post-api/server/src/main/resources/application-local.yml
PGVER="$(ls /etc/postgresql 2>/dev/null | sort -V | tail -1 || true)"
if [ -n "$PGVER" ]; then
  PGCONF="/etc/postgresql/$PGVER/main/postgresql.conf"
  if ! grep -qE '^port = 65432' "$PGCONF"; then
    log "Setting PostgreSQL port to 65432"
    sudo sed -i "s/^#\?port = .*/port = 65432/" "$PGCONF"
  fi
  sudo pg_ctlcluster "$PGVER" main start 2>/dev/null || sudo pg_ctlcluster "$PGVER" main restart
  for _ in $(seq 1 30); do sudo -u postgres pg_isready -p 65432 -q && break; sleep 1; done
  sudo -u postgres psql -p 65432 -c "ALTER USER postgres WITH PASSWORD 'myppost@2026';" >/dev/null
  sudo -u postgres psql -p 65432 -tc "SELECT 1 FROM pg_database WHERE datname='senior_post'" | grep -q 1 \
    || sudo -u postgres psql -p 65432 -c "CREATE DATABASE senior_post;" >/dev/null
  log "PostgreSQL ready (db=senior_post on 127.0.0.1:65432)"
fi

# --- 3. Admin panel (senior-post-manage) dependencies ------------------------
log "Installing admin-panel dependencies (npm ci)"
( cd "$ROOT/senior-post-manage" && npm ci )

# --- 4. Backend jar (senior-post-api) ----------------------------------------
# Requires the private Maven parent cn.nine.commons:commons-framework. When that
# is unavailable the build is skipped with a clear warning so infra + admin panel
# remain usable.
log "Building backend jar (senior-post-api)"
if ( cd "$ROOT/senior-post-api" && JAVA_HOME="$JDK17" PATH="$JDK17/bin:$PATH" \
       mvn -q -B clean package -Dmaven.test.skip=true ); then
  mkdir -p "$ROOT/senior-post-api/dist"
  JAR="$(ls -1t "$ROOT"/senior-post-api/server/target/senior-post-server-*.jar 2>/dev/null \
         | grep -v sources | grep -v javadoc | head -n1 || true)"
  if [ -n "$JAR" ]; then
    cp -f "$JAR" "$ROOT/senior-post-api/dist/"
    log "Backend build OK -> dist/$(basename "$JAR")"
  fi
else
  cat >&2 <<'EOF'
[cloud-install] WARNING: backend build failed and was skipped.
  senior-post-api depends on the private Maven parent
  `cn.nine.commons:commons-framework` (plus commons-basic/web/security/redis-starter),
  which is not on Maven Central and is not vendored in this repository.
  To enable backend builds, configure access to the internal Maven registry via
  ~/.m2/settings.xml (see MAVEN_REPO_* secrets) or publish/vendor the framework,
  then re-run: bash scripts/cloud-agent-install.sh
  Infrastructure (PostgreSQL/Redis) and the admin panel are unaffected.
EOF
fi

log "Install complete."
