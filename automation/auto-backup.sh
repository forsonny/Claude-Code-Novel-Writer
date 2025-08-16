#!/bin/bash
# automation/auto-backup.sh - Automated backup system

echo "💾 Performing automated backup..."

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/auto"
BACKUP_NAME="novel_auto_backup_$DATE"

mkdir -p "$BACKUP_DIR"

# Count existing auto backups
backup_count=$(ls "$BACKUP_DIR"/novel_auto_backup_*.tar.gz 2>/dev/null | wc -l)

# Remove old backups if more than 10
if [ "$backup_count" -gt 10 ]; then
    echo "🧹 Cleaning old backups..."
    ls -t "$BACKUP_DIR"/novel_auto_backup_*.tar.gz | tail -n +11 | xargs rm -f
fi

# Create backup
tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
    --exclude="backups" \
    --exclude=".git" \
    --exclude="*.tmp" \
    --exclude=".claude/context-injection.txt" \
    manuscript/ planning/ worldbuilding/ characters/ CLAUDE.md .claude/ 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Auto-backup completed: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
    
    # Update backup log
    echo "$(date): Auto-backup $BACKUP_NAME.tar.gz created successfully" >> backups/backup.log
else
    echo "❌ Auto-backup failed"
fi