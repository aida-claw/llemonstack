#!/bin/bash
# PATCH: patch-postgres-permissions.sh
# PURPOSE: Grant correct Postgres schema permissions to service DB users.
#          Replicates what llmn init postgres.ts does but runs from inside
#          the supabase-db container, bypassing the host->Docker connection
#          issue that occurs in HOST Ollama mode.
# USAGE: Run after llmn start (Supabase must be healthy)
# SOP REF: NE-260416-0001-01D

set -e

SERVICES=("langfuse" "flowise" "litellm" "zep" "lightrag")

echo "Checking Supabase is healthy..."
if ! docker exec supabase-db psql -U postgres -c "SELECT 1;" > /dev/null 2>&1; then
  echo "ERROR: Cannot connect to supabase-db. Is the stack running?"
  exit 1
fi

for SERVICE in "${SERVICES[@]}"; do
  SCHEMA="service_${SERVICE}"
  USERNAME="${SERVICE}"

  echo "--- Processing ${SERVICE} ---"

  # Check if user exists
  USER_EXISTS=$(docker exec supabase-db psql -U postgres -tAc \
    "SELECT 1 FROM pg_roles WHERE rolname='${USERNAME}';" 2>/dev/null)

  if [ "$USER_EXISTS" != "1" ]; then
    echo "SKIP: User '${USERNAME}' does not exist -- skipping"
    continue
  fi

  # Check if schema exists
  SCHEMA_EXISTS=$(docker exec supabase-db psql -U postgres -tAc \
    "SELECT 1 FROM pg_namespace WHERE nspname='${SCHEMA}';" 2>/dev/null)

  if [ "$SCHEMA_EXISTS" != "1" ]; then
    echo "SKIP: Schema '${SCHEMA}' does not exist -- skipping"
    continue
  fi

  # Grant postgres membership in service role (required for ALTER TABLE OWNER)
  docker exec supabase-db psql -U postgres -c \
    "GRANT ${USERNAME} TO postgres;" > /dev/null 2>&1 || true

  # Grant schema permissions
  docker exec supabase-db psql -U postgres -c "
    GRANT ALL PRIVILEGES ON SCHEMA ${SCHEMA} TO ${USERNAME};
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${SCHEMA} TO ${USERNAME};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${SCHEMA} TO ${USERNAME};
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA ${SCHEMA} TO ${USERNAME};
    ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA} GRANT ALL ON TABLES TO ${USERNAME};
    ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA} GRANT ALL ON SEQUENCES TO ${USERNAME};
    ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA} GRANT ALL ON FUNCTIONS TO ${USERNAME};
    GRANT USAGE ON SCHEMA extensions TO ${USERNAME};
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA extensions TO ${USERNAME};
    GRANT USAGE ON SCHEMA public TO ${USERNAME};
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO ${USERNAME};
    ALTER ROLE ${USERNAME} SET search_path TO ${SCHEMA},extensions,public;
  " 2>&1

  echo "PASS: ${SERVICE} permissions granted successfully"
done

echo ""
echo "PASS: All service permissions patched successfully"
