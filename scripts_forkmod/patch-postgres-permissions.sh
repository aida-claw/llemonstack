#!/bin/bash
# =========================================================
# Supabase Multi-Service Patch (v4)
# Flowise public-schema compatibility fix included
# =========================================================
# This script configures PostgreSQL schemas, roles, and
# permissions for a multi-service Llemonstack environment.
#
# It provisions isolated service schemas (service_*),
# applies role-based access control, and ensures required
# privileges for Flowise, Langfuse, LiteLLM, Zep, and
# Lightrag.
#
# Flowise requires additional compatibility with the
# default PostgreSQL session store (connect-pg-simple),
# which uses the 'public' schema for session management.
# Therefore, controlled USAGE and CREATE permissions are
# granted to the Flowise role on the public schema only.
#
# This is a pragmatic compatibility layer and does not
# affect schema isolation for other services.
# =========================================================
set -e

SERVICES=("langfuse" "flowise" "litellm" "zep" "lightrag")

echo "========================================"
echo " Supabase Multi-Service Patch (v4)"
echo "========================================"
echo "[1/4] Checking database connectivity..."

if ! docker exec supabase-db psql -U postgres -c "SELECT 1;" > /dev/null 2>&1; then
  echo "ERROR: Cannot connect to supabase-db"
  exit 1
fi

echo ""
echo "[2/4] Applying service schema permissions..."

for SERVICE in "${SERVICES[@]}"; do
  SCHEMA="service_${SERVICE}"
  ROLE="${SERVICE}"

  echo ""
  echo "----------------------------------------"
  echo "Service: ${SERVICE}"
  echo "Schema : ${SCHEMA}"
  echo "Role   : ${ROLE}"
  echo "----------------------------------------"

  echo "Ensuring schema exists..."
  docker exec supabase-db psql -U postgres -c "CREATE SCHEMA IF NOT EXISTS ${SCHEMA};" > /dev/null

  echo "Applying permissions..."
  docker exec supabase-db psql -U postgres -c "
    GRANT USAGE, CREATE ON SCHEMA ${SCHEMA} TO ${ROLE};
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ${SCHEMA} TO ${ROLE};
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ${SCHEMA} TO ${ROLE};
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA ${SCHEMA} TO ${ROLE};
    ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA} GRANT ALL ON TABLES TO ${ROLE};
    ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA} GRANT ALL ON SEQUENCES TO ${ROLE};
    ALTER DEFAULT PRIVILEGES IN SCHEMA ${SCHEMA} GRANT ALL ON FUNCTIONS TO ${ROLE};
    ALTER ROLE ${ROLE} SET search_path TO ${SCHEMA},public,extensions;
  " > /dev/null

  echo "PASS: ${SERVICE}"
done

echo ""
echo "----------------------------------------"
echo "Flowise session-store public schema fix"
echo "----------------------------------------"

echo "Granting Flowise access to public schema ONLY..."
docker exec supabase-db psql -U postgres -c "
  GRANT USAGE, CREATE ON SCHEMA public TO flowise;
" > /dev/null

echo ""
echo "========================================"
echo " PATCH COMPLETE (v4)"
echo "========================================"