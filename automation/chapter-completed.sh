#!/bin/bash
# chapter-completed.sh - Handle chapter completion tasks

# Get the latest chapter
latest_chapter=$(ls -t manuscript/chapters/chapter-*.md 2>/dev/null | head -1)

if [ -n "$latest_chapter" ]; then
    chapter_num=$(echo "$latest_chapter" | grep -o '[0-9]\+' | head -1)
    word_count=$(wc -w < "$latest_chapter" 2>/dev/null || echo "0")
    
    if [ $word_count -ge 3000 ]; then
        # Chapter is complete
        mkdir -p automation
        echo "$(date): Chapter $chapter_num completed with $word_count words" >> automation/completions.log
        echo "   ✅ Chapter $chapter_num completion logged"
        
        # Every 3 chapters, flag for continuity check
        if [ $((chapter_num % 3)) -eq 0 ]; then
            mkdir -p planning
            echo "CONTINUITY_CHECK_DUE: Chapters $((chapter_num - 2))-$chapter_num ready for review" > planning/continuity-flag.txt
            echo "   📋 Continuity check flagged for chapters $((chapter_num - 2))-$chapter_num"
        fi
        
        # Every 5 chapters, flag for planning review
        if [ $((chapter_num % 5)) -eq 0 ]; then
            mkdir -p planning
            echo "PLANNING_REVIEW_DUE: Completed $chapter_num chapters - time for story planning review" > planning/planning-flag.txt
            echo "   📋 Planning review flagged after $chapter_num chapters"
        fi
        
        # Auto-backup completed chapters if backup script exists
        if [ -x automation/auto-backup.sh ]; then
            echo "   💾 Running auto-backup..."
            automation/auto-backup.sh > /dev/null 2>&1
        fi
    fi
fi
