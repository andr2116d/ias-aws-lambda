#!/usr/bin/env bash
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

errors=0
fail() { echo "ERROR: $1"; errors=$((errors + 1)); }
has_tf() { ls "$1"/*.tf >/dev/null 2>&1; }
tracked() { git ls-files --error-unmatch "$1" >/dev/null 2>&1; }

forbidden=$(git ls-files | grep -E '(^|/)\.terraform/|\.tfstate(\.|$)|\.tfplan$|(^|/)tfplan$|\.local\.tfvars$|(^|/)node_modules/|\.zip$|^modules/.*\.terraform\.lock\.hcl$' || true)
if [ -n "$forbidden" ]; then
  while IFS= read -r f; do fail "archivo no permitido: $f"; done <<< "$forbidden"
fi

untracked=$(git ls-files --others --exclude-standard -- '*.tf' '*.tfvars' || true)
if [ -n "$untracked" ]; then
  while IFS= read -r f; do fail "archivo sin commit: $f"; done <<< "$untracked"
fi

for dir in modules/*/; do
  dir="${dir%/}"
  has_tf "$dir" || continue

  for f in versions.tf variables.tf outputs.tf; do
    [ -f "$dir/$f" ] || fail "$dir: falta $f"
  done

  if [ -f "$dir/versions.tf" ]; then
    grep -q 'required_version' "$dir/versions.tf" || fail "$dir/versions.tf: falta required_version"
    grep -q 'required_providers' "$dir/versions.tf" || fail "$dir/versions.tf: falta required_providers"
    grep -q 'hashicorp/aws' "$dir/versions.tf" || fail "$dir/versions.tf: falta hashicorp/aws"
    grep -q '"~> 6.0"' "$dir/versions.tf" || fail "$dir/versions.tf: la versión del provider debe ser ~> 6.0"
  fi

  grep -qE '^[[:space:]]*provider[[:space:]]+"' "$dir"/*.tf && fail "$dir: un módulo no debe declarar provider"
  grep -qE '^[[:space:]]*backend[[:space:]]+"' "$dir"/*.tf && fail "$dir: un módulo no debe declarar backend"
done

for dir in envs/*/; do
  dir="${dir%/}"
  env="$(basename "$dir")"
  has_tf "$dir" || continue

  for f in backend.tf versions.tf variables.tf terraform.tfvars main.tf .terraform.lock.hcl; do
    if [ ! -f "$dir/$f" ]; then
      fail "$dir: falta $f"
    elif ! tracked "$dir/$f"; then
      fail "$dir/$f: no está versionado"
    fi
  done

  if [ -f "$dir/backend.tf" ]; then
    grep -qE "key[[:space:]]*=[[:space:]]*\"$env/terraform.tfstate\"" "$dir/backend.tf" || fail "$dir/backend.tf: la key debe ser $env/terraform.tfstate"
    grep -qE 'use_lockfile[[:space:]]*=[[:space:]]*true' "$dir/backend.tf" || fail "$dir/backend.tf: falta use_lockfile = true"
  fi

  if [ -f "$dir/versions.tf" ]; then
    grep -qE '^[[:space:]]*provider[[:space:]]+"aws"' "$dir/versions.tf" || fail "$dir/versions.tf: falta provider \"aws\""
  fi

  if [ -f "$dir/terraform.tfvars" ]; then
    grep -qE "environment[[:space:]]*=[[:space:]]*\"$env\"" "$dir/terraform.tfvars" || fail "$dir/terraform.tfvars: environment debe ser \"$env\""
  fi
done

validate_dir() {
  local dir="$1"

  local out
  if ! out=$(terraform -chdir="$dir" init -backend=false -input=false -no-color 2>&1); then
    fail "$dir: terraform init falló"
    echo "$out" | tail -15
    return
  fi
  if ! out=$(terraform -chdir="$dir" validate -no-color 2>&1); then
    fail "$dir: terraform validate falló"
    echo "$out"
  fi
}

for dir in bootstrap modules/* envs/*; do
  [ -d "$dir" ] && has_tf "$dir" && validate_dir "$dir"
done

if [ "$errors" -gt 0 ]; then
  echo "$errors error(es)"
  exit 1
fi

echo "Estructura correcta"
