# Fantasy Novel Writing System v3.0 - User Guide

## 🚀 Getting Started

### System Requirements
- Claude Code or compatible AI agent platform
- Terminal/command line access
- Python 3.6+ (for monitoring dashboard)
- Sufficient storage space (recommended: 500MB minimum)

### Quick Start (30 Seconds)

1. **Clone the Repository**
   ```bash
   git clone https://github.com/forsonny/Claude-Code-Novel-Writer.git
   cd Claude-Code-Novel-Writer
   ```

2. **Start Novel Generation**
   ```bash
   claude --dangerously-skip-permissions --continue
   ```

3. **Monitor Progress** (Optional)
   ```bash
   python3 automation/dashboard.py --monitor
   ```

That's it! The system will now autonomously generate a complete 100,000-word fantasy novel.

## 📋 Detailed Setup Guide

### Step 1: Repository Clone

Clone the complete system with all configurations ready:

```bash
git clone https://github.com/forsonny/Claude-Code-Novel-Writer.git
cd Claude-Code-Novel-Writer
```

### Step 2: System Verification

After cloning, verify the project structure is complete:

```
Claude-Code-Novel-Writer/
├── CLAUDE.md                     # ✅ Master orchestrator
├── .claude/agents/               # ✅ All 5 sub-agents
├── planning/                     # ✅ Progress tracking
├── manuscript/chapters/          # ✅ Output directory
├── worldbuilding/               # ✅ World state
├── characters/                  # ✅ Character tracking
├── automation/                  # ✅ Monitoring tools
└── Documentation/               # ✅ This guide
```

### Step 3: Novel Generation Launch

Start the autonomous generation process:

```bash
claude --dangerously-skip-permissions --continue
```

**Important Notes:**
- The `--dangerously-skip-permissions` flag is required for autonomous operation
- The system will run continuously until the novel is complete
- No human intervention is needed or expected

## 📊 Monitoring Your Novel

### Real-Time Dashboard

Launch the monitoring dashboard to track progress:

```bash
# One-time status check
python3 automation/dashboard.py

# Continuous monitoring (refreshes every 30 seconds)
python3 automation/dashboard.py --monitor

# Custom refresh interval
python3 automation/dashboard.py --monitor --interval 60
```

### Dashboard Features

The monitoring dashboard displays:
- **Progress Overview**: Word count, completion percentage, target progress
- **Chapter Status**: Individual chapter completion states
- **Current Activity**: What the system is currently working on
- **File System Status**: Verification of all system components
- **Timeline**: Progress over time

### Manual Progress Checking

You can also check progress manually by examining key files:

```bash
# Current progress
cat planning/plot-progress.json

# Chapter status
cat planning/chapter-status.json

# Word count in manuscript
find manuscript/chapters -name "*.md" -exec wc -w {} + | tail -n 1
```

## 🎯 Understanding System Behavior

### The Autonomous Generation Process

The system operates in a continuous loop:

1. **Assessment Phase**
   - Reads current progress from `/planning/plot-progress.json`
   - Analyzes chapter status and word counts
   - Evaluates story pacing and structure needs

2. **Decision Phase**
   - Applies decision tree logic to determine next action
   - Prioritizes tasks based on story development needs
   - Selects appropriate sub-agent for the work

3. **Execution Phase**
   - Delegates specific tasks to specialized sub-agents
   - Provides complete, self-contained instructions
   - Receives detailed outputs and summaries

4. **Integration Phase**
   - Saves generated content to appropriate files
   - Updates progress tracking and state files
   - Maintains consistency across all elements

5. **Validation Phase**
   - Checks for errors or inconsistencies
   - Applies quality standards verification
   - Prepares for next iteration

### What to Expect

#### Phase 1: Initial Setup (Chapters 1-3)
- Complete novel outline creation
- Main character development
- World-building foundation
- Magic system establishment
- Opening scenes generation

#### Phase 2: Story Development (Chapters 4-15)
- Character relationship building
- World expansion and exploration
- Subplot introduction and development
- Conflict escalation
- Plot complication introduction

#### Phase 3: Plot Acceleration (Chapters 16-25)
- Major plot revelations
- Character growth acceleration
- Conflict intensification
- Subplot convergence
- Climax preparation

#### Phase 4: Resolution (Chapters 26-30)
- Climactic confrontations
- Character arc completion
- Subplot resolution
- World state resolution
- Satisfying conclusion

## 🛠️ System Configuration

### Modifying Generation Parameters

You can customize the novel generation by editing configuration files:

#### Target Length Adjustment
Edit `planning/plot-progress.json`:
```json
{
  "target_words": 80000,  // Modify for shorter/longer novel
  "current_chapter": 1,
  // ... other settings
}
```

#### Quality Standards
Edit the sub-agent configuration files in `.claude/agents/`:
- **Chapter length**: Modify word count targets in agent instructions
- **Dialogue ratio**: Adjust dialogue requirements in scene-writer.md
- **Pacing**: Modify tension and rhythm requirements in plot-architect.md

#### Genre Customization
While optimized for fantasy, you can adapt the system:
- Modify worldbuilder.md for different settings (sci-fi, historical, etc.)
- Adjust character-developer.md for genre-appropriate archetypes
- Update scene-writer.md for genre-specific elements

### Advanced Configuration

#### Hook Customization
Edit `.claude/settings.json` to modify system behavior:
- Change reminder frequency
- Modify restart behavior
- Adjust context injection patterns

#### Agent Specialization
Create custom sub-agents by:
1. Copying an existing agent configuration
2. Modifying capabilities and instructions
3. Adding to `.claude/agents/` directory
4. Updating master orchestrator references

## 🔧 Troubleshooting

### Common Issues and Solutions

#### System Doesn't Start
**Symptoms**: No generation begins after launch command
**Solutions**:
- Verify `CLAUDE.md` exists and is properly formatted
- Check that all sub-agent files are in `.claude/agents/`
- Ensure repository clone completed successfully
- Try restarting Claude Code entirely

#### Generation Stops Unexpectedly
**Symptoms**: System stops generating content mid-novel
**Solutions**:
- System includes auto-restart hooks, should resume automatically
- Manual restart: `claude --continue --dangerously-skip-permissions`
- Check `.claude/context-injection.txt` for system reminders
- Verify no file system issues or permission problems

#### Inconsistency Issues
**Symptoms**: Character or world contradictions in the text
**Solutions**:
- Continuity editor runs automatically every 3 chapters
- Manual consistency check: Review `/planning/` files
- Force continuity review by deleting last few chapters and regenerating
- Check world-state.json and character-knowledge.json for accuracy

#### Low Quality Output
**Symptoms**: Generated content doesn't meet expectations
**Solutions**:
- Review quality standards in sub-agent configurations
- Ensure word count targets are appropriate
- Check that progress tracking is accurate
- Consider modifying agent instructions for higher standards

#### Performance Issues
**Symptoms**: Very slow generation or high resource usage
**Solutions**:
- Reduce monitoring frequency
- Close unnecessary applications
- Ensure adequate system resources
- Consider reducing simultaneous background processes

### File System Issues

#### Missing Files
If critical files are missing:
```bash
# Verify complete clone
git status

# Re-clone if necessary
cd ..
rm -rf Claude-Code-Novel-Writer
git clone https://github.com/forsonny/Claude-Code-Novel-Writer.git
cd Claude-Code-Novel-Writer
```

#### Corrupted Progress Files
If progress tracking appears corrupted:
```bash
# Reset progress files to initial state
git checkout -- planning/plot-progress.json planning/chapter-status.json

# Or manually edit JSON files in planning/ directory
```

#### Permission Problems
If you encounter permission errors:
```bash
# Make scripts executable
chmod +x automation/dashboard.py

# Check directory permissions
ls -la .claude/
```

### Advanced Troubleshooting

#### Debug Mode
Enable detailed logging by adding debug flags:
```bash
claude --continue --dangerously-skip-permissions --verbose
```

#### Manual State Inspection
Examine system state manually:
```bash
# Check current progress
cat planning/plot-progress.json | python3 -m json.tool

# Review chapter status
cat planning/chapter-status.json | python3 -m json.tool

# Examine world state
cat worldbuilding/world-state.json | python3 -m json.tool
```

#### Recovery Procedures
If the system becomes unstable:
1. Stop the current session
2. Back up any generated content
3. Reset to clean state: `git checkout -- planning/`
4. Restart generation

## 📈 Optimization Tips

### Maximizing Quality

1. **Let the System Run**: Avoid interrupting the generation process
2. **Monitor Regularly**: Use the dashboard to track progress and quality
3. **Trust the Process**: The system self-corrects and improves over time
4. **Review Settings**: Adjust quality standards if needed

### Performance Optimization

1. **Dedicated Environment**: Run on a dedicated system if possible
2. **Minimal Background**: Close unnecessary applications
3. **Adequate Storage**: Ensure sufficient disk space
4. **Stable Connection**: Maintain reliable internet for AI access

### Customization Best Practices

1. **Gradual Changes**: Make small configuration adjustments
2. **Test Settings**: Verify changes with short test runs
3. **Backup Configs**: Save working configurations before changes
4. **Document Changes**: Keep notes on modifications

## 🎯 Success Metrics

### Quality Indicators

Monitor these metrics for optimal results:
- **Word Count Progress**: Steady advancement toward 100,000 words
- **Chapter Completion**: Regular chapter finishing (every 1-2 hours)
- **Consistency Score**: Minimal continuity errors
- **Quality Standards**: Meeting all automated quality checks

### Performance Benchmarks

Typical performance expectations:
- **Generation Speed**: 3,000-5,000 words per hour
- **Chapter Completion**: 1 chapter per 1-2 hours
- **Error Rate**: <1% requiring manual intervention
- **Completion Time**: 20-40 hours for full novel

## 📚 Additional Resources

### System Files Reference
- **CLAUDE.md**: Master orchestrator configuration and instructions
- **.claude/agents/**: Complete sub-agent specifications
- **planning/**: Progress tracking and status files
- **Documentation/**: Comprehensive system documentation

### Support and Community
- Review system architecture documentation for deep understanding
- Examine agent configurations for customization guidance
- Monitor dashboard for real-time insights
- Check progress files for detailed status information

### File Structure Reference
```
Claude-Code-Novel-Writer/
├── CLAUDE.md                     # Master orchestrator configuration
├── README.md                     # Project overview and quick start
├── .claude/
│   ├── agents/                   # Sub-agent configurations
│   │   ├── scene-writer.md       # Prose generation specialist
│   │   ├── plot-architect.md     # Story structure designer
│   │   ├── worldbuilder.md       # Fantasy world creator
│   │   ├── character-developer.md # Character creation expert
│   │   └── continuity-editor.md  # Consistency maintenance
│   ├── settings.json            # Automated hooks configuration
│   └── context-injection.txt    # Dynamic system reminders
├── manuscript/
│   ├── chapters/                # Generated novel chapters
│   └── metadata.json           # Novel metadata
├── planning/                    # Progress tracking files
│   ├── plot-progress.json       # Current story position
│   ├── chapter-status.json      # Chapter completion tracking
│   ├── novel-outline.json       # Story structure
│   ├── scene-tracker.json       # Scene type management
│   └── style-guide.json         # Writing style requirements
├── worldbuilding/              # Fantasy world elements
│   └── world-state.json        # World consistency tracking
├── characters/                 # Character development
│   └── character-knowledge.json # Character state tracking
├── automation/                 # Monitoring and utilities
│   ├── dashboard.py            # Real-time progress monitoring
│   └── backup.sh              # Manual backup utility
├── templates/                  # Reference templates
│   ├── chapter-template.md     # Chapter structure guide
│   └── character-sheet.md      # Character development template
└── Documentation/              # Complete system documentation
    ├── README.md               # System overview
    ├── User-Guide.md           # This guide
    └── System-Architecture.md  # Technical documentation
```

---

**The Fantasy Novel Writing System v3.0 is designed for autonomous operation. Clone the repository, start generation, and enjoy watching your novel come to life automatically.**