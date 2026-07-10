#!/usr/bin/env bash
# Package API JAR then start/rebuild services via root docker-compose.yml.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_ONLY=0
SKIP_MANAGE_BUILD=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-only) API_ONLY=1; shift ;;
    --skip-manage-build) SKIP_MANAGE_BUILD=1; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

cd "$ROOT"
API_DIR="$ROOT/senior-post-api"
DIST_DIR="$API_DIR/dist"

echo "==> mvn clean package (senior-post-api)"
(
  cd "$API_DIR"
  mvn clean package -Dmaven.test.skip=true
)

JAR="$(ls -1t "$API_DIR"/server/target/senior-post-server-*.jar 2>/dev/null | grep -v sources | grep -v javadoc | head -n1 || true)"
if [[ -z "${JAR}" ]]; then
  echo "No senior-post-server-*.jar under server/target after package" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"
cp -f "$JAR" "$DIST_DIR/"
cp -f "$JAR" "$DIST_DIR/senior-post-server-1.0-SNAPSHOT.jar"
echo "==> JAR -> dist/$(basename "$JAR")"

echo "==> docker compose build senior-post-api"
docker compose build senior-post-api

if [[ "$API_ONLY" -eq 0 && "$SKIP_MANAGE_BUILD" -eq 0 ]]; then
  echo "==> docker compose build senior-post-manage"
  docker compose build senior-post-manage || true
fi

echo "==> docker compose up -d"
if [[ "$API_ONLY" -eq 1 ]]; then
  docker compose up -d postgresql redis senior-post-api
else
  docker compose up -d
fi

echo ""
echo "API:    http://localhost:9011/backend"
echo "Manage: http://localhost:8080"
echo "Done."
