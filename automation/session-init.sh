#!/bin/bash
# session-init.sh - Initialize session with all necessary checks

echo "🚀 Initializing Writing Session..."

# Clean up old context injection (prevent infinite growth)
if [ -f .claude/context-injection.txt ]; then
    # Keep only last 50 lines to prevent infinite growth
    if [ $(wc -l < .claude/context-injection.txt) -gt 50 ]; then
        tail -n 50 .claude/context-injection.txt > .claude/context-injection.tmp
        mv .claude/context-injection.tmp .claude/context-injection.txt
        echo "   ✅ Cleaned up context injection file"
    fi
fi

# Run system health check if it exists
if [ -x automation/system-health-check.sh ]; then
    echo "   🔍 Running health check..."
    automation/system-health-check.sh > /tmp/health.log 2>&1
    health_score=$(grep "Health Score:" /tmp/health.log | grep -o '[0-9]*' | head -1)
    
    if [ -n "$health_score" ]; then
        if [ "$health_score" -lt 70 ]; then
            echo "⚠️  HEALTH_WARNING: System health is $health_score/100 - needs attention" >> .claude/context-injection.txt
        else
            echo "   ✅ System health: $health_score/100"
        fi
    fi
fi

# Check for duplicates if checker exists
if [ -x automation/duplicate-checker.sh ]; then
    echo "   🔍 Checking for duplicates..."
    automation/duplicate-checker.sh > /tmp/duplicates.log 2>&1
    if grep -q "DUPLICATE FOUND" /tmp/duplicates.log; then
        echo "🚨 DUPLICATES_EXIST: Multiple files for same chapter detected" >> .claude/context-injection.txt
        echo "   ⚠️  Duplicates detected - see /tmp/duplicates.log"
    else
        echo "   ✅ No duplicates found"
    fi
fi

# Quick state sync check
actual_chapters=$(ls manuscript/chapters/chapter-*.md 2>/dev/null | wc -l)
echo "   📚 Found $actual_chapters chapter files"

if [ -f planning/plot-progress.json ]; then
    tracked_chapter=$(grep -o '"current_chapter":[[:space:]]*[0-9]*' planning/plot-progress.json | grep -o '[0-9]*$' || echo "1")
    
    if [ "$actual_chapters" -gt 0 ]; then
        if [ $((tracked_chapter - actual_chapters)) -gt 1 ] || [ $((actual_chapters - tracked_chapter)) -gt 1 ]; then
            echo "⚠️  SYNC_NEEDED: Tracking shows chapter $tracked_chapter but $actual_chapters files exist" >> .claude/context-injection.txt
            echo "   ⚠️  Progress tracking may be out of sync"
        else
            echo "   ✅ Progress tracking aligned"
        fi
    fi
fi

# Check for pending review flags
if [ -f planning/continuity-flag.txt ]; then
    echo "   📋 Continuity check pending"
    cat planning/continuity-flag.txt >> .claude/context-injection.txt
fi

if [ -f planning/planning-flag.txt ]; then
    echo "   📋 Planning review pending"
    cat planning/planning-flag.txt >> .claude/context-injection.txt
fi

# Log session start
mkdir -p automation
echo "$(date): Session started - $actual_chapters chapters exist" >> automation/sessions.log

# Store starting word count for session tracking
current_words=$(find manuscript/chapters -name "*.md" -exec wc -w {} + 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
echo "$current_words" > /tmp/session_start_words

echo "✅ Session initialized successfully!"
