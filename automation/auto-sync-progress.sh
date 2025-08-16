#!/bin/bash
# auto-sync-progress.sh - Automatically synchronize progress after file writes

# Get the most recently written chapter file
last_file="${1:-$(ls -t manuscript/chapters/chapter-*.md 2>/dev/null | head -1)}"

if [[ "$last_file" =~ chapter-([0-9]+)\.md ]]; then
    chapter_num=${BASH_REMATCH[1]}
    # Remove leading zeros
    chapter_num=$((10#$chapter_num))
    
    # Count actual words
    word_count=$(wc -w < "$last_file" 2>/dev/null || echo "0")
    
    # Determine status based on word count
    if [ $word_count -ge 3000 ]; then
        status="complete"
        echo "   ✅ Chapter $chapter_num complete: $word_count words"
    elif [ $word_count -ge 500 ]; then
        status="in_progress"
        echo "   🔄 Chapter $chapter_num in progress: $word_count words"
    else
        status="started"
        echo "   📝 Chapter $chapter_num started: $word_count words"
    fi
    
    # Update chapter-status.json using Python if available
    if command -v python3 >/dev/null 2>&1; then
        python3 << PYTHON_EOF
import json
import os
from datetime import datetime

chapter_status_file = 'planning/chapter-status.json'
chapter_key = f'chapter_$chapter_num'

# Ensure planning directory exists
os.makedirs('planning', exist_ok=True)

# Read existing or create new
if os.path.exists(chapter_status_file):
    try:
        with open(chapter_status_file, 'r') as f:
            data = json.load(f)
    except:
        data = {}
else:
    data = {}

# Update this chapter
data[chapter_key] = {
    'status': '$status',
    'words': $word_count,
    'file_exists': True,
    'last_updated': datetime.utcnow().isoformat() + 'Z'
}

# Write back
with open(chapter_status_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f"   ✅ Updated chapter-status.json for chapter $chapter_num")
PYTHON_EOF
    else
        # Fallback to shell-based update
        echo "   ⚠️  Python3 not available - using basic update"
        mkdir -p planning
        if [ ! -f planning/chapter-status.json ]; then
            echo '{}' > planning/chapter-status.json
        fi
    fi
    
    # Log the update
    mkdir -p automation
    echo "$(date): Chapter $chapter_num auto-synced - $word_count words ($status)" >> automation/sync.log
fi
