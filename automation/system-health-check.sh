#!/bin/bash
# automation/system-health-check.sh - System health monitoring

echo "🔍 Running system health check..."

health_issues=()
health_score=100

# Check essential directories
required_dirs=(".claude/agents" "manuscript/chapters" "planning" "worldbuilding" "characters" "automation")
for dir in "${required_dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        health_issues+=("Missing directory: $dir")
        health_score=$((health_score - 10))
    fi
done

# Check essential files
required_files=("CLAUDE.md" ".claude/settings.json" "planning/plot-progress.json" "planning/chapter-status.json")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        health_issues+=("Missing file: $file")
        health_score=$((health_score - 15))
    fi
done

# Check sub-agent files
required_agents=("scene-writer.md" "plot-architect.md" "worldbuilder.md" "character-developer.md" "continuity-editor.md")
for agent in "${required_agents[@]}"; do
    if [ ! -f ".claude/agents/$agent" ]; then
        health_issues+=("Missing sub-agent: $agent")
        health_score=$((health_score - 10))
    fi
done

# Check JSON file validity
json_files=("planning/plot-progress.json" "planning/chapter-status.json" "worldbuilding/world-state.json")
for json_file in "${json_files[@]}"; do
    if [ -f "$json_file" ]; then
        # Simple JSON validation (check for basic structure)
        if ! grep -q '{' "$json_file" || ! grep -q '}' "$json_file"; then
            health_issues+=("Invalid JSON format: $json_file")
            health_score=$((health_score - 10))
        fi
    fi
done

# Check progress consistency
if [ -f "planning/plot-progress.json" ] && [ -f "planning/chapter-status.json" ]; then
    # Count actual chapter files
    actual_chapters=$(ls manuscript/chapters/chapter-*.md 2>/dev/null | wc -l)
    
    # Simple progress validation
    if [ "$actual_chapters" -eq 0 ]; then
        current_chapter=$(grep -o '"current_chapter":[[:space:]]*[0-9]*' planning/plot-progress.json | grep -o '[0-9]*$' || echo "1")
        if [ "$current_chapter" -gt 1 ]; then
            health_issues+=("Progress tracking ahead of actual files")
            health_score=$((health_score - 5))
        fi
    fi
fi

# Check disk space (require at least 100MB free)
available_space=$(df . | tail -1 | awk '{print $4}')
if [ "$available_space" -lt 100000 ]; then
    health_issues+=("Low disk space: ${available_space}KB available")
    health_score=$((health_score - 20))
fi

# Generate health report
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
health_file="planning/system-health.json"

cat > "$health_file" << EOF
{
  "timestamp": "$timestamp",
  "health_score": $health_score,
  "status": "$([ $health_score -ge 90 ] && echo "healthy" || [ $health_score -ge 70 ] && echo "warning" || echo "critical")",
  "issues_count": ${#health_issues[@]},
  "issues": [$(printf '"%s",' "${health_issues[@]}" | sed 's/,$//')]
}
EOF

# Report results
echo "🏥 System Health Report:"
echo "   Health Score: $health_score/100"
echo "   Status: $([ $health_score -ge 90 ] && echo "✅ Healthy" || [ $health_score -ge 70 ] && echo "⚠️  Warning" || echo "🚨 Critical")"

if [ ${#health_issues[@]} -eq 0 ]; then
    echo "✅ All systems operational"
    echo '<system_reminder>✅ SYSTEM HEALTH: All systems operational. Health score: '$health_score'/100. Continue normal operation.</system_reminder>' >> .claude/context-injection.txt
else
    echo "⚠️  Issues detected:"
    printf '   %s\n' "${health_issues[@]}"
    
    # Auto-repair common issues
    echo "🔧 Attempting auto-repair..."
    
    # Recreate missing directories
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "   ✅ Created missing directory: $dir"
        fi
    done
    
    # Create basic JSON files if missing
    if [ ! -f "planning/plot-progress.json" ]; then
        echo '{"current_chapter": 1, "current_scene": 1, "total_words": 0, "chapter_status": "not_started", "last_action": "auto_repair", "next_milestone": "create_outline"}' > planning/plot-progress.json
        echo "   ✅ Created missing plot-progress.json"
    fi
    
    if [ ! -f "planning/chapter-status.json" ]; then
        echo '{"chapter_1": {"status": "not_started", "words": 0}}' > planning/chapter-status.json
        echo "   ✅ Created missing chapter-status.json"
    fi
    
    echo '<system_reminder>⚠️  SYSTEM HEALTH: Issues detected and auto-repair attempted. Health score: '$health_score'/100. Use error-recovery agent if problems persist.</system_reminder>' >> .claude/context-injection.txt
fi

echo "💾 Health report saved to $health_file"