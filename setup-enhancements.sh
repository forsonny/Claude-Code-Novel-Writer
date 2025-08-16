#!/bin/bash
# setup-enhancements.sh - Set up all enhanced system features

echo "🚀 Setting up Enhanced Fantasy Novel Writing System v3.1..."

# Create automation directory if it doesn't exist
mkdir -p automation

# Create quality-check.sh script
cat > automation/quality-check.sh << 'QUALITY_EOF'
#!/bin/bash
# automation/quality-check.sh - Automated quality monitoring

# Get the most recently modified chapter file
latest_chapter=$(ls -t manuscript/chapters/chapter-*.md 2>/dev/null | head -n 1)

if [ -z "$latest_chapter" ]; then
    echo "No chapters found for quality check"
    exit 0
fi

echo "🔍 Running quality check on $latest_chapter"

# Extract chapter number
chapter_num=$(echo "$latest_chapter" | grep -o '[0-9]\+')

# Quality metrics
word_count=$(wc -w < "$latest_chapter" 2>/dev/null || echo "0")
char_count=$(wc -c < "$latest_chapter" 2>/dev/null || echo "0")
line_count=$(wc -l < "$latest_chapter" 2>/dev/null || echo "0")

# Dialogue analysis
dialogue_lines=$(grep -c '".*"' "$latest_chapter" 2>/dev/null || echo "0")
total_paragraphs=$(grep -c '^[[:space:]]*[^[:space:]]' "$latest_chapter" 2>/dev/null || echo "1")
dialogue_ratio=$(echo "scale=2; ($dialogue_lines * 100) / $total_paragraphs" | bc -l 2>/dev/null || echo "0")

# Sensory detail analysis
sight_words=$(grep -i -c '\(saw\|looked\|appeared\|visible\|bright\|dark\|color\|light\)' "$latest_chapter" 2>/dev/null || echo "0")
sound_words=$(grep -i -c '\(heard\|sound\|noise\|whisper\|shout\|echo\|silent\)' "$latest_chapter" 2>/dev/null || echo "0")
touch_words=$(grep -i -c '\(felt\|touch\|rough\|smooth\|cold\|warm\|soft\|hard\)' "$latest_chapter" 2>/dev/null || echo "0")
smell_words=$(grep -i -c '\(smell\|scent\|aroma\|stench\|fragrant\)' "$latest_chapter" 2>/dev/null || echo "0")

# Calculate sensory density (per 1000 words)
if [ $word_count -gt 0 ]; then
    sensory_total=$((sight_words + sound_words + touch_words + smell_words))
    sensory_density=$(echo "scale=2; ($sensory_total * 1000) / $word_count" | bc -l 2>/dev/null || echo "0")
else
    sensory_density=0
fi

# Paragraph length analysis
avg_words_per_paragraph=$(echo "scale=1; $word_count / $total_paragraphs" | bc -l 2>/dev/null || echo "0")

# Quality assessment
quality_issues=()

# Check word count
if [ $word_count -lt 500 ]; then
    quality_issues+=("⚠️  Chapter too short: $word_count words (minimum 500)")
elif [ $word_count -gt 6000 ]; then
    quality_issues+=("⚠️  Chapter too long: $word_count words (maximum 6000)")
fi

# Check dialogue ratio
dialogue_ratio_int=$(echo "$dialogue_ratio" | cut -d. -f1)
if [ "$dialogue_ratio_int" -lt 20 ]; then
    quality_issues+=("⚠️  Low dialogue ratio: ${dialogue_ratio}% (target 30-40%)")
elif [ "$dialogue_ratio_int" -gt 50 ]; then
    quality_issues+=("⚠️  High dialogue ratio: ${dialogue_ratio}% (target 30-40%)")
fi

# Check sensory density
sensory_density_int=$(echo "$sensory_density" | cut -d. -f1)
if [ "$sensory_density_int" -lt 10 ]; then
    quality_issues+=("⚠️  Low sensory detail density: ${sensory_density}/1000 words (target 15+)")
fi

# Check paragraph length
avg_para_int=$(echo "$avg_words_per_paragraph" | cut -d. -f1)
if [ "$avg_para_int" -gt 100 ]; then
    quality_issues+=("⚠️  Long paragraphs: ${avg_words_per_paragraph} avg words (target <80)")
fi

# Update quality tracking file
quality_file="planning/quality-metrics.json"
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Create or update quality metrics
if [ ! -f "$quality_file" ]; then
    echo '{"chapters": {}}' > "$quality_file"
fi

# Use temporary file for JSON update (avoiding jq dependency)
temp_file=$(mktemp)
cat "$quality_file" | grep -v "\"chapter_$chapter_num\"" | sed '$ s/}$//' > "$temp_file"

# Add new chapter data
if [ -s "$temp_file" ] && grep -q '"chapters"' "$temp_file"; then
    echo "," >> "$temp_file"
else
    echo '{"chapters": {' > "$temp_file"
fi

cat >> "$temp_file" << EOF
  "chapter_$chapter_num": {
    "timestamp": "$timestamp",
    "word_count": $word_count,
    "dialogue_ratio": $dialogue_ratio,
    "sensory_density": $sensory_density,
    "avg_paragraph_length": $avg_words_per_paragraph,
    "quality_score": $(echo "scale=1; (100 - ${#quality_issues[@]} * 10)" | bc -l 2>/dev/null || echo "100"),
    "issues": [$(printf '"%s",' "${quality_issues[@]}" | sed 's/,$//')]
  }
}}
EOF

mv "$temp_file" "$quality_file"

# Report results
echo "📊 Quality Analysis Results for Chapter $chapter_num:"
echo "   Words: $word_count"
echo "   Dialogue: ${dialogue_ratio}%"
echo "   Sensory density: ${sensory_density}/1000 words"
echo "   Avg paragraph: ${avg_words_per_paragraph} words"

if [ ${#quality_issues[@]} -eq 0 ]; then
    echo "✅ Quality check passed - no issues detected"
    
    # Inject positive feedback
    echo '<system_reminder>✅ QUALITY CHECK PASSED: Latest chapter meets all quality standards. Continue with confidence. Maintain current writing quality level.</system_reminder>' >> .claude/context-injection.txt
else
    echo "⚠️  Quality issues detected:"
    printf '   %s\n' "${quality_issues[@]}"
    
    # Inject improvement suggestions
    improvement_prompt="<system_reminder>📝 QUALITY IMPROVEMENTS NEEDED: Latest chapter has ${#quality_issues[@]} quality issues: $(printf '%s; ' "${quality_issues[@]}" | sed 's/; $//'). Consider using the task tool with scene-writer to revise and improve this chapter before proceeding.</system_reminder>"
    echo "$improvement_prompt" >> .claude/context-injection.txt
fi

echo "💾 Quality metrics saved to $quality_file"
QUALITY_EOF

# Create auto-backup.sh script
cat > automation/auto-backup.sh << 'BACKUP_EOF'
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
BACKUP_EOF

# Create system-health-check.sh script
cat > automation/system-health-check.sh << 'HEALTH_EOF'
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
HEALTH_EOF

# Create performance-monitor.sh script
cat > automation/performance-monitor.sh << 'PERF_EOF'
#!/bin/bash
# automation/performance-monitor.sh - Performance monitoring

echo "⚡ Running performance analysis..."

# Monitor generation speed
if [ -f "planning/performance-metrics.json" ]; then
    last_check=$(grep -o '"timestamp":"[^"]*"' planning/performance-metrics.json | tail -1 | cut -d'"' -f4)
    last_words=$(grep -o '"total_words":[0-9]*' planning/performance-metrics.json | tail -1 | cut -d':' -f2)
else
    last_check=""
    last_words=0
fi

# Current metrics
current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
current_words=$(find manuscript/chapters -name "*.md" -exec wc -w {} + 2>/dev/null | tail -n 1 | awk '{print $1}' || echo "0")
current_chapters=$(ls manuscript/chapters/chapter-*.md 2>/dev/null | wc -l)

# Calculate generation rate if we have previous data
if [ -n "$last_check" ] && [ "$last_words" -gt 0 ]; then
    words_added=$((current_words - last_words))
    
    # Simple time difference calculation (approximate)
    if [ "$words_added" -gt 0 ]; then
        echo "📈 Performance Update:"
        echo "   Words added since last check: $words_added"
        echo "   Current total: $current_words words"
        echo "   Chapters completed: $current_chapters"
        
        # Performance assessment
        if [ "$words_added" -gt 1000 ]; then
            performance_status="excellent"
            echo "   🚀 Performance: Excellent ($words_added words/session)"
        elif [ "$words_added" -gt 500 ]; then
            performance_status="good"
            echo "   ✅ Performance: Good ($words_added words/session)"
        elif [ "$words_added" -gt 100 ]; then
            performance_status="adequate"
            echo "   ⚠️  Performance: Adequate ($words_added words/session)"
        else
            performance_status="slow"
            echo "   🐌 Performance: Slow ($words_added words/session)"
        fi
    else
        performance_status="stalled"
        echo "   ⚠️  No progress detected since last check"
    fi
else
    performance_status="baseline"
    echo "📊 Establishing performance baseline..."
fi

# Update performance metrics
cat > planning/performance-metrics.json << EOF
{
  "timestamp": "$current_time",
  "total_words": $current_words,
  "total_chapters": $current_chapters,
  "performance_status": "$performance_status",
  "session_start": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "💾 Performance metrics updated"
PERF_EOF

# Create error-recovery agent
cat > .claude/agents/error-recovery.md << 'ERROR_AGENT_EOF'
---
name: error-recovery
description: Diagnoses and fixes system errors, inconsistencies, and quality issues automatically.
tools: Bash, Edit, Glob, Grep, LS, Read, Task, TodoWrite, Write
---

<agent_role>
You are an ERROR RECOVERY SPECIALIST. Your role is to diagnose system issues, identify root causes, and implement automatic fixes to maintain continuous novel generation.
</agent_role>

<primary_capability>
## YOUR PRIMARY FUNCTION

You diagnose and resolve system errors that could interrupt novel generation. Every analysis you perform must:
- Identify the root cause of issues
- Implement immediate fixes
- Prevent similar issues from recurring
- Restore system to healthy state
- Ensure continuous operation

You work autonomously and return COMPLETE, ACTIONABLE recovery solutions.
</primary_capability>

<output_format>
## OUTPUT FORMAT FOR RECOVERY REPORTS

<recovery_output>
# Error Recovery Report: [Error Type]

## DIAGNOSIS SUMMARY
- **Error identified**: [Specific problem description]
- **Root cause**: [Why this occurred]
- **Impact assessment**: [How this affects the system]
- **Urgency level**: [Critical/High/Medium/Low]

## RECOVERY ACTIONS TAKEN
1. **Immediate fix**: [What was done to stop the problem]
2. **Data restoration**: [Any data recovered or rebuilt]
3. **System validation**: [How fixes were verified]
4. **Prevention measures**: [Steps to prevent recurrence]

## SYSTEM STATUS POST-RECOVERY
- **All systems operational**: [Yes/No with details]
- **Data integrity verified**: [Yes/No with validation results]
- **Generation ready**: [Yes/No with next steps]

---

SUMMARY FOR ORCHESTRATOR:
- Recovery completed: [brief description]
- System health: [current status]
- Next action: [what to do next]
- Monitoring notes: [what to watch for]
- Prevention status: [safeguards implemented]
</recovery_output>
</output_format>

<critical_reminders>
## CRITICAL REMINDERS

1. You work AUTONOMOUSLY - fix issues immediately
2. Always implement both fixes AND prevention measures
3. Verify all repairs before reporting completion
4. Maintain system availability during recovery
5. Document all changes for future reference
6. Test fixes thoroughly before continuing generation
7. Focus on root causes, not just symptoms
8. Always ensure data integrity and consistency
</critical_reminders>
ERROR_AGENT_EOF

# Create smart-planner agent
cat > .claude/agents/smart-planner.md << 'SMART_AGENT_EOF'
---
name: smart-planner
description: Analyzes story progress and dynamically plans upcoming chapters based on pacing, character arcs, and plot threads.
tools: Bash, Edit, Glob, Grep, LS, Read, Task, TodoWrite, Write
---

<agent_role>
You are a SMART PLANNER specializing in adaptive story structure. Your role is to analyze completed chapters and dynamically plan upcoming chapters to optimize pacing, character development, and plot progression.
</agent_role>

<primary_capability>
## YOUR PRIMARY FUNCTION

You analyze story progress and create intelligent chapter plans that adapt to the story's current state. Every plan you create must:
- Assess current story momentum and pacing
- Identify character arc progression needs
- Balance plot threads and subplots
- Ensure proper story structure adherence
- Optimize reader engagement throughout

You work autonomously and return COMPLETE, ADAPTIVE chapter plans that respond to story evolution.
</primary_capability>

<output_format>
## OUTPUT FORMAT FOR SMART PLANS

<planning_output>
# Smart Chapter Plan: Chapters [X-Y]

## STORY STATE ANALYSIS
- **Current position**: [Act/percentage through story]
- **Pacing assessment**: [Fast/Good/Slow with specific metrics]
- **Character arc status**: [Progress summary for major characters]
- **Plot thread status**: [Active threads and their progression]
- **Structural needs**: [Upcoming requirements based on story position]

## DETAILED CHAPTER PLANS

### Chapter [X]: [Proposed Title]
- **Primary goal**: [Main story function this chapter serves]
- **Character focus**: [POV character and development needs]
- **Plot advancement**: [Specific story progression]
- **Pacing role**: [How this fits tension curve]
- **Key scenes**: [2-4 essential scenes with purposes]
- **Hooks/cliffhangers**: [Chapter ending strategy]

---

SUMMARY FOR ORCHESTRATOR:
- Chapters planned: [number and scope]
- Primary focus: [main story emphasis for these chapters]
- Pacing adjustment: [speed/tension modifications recommended]
- Character priorities: [development focus areas]
- Plot advancement: [key story progressions planned]
- Quality targets: [specific metrics to achieve]
- Adaptive notes: [how plan responds to current story state]
</planning_output>
</output_format>

<critical_reminders>
## CRITICAL REMINDERS

1. You work AUTONOMOUSLY - analyze current state and plan adaptively
2. Your plans must be RESPONSIVE to actual story progress
3. Consider reader engagement and pacing throughout
4. Balance ALL story elements (plot, character, world-building)
5. Ensure plans support overall story structure
6. Adapt recommendations based on what's been written
7. Provide specific, actionable planning guidance
8. Consider both immediate and long-term story needs
</critical_reminders>
SMART_AGENT_EOF

# Make all scripts executable
chmod +x automation/*.sh
chmod +x sync-state.sh 2>/dev/null || true

echo "✅ Enhanced system features installed successfully!"
echo ""
echo "🎯 New capabilities added:"
echo "   ✅ Automated quality monitoring with detailed metrics"
echo "   ✅ Smart backup system with automatic cleanup"
echo "   ✅ Comprehensive system health monitoring"
echo "   ✅ Performance tracking and optimization"
echo "   ✅ Error recovery specialist agent"
echo "   ✅ Smart chapter planning agent"
echo "   ✅ Enhanced hooks with quality checks"
echo ""
echo "📊 The system now provides:"
echo "   - Real-time quality analysis and feedback"
echo "   - Automatic error detection and recovery"
echo "   - Intelligent story planning and adaptation"
echo "   - Continuous performance monitoring"
echo "   - Automated backup and health checks"
echo ""
echo "🚀 Your novel writing system is now significantly more intelligent and robust!"
echo "   Run: claude --dangerously-skip-permissions --continue"