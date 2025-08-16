#!/bin/bash
# sync-state.sh - Synchronize progress tracking with actual files
# FIXED VERSION: Corrected shell scripting errors and improved reliability

echo "🔧 Fantasy Novel Writing System - State Synchronization"
echo "======================================================"

# Ensure required directories exist
mkdir -p planning manuscript/chapters backups

# Create backup of current tracking files
echo "📦 Creating backup of current tracking files..."
backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"
cp planning/*.json "$backup_dir/" 2>/dev/null || echo "   No existing tracking files to backup"

# Scan for chapter files
echo "📁 Scanning manuscript/chapters/ directory..."
mapfile -t chapter_files < <(ls manuscript/chapters/chapter-*.md 2>/dev/null | sort -V)

if [ ${#chapter_files[@]} -eq 0 ]; then
    echo "   No chapter files found - initializing fresh state"
    
    # Use variable for timestamp instead of command substitution in heredoc
    current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    cat > planning/plot-progress.json << EOF
{
  "current_chapter": 1,
  "current_scene": 1,
  "total_words": 0,
  "chapter_status": "not_started",
  "last_action": "fresh_initialization",
  "next_milestone": "create_outline",
  "chapters_completed": [],
  "last_sync_time": "$current_time"
}
EOF

    cat > planning/chapter-status.json << 'EOF'
{
  "chapter_1": {"status": "not_started", "words": 0, "file_exists": false}
}
EOF
    echo "✅ Fresh state initialized"
    exit 0
fi

echo "📊 Found ${#chapter_files[@]} chapter files. Analyzing..."

# Analyze each file and build corrected state
total_words=0
highest_chapter=0
incomplete_chapters=()
declare -A chapter_data

for file in "${chapter_files[@]}"; do
    if [[ $file =~ chapter-([0-9]+)\.md$ ]]; then
        chapter_num=${BASH_REMATCH[1]}
        chapter_num=$((10#$chapter_num))  # Remove leading zeros
        
        if [ $chapter_num -gt $highest_chapter ]; then
            highest_chapter=$chapter_num
        fi
        
        # Count words in file safely
        if [ -r "$file" ]; then
            word_count=$(wc -w < "$file" 2>/dev/null || echo "0")
        else
            word_count=0
        fi
        total_words=$((total_words + word_count))
        
        # Determine status based on word count
        if [ $word_count -ge 3000 ]; then
            status="complete"
        elif [ $word_count -ge 500 ]; then
            status="in_progress"
            incomplete_chapters+=($chapter_num)
        else
            status="not_started"
            incomplete_chapters+=($chapter_num)
        fi
        
        # Store chapter data
        chapter_data[$chapter_num]="$status:$word_count"
        
        echo "   📄 Chapter $chapter_num: $word_count words ($status)"
    fi
done

# Determine next chapter to work on
if [ ${#incomplete_chapters[@]} -gt 0 ]; then
    # Sort incomplete chapters and take the first one
    IFS=$'\n' read -d '' -r -a sorted_incomplete < <(printf '%s\n' "${incomplete_chapters[@]}" | sort -n)
    next_chapter=${sorted_incomplete[0]}
    next_status="in_progress"
else
    # All chapters complete, start next one
    next_chapter=$((highest_chapter + 1))
    next_status="not_started"
fi

echo ""
echo "📊 Analysis Results:"
echo "   Total words: $total_words"
echo "   Highest chapter: $highest_chapter"
echo "   Next chapter to work on: $next_chapter"
echo "   Incomplete chapters: ${incomplete_chapters[*]:-none}"

# Write corrected chapter-status.json with proper error handling
echo "💾 Writing corrected chapter-status.json..."
temp_file=$(mktemp)

{
    echo "{"
    first=true
    
    # Sort chapter numbers for consistent output
    for chapter_num in $(printf '%s\n' "${!chapter_data[@]}" | sort -n); do
        IFS=':' read -r status word_count <<< "${chapter_data[$chapter_num]}"
        
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        printf '  "chapter_%d": {"status": "%s", "words": %d, "file_exists": true}' "$chapter_num" "$status" "$word_count"
    done
    echo ""
    echo "}"
} > "$temp_file"

# Verify JSON is valid before replacing
if python3 -m json.tool "$temp_file" >/dev/null 2>&1; then
    mv "$temp_file" planning/chapter-status.json
    echo "   ✅ Chapter status updated successfully"
else
    echo "   ❌ Generated invalid JSON, keeping original"
    rm "$temp_file"
fi

# Build completed chapters array
completed_chapters=()
for chapter_num in "${!chapter_data[@]}"; do
    IFS=':' read -r status word_count <<< "${chapter_data[$chapter_num]}"
    if [ "$status" = "complete" ]; then
        completed_chapters+=($chapter_num)
    fi
done

# Sort completed chapters
if [ ${#completed_chapters[@]} -gt 0 ]; then
    IFS=$'\n' read -d '' -r -a completed_chapters < <(printf '%s\n' "${completed_chapters[@]}" | sort -n)
fi

# Convert completed chapters array to JSON format
completed_json="["
for i in "${!completed_chapters[@]}"; do
    if [ $i -gt 0 ]; then
        completed_json+=", "
    fi
    completed_json+="${completed_chapters[$i]}"
done
completed_json+="]"

# Write corrected plot-progress.json
echo "💾 Writing corrected plot-progress.json..."
current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sync_timestamp=$(date +%Y%m%d_%H%M%S)

temp_file=$(mktemp)
cat > "$temp_file" << EOF
{
  "current_chapter": $next_chapter,
  "current_scene": 1,
  "total_words": $total_words,
  "chapter_status": "$next_status",
  "last_action": "state_synchronized_$sync_timestamp",
  "next_milestone": "complete_chapter_$next_chapter",
  "chapters_completed": $completed_json,
  "last_sync_time": "$current_time"
}
EOF

# Verify JSON is valid before replacing
if python3 -m json.tool "$temp_file" >/dev/null 2>&1; then
    mv "$temp_file" planning/plot-progress.json
    echo "   ✅ Plot progress updated successfully"
else
    echo "   ❌ Generated invalid JSON, keeping original"
    rm "$temp_file"
fi

echo ""
echo "✅ State synchronization complete!"
echo ""
echo "📋 Summary:"
echo "   - Progress tracking updated to match actual files"
echo "   - Next chapter to work on: $next_chapter"
echo "   - Total synchronized words: $total_words"
echo "   - Completed chapters: ${#completed_chapters[@]}"
echo ""
echo "🚀 You can now safely resume novel generation."
echo "   The system will continue from chapter $next_chapter."

# Optional: Show current dashboard status if available
if [ -f "automation/dashboard.py" ] && command -v python3 >/dev/null 2>&1; then
    echo ""
    echo "📊 Current status:"
    python3 automation/dashboard.py 2>/dev/null || echo "   (Dashboard needs dependencies)"
fi

# Create context injection reminder
echo '<system_reminder>STATE SYNCHRONIZED: Progress tracking now matches actual files. Current chapter: '$next_chapter'. Total words: '$total_words'. Ready to continue generation.</system_reminder>' >> .claude/context-injection.txt 2>/dev/null || true

echo ""
echo "✅ State synchronization completed successfully!"