#!/bin/bash
# pre-compact-backup.sh - Backup before context compaction

echo "💾 Creating pre-compact backup..."

backup_dir="backups/compact-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Backup critical files
if [ -d manuscript/chapters ]; then
    cp -r manuscript/chapters "$backup_dir/" 2>/dev/null
    echo "   ✅ Backed up manuscript"
fi

if [ -d planning ]; then
    cp -r planning "$backup_dir/" 2>/dev/null
    echo "   ✅ Backed up planning files"
fi

if [ -d worldbuilding ]; then
    cp -r worldbuilding "$backup_dir/" 2>/dev/null
    echo "   ✅ Backed up worldbuilding"
fi

if [ -d characters ]; then
    cp -r characters "$backup_dir/" 2>/dev/null
    echo "   ✅ Backed up characters"
fi

echo "✅ Pre-compact backup created: $backup_dir"
mkdir -p automation
echo "$(date): Pre-compact backup created in $backup_dir" >> automation/backup.log
