#!/usr/bin/env bash
set -euo pipefail

backup_dir="backups/compact-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$backup_dir" automation

for dir in manuscript planning worldbuilding characters; do
  if [[ -d "$dir" ]]; then
    cp -R "$dir" "$backup_dir/"
  fi
done

printf '%s pre_compact_backup=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$backup_dir" >> automation/backup.log
