#!/usr/bin/env bash
# Cloud Agent install phase for senior-golden (senior-post).
# Idempotent: safe to run repeatedly. Installs system dependencies, prepares a
# local PostgreSQL + Redis, installs admin-panel deps, and builds the backend jar.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JDK17="/usr/lib/jvm/java-17-openjdk-amd64"

# Private parent framework required by senior-post-api. Overridable via env.
COMMONS_REPO="${COMMONS_FRAMEWORK_REPO:-https://github.com/jiuwohuge/commons-framework}"
COMMONS_REF="${COMMONS_FRAMEWORK_REF:-}"
COMMONS_M2_MARKER="$HOME/.m2/repository/cn/nine/commons/commons-framework/1.1-SNAPSHOT"

log() { echo "[cloud-install] $*"; }

# Clone jiuwohuge/commons-framework and `mvn install` it into the local ~/.m2 so
# senior-post-api can resolve its parent POM (cn.nine.commons:commons-framework)
# and the commons-* modules. Relies on the environment GitHub token (git is
# configured with url.insteadOf to inject it) having access to that private repo,
# granted via `repositoryDependencies` in .cursor/environment.json.
ensure_commons_framework() {
  if compgen -G "$COMMONS_M2_MARKER/commons-framework-*.pom" >/dev/null 2>&1; then
    log "commons-framework already present in ~/.m2 — skipping."
    return 0
  fi
  local tmp; tmp="$(mktemp -d)"
  log "Cloning commons-framework from $COMMONS_REPO"
  if [ -n "$COMMONS_REF" ]; then
    git clone --depth 1 --branch "$COMMONS_REF" "$COMMONS_REPO" "$tmp/commons-framework" || { rm -rf "$tmp"; return 1; }
  else
    git clone --depth 1 "$COMMONS_REPO" "$tmp/commons-framework" || { rm -rf "$tmp"; return 1; }
  fi
  log "Installing commons-framework into ~/.m2 (mvn install)"
  ( cd "$tmp/commons-framework" && JAVA_HOME="$JDK17" PATH="$JDK17/bin:$PATH" \
      mvn -q -B clean install -DskipTests ) || { rm -rf "$tmp"; return 1; }
  rm -rf "$tmp"
  log "commons-framework installed."
}

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
# Requires the private Maven parent cn.nine.commons:commons-framework. We first
# install that framework from its GitHub repo into ~/.m2, then build the backend.
# When the framework repo is unreachable the build is skipped with a clear
# warning so infra + admin panel remain usable.
COMMONS_OK=0
if ensure_commons_framework; then COMMONS_OK=1; fi

log "Building backend jar (senior-post-api)"
if [ "$COMMONS_OK" -eq 1 ] && ( cd "$ROOT/senior-post-api" && JAVA_HOME="$JDK17" PATH="$JDK17/bin:$PATH" \
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
  sourced from https://github.com/jiuwohuge/commons-framework.
  The environment could not clone/install it. Ensure:
    1) .cursor/environment.json lists the repo under `repositoryDependencies`, and
    2) the Cursor GitHub App is authorized to access that private repository.
  Then start a fresh agent (or re-run: bash scripts/cloud-agent-install.sh).
  Infrastructure (PostgreSQL/Redis) and the admin panel are unaffected.
EOF
fi

log "Install complete."
