#!/bin/bash
# PATCH: patch-supabase-vector.sh
# PURPOSE: Fix Supabase vector.yml to use placeholder fallback for
#          LOGFLARE_PUBLIC_ACCESS_TOKEN instead of hard requirement.
#          Required because .llemonstack/repos is re-cloned on each llmn init.
# USAGE: Run after every llmn init
# SOP REF: NE-260416-0001-01D

VECTOR_YML="$(dirname "$0")/../.llemonstack/repos/supabase/docker/volumes/logs/vector.yml"

if [ ! -f "$VECTOR_YML" ]; then
  echo "ERROR: vector.yml not found at $VECTOR_YML"
  echo "Has llmn init been run?"
  exit 1
fi

# Check if already patched
if grep -q ":-placeholder" "$VECTOR_YML"; then
  echo "PASS: vector.yml already patched -- no action needed"
  exit 0
fi

# Apply fix
sed -i '' 's/${LOGFLARE_PUBLIC_ACCESS_TOKEN?LOGFLARE_PUBLIC_ACCESS_TOKEN is required}/${LOGFLARE_PUBLIC_ACCESS_TOKEN:-placeholder}/g' "$VECTOR_YML"

# Verify
COUNT=$(grep -c ":-placeholder" "$VECTOR_YML")
if [ "$COUNT" -eq 7 ]; then
  echo "PASS: vector.yml patched successfully ($COUNT occurrences fixed)"
else
  echo "ERROR: Expected 7 replacements, got $COUNT -- check vector.yml manually"
  exit 1
fi
