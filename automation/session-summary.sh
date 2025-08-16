#!/bin/bash
# session-summary.sh - Generate session summary statistics

echo "📊 Generating session summary..."

# Get session timing
if [ -f automation/sessions.log ]; then
    session_start=$(tail -n 1 automation/sessions.log | cut -d: -f1-2)
else
    session_start="Unknown"
fi
session_end=$(date)

# Calculate words written this session
if [ -f /tmp/session_start_words ]; then
    start_words=$(cat /tmp/session_start_words)
else
    start_words=0
fi

current_words=$(find manuscript/chapters -name "*.md" -exec wc -w {} + 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
words_written=$((current_words - start_words))

# Count tasks completed
if [ -f automation/task.log ]; then
    tasks_today=$(grep "$(date +%Y-%m-%d)" automation/task.log 2>/dev/null | wc -l)
else
    tasks_today=0
fi

# Count chapters
total_chapters=$(ls manuscript/chapters/chapter-*.md 2>/dev/null | wc -l)

# Generate summary file
mkdir -p automation
summary_file="automation/session-summary-$(date +%Y%m%d_%H%M%S).txt"

cat > "$summary_file" << SUMMARY_EOF
SESSION SUMMARY
===============
Start: $session_start
End: $session_end

PROGRESS
--------
Words Written: $words_written
Tasks Completed: $tasks_today
Total Words: $current_words
Total Chapters: $total_chapters

NEXT ACTIONS
------------
$(if [ -f planning/continuity-flag.txt ]; then cat planning/continuity-flag.txt; fi)
$(if [ -f planning/planning-flag.txt ]; then cat planning/planning-flag.txt; fi)

Generated: $(date)
SUMMARY_EOF

echo "   📄 Summary saved to: $summary_file"
echo "   📝 Words written: $words_written"
echo "   ✅ Tasks completed: $tasks_today"

# Log session end
echo "$(date): Session ended - $words_written words written" >> automation/sessions.log

# Store current word count for next session
echo "$current_words" > /tmp/session_start_words

echo "✅ Session summary complete!"
