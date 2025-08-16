#!/bin/bash
# automation/system-health-check.sh - System health monitoring
# FIXED VERSION: Improved error handling and safety

echo "🔍 Running system health check..."

# Initialize health tracking
health_issues=()
health_score=100

# Ensure planning directory exists
mkdir -p planning

# Check essential directories
required_dirs=(".claude/agents" "manuscript/chapters" "planning" "worldbuilding" "characters" "automation")
echo "📁 Checking essential directories..."
for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        health_issues+=("Missing directory: $dir")
        health_score=$((health_score - 10))
        echo "   ❌ Missing: $dir"
        # Auto-create missing directories
        mkdir -p "$dir" && echo "   🔧 Created: $dir"
    else
        echo "   ✅ Found: $dir"
    fi
done

# Check essential files
required_files=("CLAUDE.md" ".claude/settings.json")
echo "📄 Checking essential files..."
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        health_issues+=("Missing critical file: $file")
        health_score=$((health_score - 15))
        echo "   ❌ Missing: $file"
    else
        echo "   ✅ Found: $file"
    fi
done

# Check progress files (less critical, auto-create if missing)
progress_files=("planning/plot-progress.json" "planning/chapter-status.json")
echo "📊 Checking progress files..."
for file in "${progress_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "   ⚠️  Missing: $file (will auto-create)"
        health_score=$((health_score - 5))
    else
        echo "   ✅ Found: $file"
    fi
done

# Check sub-agent files
required_agents=("scene-writer.md" "plot-architect.md" "worldbuilder.md" "character-developer.md" "continuity-editor.md")
echo "🤖 Checking sub-agent files..."
missing_agents=0
for agent in "${required_agents[@]}"; do
    if [ ! -f ".claude/agents/$agent" ]; then
        health_issues+=("Missing sub-agent: $agent")
        health_score=$((health_score - 10))
        missing_agents=$((missing_agents + 1))
        echo "   ❌ Missing: $agent"
    else
        echo "   ✅ Found: $agent"
    fi
done

# Check JSON file validity where files exist
json_files=("planning/plot-progress.json" "planning/chapter-status.json" "worldbuilding/world-state.json" "characters/character-knowledge.json")
echo "🔍 Validating JSON files..."
for json_file in "${json_files[@]}"; do
    if [ -f "$json_file" ]; then
        if command -v python3 >/dev/null 2>&1 && python3 -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "   ✅ Valid JSON: $json_file"
        else
            health_issues+=("Invalid JSON format: $json_file")
            health_score=$((health_score - 10))
            echo "   ❌ Invalid JSON: $json_file"
        fi
    else
        echo "   ⚠️  Missing: $json_file"
    fi
done

# Check progress consistency
echo "📈 Checking progress consistency..."
if [ -f "planning/plot-progress.json" ] && [ -f "planning/chapter-status.json" ]; then
    # Count actual chapter files
    actual_chapters=$(ls manuscript/chapters/chapter-*.md 2>/dev/null | wc -l)
    
    # Try to extract current chapter from progress file
    if command -v python3 >/dev/null 2>&1; then
        current_chapter=$(python3 -c "
import json, sys
try:
    with open('planning/plot-progress.json', 'r') as f:
        data = json.load(f)
    print(data.get('current_chapter', 1))
except:
    print(1)
" 2>/dev/null || echo "1")
    else
        current_chapter=$(grep -o '"current_chapter":[[:space:]]*[0-9]*' planning/plot-progress.json 2>/dev/null | grep -o '[0-9]*$' || echo "1")
    fi
    
    # Simple progress validation
    if [ "$actual_chapters" -eq 0 ] && [ "$current_chapter" -gt 1 ]; then
        health_issues+=("Progress tracking ahead of actual files")
        health_score=$((health_score - 5))
        echo "   ⚠️  Progress tracking inconsistency detected"
    else
        echo "   ✅ Progress tracking appears consistent"
    fi
else
    echo "   ⚠️  Progress files missing - will be created"
fi

# Check disk space (require at least 100MB free)
echo "💾 Checking disk space..."
if command -v df >/dev/null 2>&1; then
    available_space=$(df . 2>/dev/null | tail -1 | awk '{print $4}' || echo "999999")
    if [ "$available_space" -lt 100000 ]; then
        health_issues+=("Low disk space: ${available_space}KB available")
        health_score=$((health_score - 20))
        echo "   ❌ Low disk space: ${available_space}KB"
    else
        echo "   ✅ Adequate disk space: ${available_space}KB"
    fi
else
    echo "   ⚠️  Cannot check disk space"
fi

# Check script dependencies
echo "🔧 Checking script dependencies..."
deps=(wc grep sed awk)
for dep in "${deps[@]}"; do
    if command -v "$dep" >/dev/null 2>&1; then
        echo "   ✅ Available: $dep"
    else
        health_issues+=("Missing dependency: $dep")
        health_score=$((health_score - 15))
        echo "   ❌ Missing: $dep"
    fi
done

# Check Python for dashboard
if command -v python3 >/dev/null 2>&1; then
    echo "   ✅ Python3 available for dashboard"
else
    echo "   ⚠️  Python3 not available - dashboard will not work"
fi

# Generate health report
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
health_file="planning/system-health.json"

# Determine status
if [ $health_score -ge 90 ]; then
    status="healthy"
elif [ $health_score -ge 70 ]; then
    status="warning"
else
    status="critical"
fi

# Create health report
cat > "$health_file" << EOF
{
  "timestamp": "$timestamp",
  "health_score": $health_score,
  "status": "$status",
  "issues_count": ${#health_issues[@]},
  "issues": [$(printf '"%s",' "${health_issues[@]}" | sed 's/,$//')]
}
EOF

# Report results
echo ""
echo "🏥 System Health Report:"
echo "   Health Score: $health_score/100"
case $status in
    "healthy")
        echo "   Status: ✅ Healthy"
        ;;
    "warning")
        echo "   Status: ⚠️  Warning"
        ;;
    "critical")
        echo "   Status: 🚨 Critical"
        ;;
esac

if [ ${#health_issues[@]} -eq 0 ]; then
    echo "✅ All systems operational"
    echo '<system_reminder>✅ SYSTEM HEALTH: All systems operational. Health score: '$health_score'/100. Continue normal operation.</system_reminder>' >> .claude/context-injection.txt 2>/dev/null || true
else
    echo "⚠️  Issues detected:"
    printf '   %s\n' "${health_issues[@]}"
    
    # Auto-repair common issues
    echo ""
    echo "🔧 Attempting auto-repair..."
    
    # Create basic JSON files if missing
    if [ ! -f "planning/plot-progress.json" ]; then
        echo '{"current_chapter": 1, "current_scene": 1, "total_words": 0, "chapter_status": "not_started", "last_action": "auto_repair", "next_milestone": "create_outline", "last_sync_time": "'$timestamp'"}' > planning/plot-progress.json
        echo "   ✅ Created missing plot-progress.json"
    fi
    
    if [ ! -f "planning/chapter-status.json" ]; then
        echo '{"chapter_1": {"status": "not_started", "words": 0}}' > planning/chapter-status.json
        echo "   ✅ Created missing chapter-status.json"
    fi
    
    if [ ! -f "worldbuilding/world-state.json" ]; then
        echo '{"locations_established": [], "magic_rules": [], "cultures": [], "history_timeline": [], "notable_items": []}' > worldbuilding/world-state.json
        echo "   ✅ Created missing world-state.json"
    fi
    
    if [ ! -f "characters/character-knowledge.json" ]; then
        echo '{"protagonist": {"knows": [], "believes": [], "relationships": {}}, "characters_created": []}' > characters/character-knowledge.json
        echo "   ✅ Created missing character-knowledge.json"
    fi
    
    echo '<system_reminder>⚠️  SYSTEM HEALTH: Issues detected and auto-repair attempted. Health score: '$health_score'/100. Use error-recovery agent if problems persist.</system_reminder>' >> .claude/context-injection.txt 2>/dev/null || true
fi

echo "💾 Health report saved to $health_file"

# Return appropriate exit code
if [ $health_score -ge 70 ]; then
    exit 0
else
    exit 1
fi