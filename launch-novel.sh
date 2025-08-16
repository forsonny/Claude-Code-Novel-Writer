#!/bin/bash
# launch-novel.sh - Start autonomous novel generation with improved state management

echo "🚀 Initializing Fantasy Novel Writing System v3.0..."

# Check if this is a restart/resume scenario
if [ -d "manuscript/chapters" ] && [ -n "$(ls manuscript/chapters/ 2>/dev/null)" ]; then
    echo "📁 Existing manuscript files detected - performing state synchronization..."
    
    # Run state synchronization first
    ./sync-state.sh
    
    echo ""
    echo "🔄 State synchronized. Ready to resume generation."
    echo ""
else
    echo "📁 Fresh start - creating project structure..."
    
    # Initialize project structure (additional directories if needed)
    mkdir -p .claude/agents .claude/memory manuscript/chapters planning worldbuilding characters automation

    echo "📁 Directory structure created"
fi

# Create sync script if it doesn't exist
if [ ! -f "sync-state.sh" ]; then
    echo "🔧 Creating state synchronization script..."
    
    cat > sync-state.sh << 'SYNC_EOF'
#!/bin/bash
# sync-state.sh - Synchronize progress tracking with actual files

echo "🔧 Fantasy Novel Writing System - State Synchronization"
echo "======================================================"

# Create backup of current tracking files
echo "📦 Creating backup of current tracking files..."
mkdir -p backups/$(date +%Y%m%d_%H%M%S)
cp planning/*.json backups/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || echo "   No existing tracking files to backup"

# Scan for chapter files
echo "📁 Scanning manuscript/chapters/ directory..."
chapter_files=($(ls manuscript/chapters/chapter-*.md 2>/dev/null | sort -V))

if [ ${#chapter_files[@]} -eq 0 ]; then
    echo "   No chapter files found - initializing fresh state"
    cat > planning/plot-progress.json << 'EOF'
{
  "current_chapter": 1,
  "current_scene": 1,
  "total_words": 0,
  "chapter_status": "not_started",
  "last_action": "fresh_initialization",
  "next_milestone": "create_outline",
  "chapters_completed": [],
  "last_sync_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
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

# Generate corrected chapter status
echo "{"
first=true
total_words=0
highest_chapter=0
incomplete_chapters=()

for file in "${chapter_files[@]}"; do
    if [[ $file =~ chapter-([0-9]+)\.md$ ]]; then
        chapter_num=${BASH_REMATCH[1]}
        chapter_num=$((10#$chapter_num))  # Remove leading zeros
        
        if [ $chapter_num -gt $highest_chapter ]; then
            highest_chapter=$chapter_num
        fi
        
        # Count words in file
        word_count=$(wc -w < "$file" 2>/dev/null || echo "0")
        total_words=$((total_words + word_count))
        
        # Determine status
        if [ $word_count -ge 3000 ]; then
            status="complete"
        elif [ $word_count -ge 500 ]; then
            status="in_progress"
            incomplete_chapters+=($chapter_num)
        else
            status="not_started"
            incomplete_chapters+=($chapter_num)
        fi
        
        # Add to JSON (manually building to avoid jq dependency)
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        echo "  \"chapter_$chapter_num\": {\"status\": \"$status\", \"words\": $word_count, \"file_exists\": true}"
        
        echo "   📄 Chapter $chapter_num: $word_count words ($status)"
    fi
done
echo "}"

# Determine next chapter to work on
if [ ${#incomplete_chapters[@]} -gt 0 ]; then
    # Sort incomplete chapters and take the first one
    IFS=$'\n' sorted_incomplete=($(sort -n <<<"${incomplete_chapters[*]}"))
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

# Write corrected chapter-status.json
echo "💾 Writing corrected chapter-status.json..."
{
    echo "{"
    first=true
    
    for file in "${chapter_files[@]}"; do
        if [[ $file =~ chapter-([0-9]+)\.md$ ]]; then
            chapter_num=${BASH_REMATCH[1]}
            chapter_num=$((10#$chapter_num))
            
            word_count=$(wc -w < "$file" 2>/dev/null || echo "0")
            
            if [ $word_count -ge 3000 ]; then
                status="complete"
            elif [ $word_count -ge 500 ]; then
                status="in_progress"
            else
                status="not_started"
            fi
            
            if [ "$first" = true ]; then
                first=false
            else
                echo ","
            fi
            echo "  \"chapter_$chapter_num\": {\"status\": \"$status\", \"words\": $word_count, \"file_exists\": true}"
        fi
    done
    echo "}"
} > planning/chapter-status.json

# Build completed chapters array
completed_chapters=()
for file in "${chapter_files[@]}"; do
    if [[ $file =~ chapter-([0-9]+)\.md$ ]]; then
        chapter_num=${BASH_REMATCH[1]}
        chapter_num=$((10#$chapter_num))
        word_count=$(wc -w < "$file" 2>/dev/null || echo "0")
        
        if [ $word_count -ge 3000 ]; then
            completed_chapters+=($chapter_num)
        fi
    fi
done

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
cat > planning/plot-progress.json << EOF
{
  "current_chapter": $next_chapter,
  "current_scene": 1,
  "total_words": $total_words,
  "chapter_status": "$next_status",
  "last_action": "state_synchronized_$(date +%Y%m%d_%H%M%S)",
  "next_milestone": "complete_chapter_$next_chapter",
  "chapters_completed": $completed_json,
  "last_sync_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

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

# Optional: Show current dashboard status
if [ -f "automation/dashboard.py" ]; then
    echo ""
    echo "📊 Current status:"
    python3 automation/dashboard.py
fi
SYNC_EOF

    chmod +x sync-state.sh
    echo "   ✅ Sync script created"
fi

# Create all essential .claude configuration files
echo "🤖 Ensuring Claude configuration files exist..."

# Initialize progress tracking if it doesn't exist or is outdated
if [ ! -f "planning/plot-progress.json" ] || [ ! -f "planning/chapter-status.json" ]; then
    echo "📊 Initializing progress tracking..."
    
    cat > planning/plot-progress.json << 'EOF'
{
  "current_chapter": 1,
  "current_scene": 1,
  "total_words": 0,
  "chapter_status": "not_started",
  "last_action": "initialized",
  "next_milestone": "create_outline",
  "chapters_completed": [],
  "last_sync_time": "never"
}
EOF

    cat > planning/chapter-status.json << 'EOF'
{
  "chapter_1": {"status": "not_started", "words": 0, "file_exists": false}
}
EOF
    echo "   ✅ Progress tracking initialized"
fi

# Initialize other tracking files if they don't exist
if [ ! -f "worldbuilding/world-state.json" ]; then
    echo "🌍 Initializing world state tracking..."
    cat > worldbuilding/world-state.json << 'EOF'
{
  "locations_established": [],
  "magic_rules": [],
  "cultures": [],
  "history_timeline": [],
  "notable_items": []
}
EOF
    echo "   ✅ World state initialized"
fi

if [ ! -f "characters/character-knowledge.json" ]; then
    echo "👥 Initializing character tracking..."
    cat > characters/character-knowledge.json << 'EOF'
{
  "protagonist": {"knows": [], "believes": [], "relationships": {}},
  "characters_created": []
}
EOF
    echo "   ✅ Character tracking initialized"
fi

echo "💾 All initialization files verified/created"

echo ""
echo "✅ Fantasy Novel Writing System v3.0 ready!"
echo ""
echo "🎯 Next steps:"
echo "1. Run: claude --dangerously-skip-permissions --continue"
echo "2. The system will automatically synchronize state and continue generation"
echo "3. Monitor progress with: python3 automation/dashboard.py --monitor"
echo ""
echo "📝 The improved system will:"
echo "   ✅ Always check existing files before creating new ones"
echo "   ✅ Prevent chapter duplication through state synchronization"
echo "   ✅ Maintain accurate progress tracking"
echo "   ✅ Self-correct any inconsistencies automatically"
echo ""
echo "🚨 IMPORTANT: The system now prevents duplication and maintains"
echo "   consistent state across sessions. It will resume exactly where"
echo "   it left off without creating duplicate chapters."
echo ""

# Run state sync to ensure everything is aligned
echo "🔄 Running final state synchronization..."
./sync-state.sh

echo ""
echo "Ready to launch autonomous novel generation!"
echo "Run: claude --dangerously-skip-permissions --continue"