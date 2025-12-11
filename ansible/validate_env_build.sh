#!/usr/bin/env bash
# validate_env_build.sh - Pre-flight validator for env_vars.sh
# Usage: ./validate_env_build.sh [path-to-env_vars.sh]

set -euo pipefail

ENV_FILE="${1:-./env_vars.sh}"

# --- Required variables list ---
REQUIRED_VARS=(
  admin_id
  admin_set
  admin_hash
  secops_id
  secops_pwd
  helper_id
  helper_pwd
  ipa_dm_password
  ipa_admin_password
  iso_path
)

# --- Optional variables with defaults ---
OPTIONAL_VARS=(
  VM_MEM
  VM_CPU
  VM_DISK_SIZE
  VM_HOST
  VM_ISO
  VG_NAME
)

echo "🔍 Validating environment file: $ENV_FILE"

# Ensure file exists
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ ERROR: $ENV_FILE not found."
  exit 1
fi

# Source the file safely
set -a
. "$ENV_FILE"
set +a

# Check required variables
MISSING=()
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    MISSING+=("$var")
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "❌ ERROR: Missing required variables: ${MISSING[*]}"
  exit 1
fi

# Basic sanity checks
if ! [[ "$VM_MEM" =~ ^[0-9]+$ ]]; then
  echo "❌ ERROR: VM_MEM must be numeric (got '$VM_MEM')"
  exit 1
fi

if ! [[ "$VM_CPU" =~ ^[0-9]+$ ]]; then
  echo "❌ ERROR: VM_CPU must be numeric (got '$VM_CPU')"
  exit 1
fi

if [[ "$VM_DISK_SIZE" -lt 10 ]]; then
  echo "❌ ERROR: VM_DISK_SIZE too small (must be >=10 GB)"
  exit 1
fi

# Report summary
echo "✅ All required variables present."
echo "   VM_HOST=$VM_HOST"
echo "   VM_ISO=$VM_ISO"
echo "   VG_NAME=$VG_NAME"
echo "   VM_MEM=$VM_MEM MB"
echo "   VM_CPU=$VM_CPU cores"
echo "   VM_DISK_SIZE=$VM_DISK_SIZE GB"

echo "✅ Environment file validated successfully."

