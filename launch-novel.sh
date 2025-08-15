#!/bin/bash
# launch-novel.sh - Start autonomous novel generation

echo "🚀 Initializing Fantasy Novel Writing System v3.0..."

# Initialize project structure (additional directories if needed)
mkdir -p .claude/agents .claude/memory manuscript/chapters planning worldbuilding characters automation

echo "📁 Directory structure created"

# Copy all agent configurations (if they exist in a separate agents directory)
if [ -d "agents" ]; then
    cp agents/*.md .claude/agents/
    echo "🤖 Agent configurations copied"
fi

# Initialize progress tracking
cat > planning/plot-progress.json << 'EOF'
{
  "current_chapter": 1,
  "current_scene": 1,
  "total_words": 0,
  "chapter_status": "not_started",
  "last_action": "initialized",
  "next_milestone": "create_outline"
}
EOF

echo "📊 Progress tracking initialized"

# Initialize chapter status tracking
cat > planning/chapter-status.json << 'EOF'
{
  "chapter_1": {"status": "not_started", "words": 0}
}
EOF

echo "📖 Chapter status tracking initialized"

# Initialize world state tracking
cat > worldbuilding/world-state.json << 'EOF'
{
  "locations_established": [],
  "magic_rules": [],
  "cultures": [],
  "history_timeline": [],
  "notable_items": []
}
EOF

echo "🌍 World state tracking initialized"

# Initialize character knowledge tracking
cat > characters/character-knowledge.json << 'EOF'
{
  "protagonist": {"knows": [], "believes": [], "relationships": {}},
  "characters_created": []
}
EOF

echo "👥 Character tracking initialized"

# Create context injection file
touch .claude/context-injection.txt

echo "💾 All initialization files created"

echo ""
echo "✅ Fantasy Novel Writing System v3.0 ready!"
echo ""
echo "🎯 Next steps:"
echo "1. Run: claude --dangerously-skip-permissions --continue"
echo "2. The system will automatically begin generating your novel"
echo "3. Monitor progress in the planning/ directory"
echo ""
echo "📝 The system will:"
echo "   - Create a complete 30-chapter outline"
echo "   - Generate 3000-5000 word chapters"
echo "   - Maintain character and world consistency"
echo "   - Self-manage the entire writing process"
echo ""
echo "🚨 IMPORTANT: The system runs autonomously. It will write continuously"
echo "   without human intervention until the novel is complete."
echo ""

# Optional: Start monitoring dashboard if it exists
if [ -f "automation/dashboard.py" ]; then
    echo "📊 Starting monitoring dashboard..."
    python3 automation/dashboard.py &
    echo "   Dashboard running in background"
fi

echo "Ready to launch autonomous novel generation!"
echo "Run the Claude command above to begin."
