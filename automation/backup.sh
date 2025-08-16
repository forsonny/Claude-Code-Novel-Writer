#!/bin/bash
# Simple backup script for novel project

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups"
PROJECT_NAME="novel_backup_$DATE"

mkdir -p "$BACKUP_DIR"

# Create tar archive of project
tar -czf "$BACKUP_DIR/$PROJECT_NAME.tar.gz" \
    --exclude="backups" \
    --exclude=".git" \
    --exclude="node_modules" \
    --exclude="*.tmp" \
    .

echo "✅ Backup created: $BACKUP_DIR/$PROJECT_NAME.tar.gz"
