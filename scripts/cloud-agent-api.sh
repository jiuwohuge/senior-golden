#!/usr/bin/env bash
# Cloud Agent terminal wrapper: run the Spring Boot backend (local profile).
# Keeps the terminal alive with guidance when the jar is not built yet.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JDK17="/usr/lib/jvm/java-17-openjdk-amd64"

JAR="$(ls -1t "$ROOT"/senior-post-api/server/target/senior-post-server-*.jar 2>/dev/null \
       | grep -v sources | grep -v javadoc | head -n1 || true)"
[ -z "$JAR" ] && JAR="$(ls -1t "$ROOT"/senior-post-api/dist/senior-post-server-*.jar 2>/dev/null | head -n1 || true)"

if [ -n "$JAR" ]; then
  echo "[api] starting $JAR (profile=local) -> http://localhost:9011/backend"
  exec env JAVA_HOME="$JDK17" PATH="$JDK17/bin:$PATH" \
       java -jar "$JAR" --spring.profiles.active=local
else
  echo "[api] Backend jar not found — build is blocked on the private"
  echo "[api] cn.nine.commons:commons-framework Maven artifacts."
  echo "[api] Configure the internal Maven registry (~/.m2/settings.xml) or vendor"
  echo "[api] the framework, then run: bash scripts/cloud-agent-install.sh"
  exec sleep infinity
fi
