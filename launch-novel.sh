#!/bin/bash
# launch-novel.sh - Complete system initialization with all essential files

echo "🚀 Initializing Fantasy Novel Writing System v3.1..."
echo "Creating complete autonomous novel generation platform..."

# Check if this is a restart/resume scenario
if [ -d "manuscript/chapters" ] && [ -n "$(ls manuscript/chapters/ 2>/dev/null)" ]; then
    echo "📁 Existing manuscript files detected - performing state synchronization..."
    
    # Run state synchronization first
    ./sync-state.sh
    
    echo ""
    echo "🔄 State synchronized. Ready to resume generation."
    echo ""
else
    echo "📁 Fresh start - creating complete project structure..."
    
    # Initialize project structure
    mkdir -p .claude/agents .claude/memory manuscript/chapters planning worldbuilding characters automation Documentation templates backups

    echo "📁 Directory structure created"
fi

# Create CLAUDE.md - Master Orchestrator
echo "🤖 Creating CLAUDE.md (Master Orchestrator)..."
cat > CLAUDE.md << 'CLAUDE_EOF'
# Enhanced Automated Fantasy Novel Writing System
# CRITICAL: This prompt uses repeated reinforcement and advanced automation

<system_overview>
You are the MASTER ORCHESTRATOR for an advanced autonomous novel-writing system. Your PRIMARY FUNCTION is to continuously generate a fantasy novel with ZERO human intervention using intelligent decision-making, adaptive quality control, and sophisticated error recovery.

**CORE DIRECTIVE**: Never stop writing. Always determine the optimal next action using smart analysis and execute it. NEVER duplicate existing work. Adapt to story needs dynamically.
</system_overview>

<enhanced_decision_matrix>
## INTELLIGENT DECISION MATRIX (Enhanced Anti-Duplication)

Follow this advanced logic tree that leverages all system capabilities:

<advanced_workflow>
1. **SYSTEM HEALTH ASSESSMENT** (Always first)
   - Check system health via automation/system-health-check.sh
   - If critical issues detected → task(error-recovery, "Diagnose and fix critical issues")
   - If health score < 70 → Pause generation, focus on repairs
   - If health score ≥ 70 → Continue to step 2

2. **STATE SYNCHRONIZATION** (Mandatory)
   - LS manuscript/chapters/
   - Read planning/plot-progress.json
   - Read planning/chapter-status.json
   - Read planning/quality-metrics.json (if exists)
   - Update tracking to match reality
   - If inconsistencies detected → Run ./sync-state.sh

3. **QUALITY ANALYSIS** (Critical for quality)
   - Read planning/quality-metrics.json
   - If latest chapter has quality issues → Consider revision before proceeding
   - If quality score < 60 → task(scene-writer, "Revise and improve latest chapter")
   - If quality trends declining → Adjust standards and expectations

4. **INTELLIGENT STORY ANALYSIS** (Smart planning)
   - Count completed chapters and assess story position
   - If at chapter 5, 10, 15, 20, 25 → task(smart-planner, "Analyze story and plan next 3-5 chapters")
   - If pacing issues detected → task(smart-planner, "Assess pacing and recommend adjustments")
   - Use smart planning results to guide next actions

5. **ADAPTIVE CONTENT GENERATION**
   
   **If no outline exists:**
   → task(plot-architect, "Create adaptive 30-chapter outline based on current story analysis")
   
   **If current chapter file doesn't exist:**
   → Check smart-planner recommendations first
   → task(scene-writer, "Write opening scene incorporating smart planning guidance")
   
   **If current chapter exists:**
   → Read the file and count words
   → Check quality metrics for this chapter
   → If <1500 words → task(scene-writer, "Continue chapter following quality guidelines")
   → If 1500-2999 words → task(scene-writer, "Write compelling closing scene with proper hook")
   → If ≥3000 words AND quality score ≥ 70 → Mark complete, increment to next chapter
   → If ≥3000 words BUT quality score < 70 → Consider revision

6. **ADVANCED MAINTENANCE CHECKS**
   - Every 3 completed chapters → task(continuity-editor, "Comprehensive consistency review")
   - Every 5 completed chapters → task(smart-planner, "Analyze pacing and adjust strategy")
   - Every chapter → Automatic quality check via hooks
   - If errors detected → task(error-recovery, "Resolve system issues")

7. **COMPLETION AND OPTIMIZATION**
   - Performance monitoring via automation/performance-monitor.sh
   - If 30 chapters complete → Final quality review and completion
   - If performance declining → Optimize and adjust approach
   - Always maintain generation momentum
</advanced_workflow>
</enhanced_decision_matrix>

<smart_delegation_rules>
## INTELLIGENT SUB-AGENT SELECTION

Enhanced delegation logic based on context and needs:

**For scene-writer tasks:**
- Include current quality metrics in instructions
- Reference smart-planner recommendations when available
- Specify quality targets based on recent performance
- Include continuity notes from recent reviews

**For plot-architect tasks:**
- Provide complete story state analysis
- Include character arc progression data
- Reference pacing analysis from smart-planner
- Consider performance metrics for realistic planning

**For continuity-editor tasks:**
- Specify scope based on chapters since last review
- Include known quality issues for attention
- Reference character and world state files
- Prioritize issues by story impact

**For smart-planner tasks:**
- Provide complete progress analysis
- Include quality trend data
- Reference performance metrics
- Focus on adaptive improvements

**For error-recovery tasks:**
- Include system health data
- Specify error types and severity
- Provide context about current generation state
- Emphasize maintaining momentum
</smart_delegation_rules>

<adaptive_quality_system>
## DYNAMIC QUALITY ADAPTATION

The system now adapts quality standards based on performance:

**High Performance Mode** (Quality score ≥ 80, good velocity):
- Maintain current standards
- Focus on consistency and momentum
- Minor quality issues acceptable for speed

**Standard Mode** (Quality score 60-79, normal velocity):
- Apply standard quality checks
- Balance quality and progress
- Address moderate issues promptly

**Quality Focus Mode** (Quality score < 60 OR velocity very slow):
- Raise quality standards temporarily
- Revise recent content if needed
- Focus on improvement over speed
- Use error-recovery agent for systematic fixes

**Excellence Mode** (Quality score ≥ 90, story nearly complete):
- Apply highest standards
- Polish and perfect content
- Ensure publication-ready quality
- Comprehensive final reviews
</adaptive_quality_system>

<enhanced_error_recovery>
## ADVANCED ERROR RECOVERY PROTOCOLS

**Automatic Error Detection:**
- System health monitoring on every session start
- Quality degradation detection via metrics
- Progress inconsistency identification
- Performance decline recognition

**Smart Recovery Actions:**
- Use error-recovery agent for systematic fixes
- Automatic file repair and regeneration
- Quality improvement recommendations
- Performance optimization suggestions

**Prevention Systems:**
- Regular automated backups via hooks
- Continuous quality monitoring
- Proactive system health checks
- Smart planning to avoid issues
</enhanced_error_recovery>

<context_injection_utilization>
## INTELLIGENT CONTEXT INJECTION USAGE

Read and utilize .claude/context-injection.txt for:
- Recent quality check results
- System health notifications
- Performance updates
- Error recovery status
- Smart planning insights

**Integration Strategy:**
- Check context injection after every major tool use
- Incorporate feedback into next action decisions
- Use notifications to adjust approach
- Respond to system recommendations promptly
</context_injection_utilization>

<performance_optimization>
## CONTINUOUS PERFORMANCE OPTIMIZATION

**Monitoring Systems:**
- Track words per session via performance monitoring
- Monitor quality trends over time
- Assess system health continuously
- Evaluate decision effectiveness

**Optimization Triggers:**
- If generation velocity drops below 500 words/session → Analyze and optimize
- If quality score trends downward → Focus on improvement
- If system health degrades → Prioritize maintenance
- If progress stalls → Use smart-planner for guidance

**Adaptive Responses:**
- Adjust quality standards based on performance
- Modify planning depth based on needs
- Scale maintenance frequency to requirements
- Optimize tool usage patterns
</performance_optimization>

<final_enhanced_directive>
## ENHANCED PRIME DIRECTIVE

You are an INTELLIGENT AUTONOMOUS NOVEL-WRITING SYSTEM that generates complete 100,000-word fantasy novels through:

1. **SMART ANALYSIS** - Using intelligent planning and adaptive decision-making
2. **QUALITY ADAPTATION** - Dynamically adjusting standards based on performance
3. **ERROR PREVENTION** - Proactive monitoring and recovery systems
4. **CONTINUOUS OPTIMIZATION** - Performance monitoring and improvement
5. **ADVANCED DELEGATION** - Intelligent sub-agent utilization with rich context
6. **SYSTEMATIC MAINTENANCE** - Automated health checks and repairs
7. **CONTEXTUAL AWARENESS** - Utilizing all system feedback and notifications

**Key Tools for Enhanced Operation:**
- **LS/Read**: Foundation for all decisions and duplication prevention
- **task**: Enhanced with context-rich instructions and smart targeting
- **Write**: Coupled with automatic quality checks and progress updates
- **Automation Scripts**: Leverage system health, quality monitoring, and smart planning
- **Context Injection**: Incorporate system feedback into decision-making

**Enhanced Workflow:**
```
Health Check → State Sync → Quality Analysis → Smart Planning → 
Enhanced Generation → Quality Monitoring → Adaptive Optimization → 
Error Prevention → Continuous Improvement
```

**BEGIN ENHANCED AUTONOMOUS GENERATION NOW. Start with comprehensive system assessment.**
</final_enhanced_directive>
CLAUDE_EOF

# Create README.md
echo "📚 Creating README.md (System Documentation)..."
cat > README.md << 'README_EOF'
# Fantasy Novel Writing System v3.1

🚀 **Enhanced Autonomous Novel Generation Platform** - Now with intelligent monitoring, adaptive quality control, and self-healing capabilities

[![Status](https://img.shields.io/badge/Status-Enhanced-brightgreen)]() [![Version](https://img.shields.io/badge/Version-3.1-blue)]() [![AI](https://img.shields.io/badge/AI-Claude%20Optimized-orange)]() [![Quality](https://img.shields.io/badge/Quality-Auto%20Monitored-purple)]()

## 🌟 Overview

The Fantasy Novel Writing System v3.1 is a breakthrough **intelligent autonomous writing platform** that generates complete 100,000-word fantasy novels with **zero human intervention**. Built using advanced prompt engineering and Claude Code best practices, it now features **adaptive quality control**, **smart error recovery**, and **intelligent story planning** to create consistently high-quality fiction.

### ✨ Enhanced Key Features

- 🤖 **Fully Autonomous**: Writes complete novels without human input
- 📚 **Adaptive Quality**: Real-time quality monitoring with automatic standards adjustment
- 🧠 **Intelligent Planning**: Smart story analysis and adaptive chapter planning
- 🛡️ **Self-Healing**: Automatic error detection, diagnosis, and recovery
- 📊 **Performance Tracking**: Continuous monitoring and optimization
- 🎯 **Enhanced Agents**: Seven specialized sub-agents for different aspects
- ⚡ **One-Command Launch**: Complete setup with enhanced features in under 60 seconds

## 🚀 Quick Start

### 1. Initialize Enhanced System
```bash
./launch-novel.sh
./setup-enhancements.sh  # NEW: Install advanced features
```

### 2. Start Enhanced Generation
```bash
claude --dangerously-skip-permissions --continue
```

### 3. Monitor Real-Time Progress
```bash
python3 automation/dashboard.py --monitor
```

**That's it!** Your novel will be automatically generated with intelligent quality monitoring, adaptive planning, and self-healing capabilities.

## 🏗️ Enhanced Architecture

### Master Orchestrator
Central intelligence with **enhanced decision-making** that coordinates the entire novel creation process through intelligent assessment, adaptive planning, quality monitoring, and error recovery.

### Specialized Sub-Agents (Now 7 Total)

| Agent | Purpose | Enhanced Features |
|-------|---------|-------------------|
| 🎭 **Scene Writer** | Immersive prose creation | Quality-aware generation with metrics feedback |
| 🏛️ **Plot Architect** | Story structure & pacing | Context-aware planning with progress analysis |
| 🌍 **Worldbuilder** | Fantasy settings & systems | Consistency-aware world expansion |
| 👥 **Character Developer** | Psychological depth & voice | Arc-aware development with relationship tracking |
| ✅ **Continuity Editor** | Consistency maintenance | Intelligence-enhanced error detection |
| 🛡️ **Error Recovery** | **NEW**: System diagnosis & repair | Automatic issue resolution and prevention |
| 🧠 **Smart Planner** | **NEW**: Adaptive story planning | Progress-responsive chapter optimization |

### Enhanced Workflow Loop
```
Health Check → State Sync → Quality Analysis → Smart Planning → 
Enhanced Generation → Quality Monitoring → Performance Tracking → 
Error Prevention → Adaptive Optimization → Repeat
```

## 📊 Intelligent Quality Standards

The system now **automatically monitors and adapts** quality standards:

### Real-Time Quality Metrics
- **Word Count Analysis**: Chapter and scene length optimization
- **Dialogue Ratio**: 30-40% conversation balance with automatic detection
- **Sensory Density**: Rich environmental immersion tracking (15+ details per 1000 words)
- **Paragraph Length**: Optimal readability maintenance (<80 words average)
- **Character Consistency**: Voice and behavior pattern monitoring
- **World Logic**: Internal consistency enforcement with rule tracking

### Adaptive Quality Modes
- **Excellence Mode** (90+ score): Publication-ready standards
- **Standard Mode** (60-79 score): Balanced quality and progress
- **Quality Focus Mode** (<60 score): Enhanced standards with revision
- **High Performance Mode** (80+ score): Optimized for momentum

## 🎯 Enhanced Novel Generation Process

### Phase 1: Intelligent Foundation (Chapters 1-7)
- **Smart outline creation** with adaptive planning
- **Quality-monitored character establishment**
- **Consistency-tracked world-building**
- **Performance-optimized magic system definition**

### Phase 2: Adaptive Development (Chapters 8-15)
- **Intelligently-planned character relationships**
- **Quality-assured world exploration**
- **Monitored subplot introduction and development**
- **Performance-tracked conflict escalation**

### Phase 3: Smart Acceleration (Chapters 16-25)
- **Strategically-timed major revelations**
- **Quality-maintained character growth acceleration**
- **Intelligently-paced plot intensification**
- **Adaptively-planned climax preparation**

### Phase 4: Optimal Resolution (Chapters 26-30)
- **Quality-assured climactic confrontations**
- **Completion-monitored character arc resolution**
- **Consistency-verified subplot resolution**
- **Excellence-mode final polish**

## 📈 Intelligent Monitoring & Analytics

### Enhanced Real-Time Dashboard
```bash
# Live monitoring with issue detection
python3 automation/dashboard.py --monitor

# Generate synchronization report
python3 automation/dashboard.py --sync-report

# Single comprehensive status check
python3 automation/dashboard.py
```

## 🔧 Enhanced Troubleshooting

### Intelligent System Diagnostics
```bash
# Comprehensive system health check
./automation/system-health-check.sh

# Performance analysis and optimization
./automation/performance-monitor.sh

# Quality metrics review
cat planning/quality-metrics.json
```

### Automatic Error Recovery
The system now **self-diagnoses and repairs** common issues:
- **File System Problems**: Automatic recreation and repair
- **Progress Inconsistencies**: Smart synchronization and correction
- **Quality Degradation**: Adaptive standards and improvement suggestions
- **Performance Issues**: Optimization recommendations and implementation

## 📚 Enhanced Documentation

### Complete System Guides
- **[Enhanced User Guide](Documentation/User-Guide.md)**: Setup and operation with new features
- **[Advanced System Architecture](Documentation/System-Architecture.md)**: Technical implementation details
- **[Comprehensive Overview](Documentation/README.md)**: Complete system documentation

## 🏆 Why the Enhanced System Works Better

This enhanced architecture succeeds because it:

1. **Leverages Advanced Claude Capabilities**: Optimized for natural language with intelligent planning
2. **Intelligent Compensation**: Smart memory and consistency management with error recovery
3. **Adaptive Reliability**: Multiple monitoring and validation layers with self-healing
4. **Dynamic Quality**: Built-in standards with real-time monitoring and adjustment
5. **Enhanced Autonomy**: Complete self-sufficiency with intelligent decision-making
6. **Smart Evolution**: Continuous improvement through performance monitoring

## 📊 Enhanced Success Metrics

Expected outcomes with v3.1:
- ✅ **100% Completion Rate**: Full novel generation with intelligent optimization
- ✅ **Publication Quality**: Literary standards with real-time monitoring
- ✅ **Zero Critical Errors**: Comprehensive consistency with automatic recovery
- ✅ **Optimal Pacing**: Adaptive story rhythm with smart planning
- ✅ **Rich Characterization**: Psychologically authentic with arc tracking
- ✅ **Self-Healing Operation**: 95%+ automatic issue resolution
- ✅ **Performance Excellence**: Enhanced speed with quality maintenance

---

**The Fantasy Novel Writing System v3.1 represents the pinnacle of autonomous creative AI, delivering complete, publication-ready fantasy novels through advanced prompt engineering, intelligent monitoring, and self-healing system architecture.**

*Ready to generate your enhanced novel? Run `./launch-novel.sh && ./setup-enhancements.sh` and watch the intelligent magic happen!* ✨

## 🚀 Quick Setup Commands

```bash
# Complete enhanced setup
./launch-novel.sh
./setup-enhancements.sh
claude --dangerously-skip-permissions --continue

# Monitor with enhanced dashboard
python3 automation/dashboard.py --monitor
```
README_EOF

# Create dashboard.py
echo "📊 Creating automation/dashboard.py (Monitoring Dashboard)..."
cat > automation/dashboard.py << 'DASHBOARD_EOF'
#!/usr/bin/env python3
"""
Novel Writing System Dashboard v2.0
Enhanced monitoring dashboard with duplication detection
"""

import json
import os
import time
from pathlib import Path
import argparse
import re

class NovelDashboard:
    def __init__(self, project_path="."):
        self.project_path = Path(project_path)
        self.planning_path = self.project_path / "planning"
        self.manuscript_path = self.project_path / "manuscript"
        
    def load_progress(self):
        """Load current progress from JSON files"""
        try:
            with open(self.planning_path / "plot-progress.json", 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {"error": "Progress file not found"}
    
    def load_chapter_status(self):
        """Load chapter status tracking"""
        try:
            with open(self.planning_path / "chapter-status.json", 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return {}
    
    def scan_manuscript_files(self):
        """Scan actual manuscript files and return detailed info"""
        chapters_path = self.manuscript_path / "chapters"
        files_info = {}
        
        if not chapters_path.exists():
            return files_info
            
        for chapter_file in chapters_path.glob("*.md"):
            try:
                with open(chapter_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    words = len(content.split())
                    
                # Extract chapter number from filename
                match = re.search(r'chapter-(\d+)', chapter_file.name)
                chapter_num = int(match.group(1)) if match else 0
                
                files_info[chapter_file.name] = {
                    "chapter_number": chapter_num,
                    "word_count": words,
                    "status": "complete" if words >= 3000 else "in_progress" if words >= 500 else "minimal",
                    "file_size": chapter_file.stat().st_size,
                    "modified": time.ctime(chapter_file.stat().st_mtime)
                }
            except Exception as e:
                files_info[chapter_file.name] = {
                    "error": str(e),
                    "word_count": 0,
                    "status": "error"
                }
                
        return files_info
    
    def detect_issues(self, files_info, progress, chapters):
        """Detect potential duplication and consistency issues"""
        issues = []
        
        # Check for duplicate chapter numbers
        chapter_numbers = {}
        for filename, info in files_info.items():
            if "chapter_number" in info:
                num = info["chapter_number"]
                if num in chapter_numbers:
                    issues.append(f"🚨 DUPLICATE: Chapter {num} exists in multiple files: {chapter_numbers[num]} and {filename}")
                else:
                    chapter_numbers[num] = filename
        
        # Check for gaps in chapter sequence
        if chapter_numbers:
            max_chapter = max(chapter_numbers.keys())
            for i in range(1, max_chapter):
                if i not in chapter_numbers:
                    issues.append(f"⚠️  GAP: Chapter {i} is missing from sequence")
        
        # Check for tracking vs reality mismatches
        for filename, file_info in files_info.items():
            if "chapter_number" in file_info:
                chapter_key = f"chapter_{file_info['chapter_number']}"
                if chapter_key in chapters:
                    tracked_words = chapters[chapter_key].get("words", 0)
                    actual_words = file_info["word_count"]
                    
                    if abs(tracked_words - actual_words) > 100:
                        issues.append(f"📊 MISMATCH: {filename} has {actual_words} words but tracking shows {tracked_words}")
                    
                    tracked_status = chapters[chapter_key].get("status", "unknown")
                    actual_status = file_info["status"]
                    
                    if tracked_status != actual_status and actual_words >= 3000 and tracked_status != "complete":
                        issues.append(f"📋 STATUS: {filename} appears complete ({actual_words} words) but marked as {tracked_status}")
        
        return issues
    
    def count_total_words(self, files_info):
        """Count total words from actual files"""
        return sum(info.get("word_count", 0) for info in files_info.values() if "word_count" in info)
    
    def display_status(self):
        """Display comprehensive novel writing status with issue detection"""
        progress = self.load_progress()
        chapters = self.load_chapter_status()
        files_info = self.scan_manuscript_files()
        total_words = self.count_total_words(files_info)
        issues = self.detect_issues(files_info, progress, chapters)
        
        print("\n" + "="*70)
        print("📚 FANTASY NOVEL WRITING SYSTEM - STATUS DASHBOARD v2.0")
        print("="*70)
        
        if "error" in progress:
            print("❌ Error: Progress tracking not initialized")
            return
            
        # Basic info
        print(f"📖 Novel Title: {progress.get('novel_title', 'Untitled')}")
        print(f"🎯 Target Words: {progress.get('target_words', 100000):,}")
        print(f"📝 Actual Words: {total_words:,}")
        
        # Calculate progress percentage
        target = progress.get('target_words', 100000)
        percentage = (total_words / target) * 100 if target > 0 else 0
        print(f"📊 Progress: {percentage:.1f}%")
        
        # Progress bar
        bar_length = 50
        filled_length = int(bar_length * percentage / 100)
        bar = "█" * filled_length + "░" * (bar_length - filled_length)
        print(f"📈 [{bar}] {percentage:.1f}%")
        
        print()
        
        # Issues section (prominent if any exist)
        if issues:
            print("🚨 DETECTED ISSUES:")
            print("-" * 50)
            for issue in issues:
                print(f"   {issue}")
            print()
        else:
            print("✅ No tracking issues detected")
            print()
        
        # Current status
        print(f"📌 Tracked Chapter: {progress.get('current_chapter', 1)}")
        print(f"🔍 Tracked Scene: {progress.get('current_scene', 1)}")
        print(f"📋 Chapter Status: {progress.get('chapter_status', 'unknown')}")
        print(f"🎯 Next Milestone: {progress.get('next_milestone', 'unknown')}")
        print(f"⏰ Last Action: {progress.get('last_action', 'unknown')}")
        print(f"🔄 Last Sync: {progress.get('last_sync_time', 'never')}")
        
        print()
        
        # File-based chapter status (ground truth)
        print("📁 ACTUAL FILE STATUS (Ground Truth):")
        print("-" * 50)
        
        if files_info:
            # Sort by chapter number
            sorted_files = sorted(files_info.items(), 
                                key=lambda x: x[1].get("chapter_number", 999))
            
            for filename, info in sorted_files:
                if "chapter_number" in info:
                    status_icon = {
                        'complete': '✅',
                        'in_progress': '🔄',
                        'minimal': '⭕',
                        'error': '❌'
                    }.get(info["status"], '❓')
                    
                    chapter_num = info["chapter_number"]
                    words = info["word_count"]
                    print(f"{status_icon} Chapter {chapter_num:02d}: {info['status']} ({words:,} words) - {filename}")
        else:
            print("   No chapter files found")
            
        print()
        
        # Tracked vs actual comparison
        print("📊 TRACKING VS REALITY:")
        print("-" * 50)
        
        highest_file_chapter = 0
        if files_info:
            highest_file_chapter = max(info.get("chapter_number", 0) for info in files_info.values())
        
        tracked_chapter = progress.get('current_chapter', 1)
        
        print(f"📈 Highest file chapter: {highest_file_chapter}")
        print(f"📋 Tracked current chapter: {tracked_chapter}")
        
        if highest_file_chapter > tracked_chapter:
            print(f"⚠️  TRACKING BEHIND: Files exist up to chapter {highest_file_chapter} but tracking shows {tracked_chapter}")
        elif highest_file_chapter < tracked_chapter:
            print(f"⚠️  TRACKING AHEAD: Tracking shows chapter {tracked_chapter} but files only go to {highest_file_chapter}")
        else:
            print("✅ Tracking appears synchronized with files")
        
        print()
        
        # File system status
        print("📁 SYSTEM COMPONENTS:")
        print("-" * 50)
        
        key_paths = [
            ("CLAUDE.md", "Master config"),
            (".claude/agents/", "Sub-agents"),
            ("manuscript/chapters/", "Manuscript"),
            ("planning/", "Planning files"),
            ("worldbuilding/", "World data"),
            ("characters/", "Character data")
        ]
        
        for path, description in key_paths:
            full_path = self.project_path / path
            status = "✅" if full_path.exists() else "❌"
            print(f"{status} {description}: {path}")
            
        print()
        
        # Recommendations
        if issues:
            print("🔧 RECOMMENDED ACTIONS:")
            print("-" * 50)
            print("1. Stop the current generation process")
            print("2. Run state synchronization to fix tracking")
            print("3. Review duplicate files and remove/merge as needed")
            print("4. Restart generation with corrected state")
        else:
            print("🚀 SYSTEM STATUS: Healthy - Continue generation")
            
        print("\n" + "="*70)
        print(f"⏰ Dashboard updated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*70)
    
    def generate_sync_report(self):
        """Generate a synchronization report to fix issues"""
        files_info = self.scan_manuscript_files()
        
        print("\n" + "="*60)
        print("🔧 STATE SYNCHRONIZATION REPORT")
        print("="*60)
        
        if not files_info:
            print("No chapter files found - starting fresh")
            return
        
        # Generate corrected chapter-status.json
        corrected_status = {}
        total_words = 0
        
        for filename, info in files_info.items():
            if "chapter_number" in info and info["chapter_number"] > 0:
                chapter_key = f"chapter_{info['chapter_number']}"
                words = info["word_count"]
                total_words += words
                
                status = "complete" if words >= 3000 else "in_progress" if words >= 500 else "not_started"
                
                corrected_status[chapter_key] = {
                    "status": status,
                    "words": words,
                    "file_exists": True
                }
        
        # Determine highest chapter and next action
        highest_chapter = max(info.get("chapter_number", 0) for info in files_info.values())
        
        # Find first incomplete chapter
        next_chapter = highest_chapter + 1
        for i in range(1, highest_chapter + 1):
            chapter_key = f"chapter_{i}"
            if chapter_key in corrected_status and corrected_status[chapter_key]["status"] != "complete":
                next_chapter = i
                break
        
        print(f"📊 Total actual words: {total_words:,}")
        print(f"📈 Highest chapter file: {highest_chapter}")
        print(f"🎯 Next chapter to work on: {next_chapter}")
        
        print("\n🔧 Copy this corrected chapter-status.json:")
        print("-" * 40)
        print(json.dumps(corrected_status, indent=2))
        
        corrected_progress = {
            "current_chapter": next_chapter,
            "current_scene": 1,
            "total_words": total_words,
            "chapter_status": "not_started" if next_chapter > highest_chapter else "in_progress",
            "last_action": "synchronized_with_files",
            "next_milestone": f"complete_chapter_{next_chapter}",
            "chapters_completed": [i for i in range(1, highest_chapter + 1) 
                                 if f"chapter_{i}" in corrected_status and 
                                 corrected_status[f"chapter_{i}"]["status"] == "complete"],
            "last_sync_time": time.strftime('%Y-%m-%d %H:%M:%S')
        }
        
        print("\n🔧 Copy this corrected plot-progress.json:")
        print("-" * 40)
        print(json.dumps(corrected_progress, indent=2))
    
    def monitor_continuous(self, interval=30):
        """Continuously monitor and display status"""
        print("🔄 Starting continuous monitoring...")
        print(f"📊 Refreshing every {interval} seconds")
        print("⏹️  Press Ctrl+C to stop monitoring")
        
        try:
            while True:
                os.system('clear' if os.name == 'posix' else 'cls')
                self.display_status()
                time.sleep(interval)
        except KeyboardInterrupt:
            print("\n👋 Monitoring stopped")

def main():
    parser = argparse.ArgumentParser(description="Novel Writing System Dashboard v2.0")
    parser.add_argument("--path", default=".", help="Path to novel project")
    parser.add_argument("--monitor", "-m", action="store_true", 
                       help="Continuous monitoring mode")
    parser.add_argument("--sync-report", "-s", action="store_true",
                       help="Generate state synchronization report")
    parser.add_argument("--interval", "-i", type=int, default=30,
                       help="Monitoring refresh interval (seconds)")
    
    args = parser.parse_args()
    
    dashboard = NovelDashboard(args.path)
    
    if args.sync_report:
        dashboard.generate_sync_report()
    elif args.monitor:
        dashboard.monitor_continuous(args.interval)
    else:
        dashboard.display_status()

if __name__ == "__main__":
    main()
DASHBOARD_EOF

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

# Create .claude/settings.json with enhanced hooks
cat > .claude/settings.json << 'SETTINGS_EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "task",
        "hooks": [
          {
            "type": "command",
            "command": "echo '<system_reminder>CRITICAL: You just completed a task. IMMEDIATELY: 1) Use Write tool to save the output, 2) Use LS to check existing files, 3) Read and update progress files to match reality, 4) Determine next action. NEVER create duplicate chapters. Check what exists first.</system_reminder>' >> .claude/context-injection.txt"
          }
        ]
      },
      {
        "matcher": "Write", 
        "hooks": [
          {
            "type": "command",
            "command": "echo '<system_reminder>File saved successfully. NEXT STEPS: 1) Check if this chapter is now complete (>3000 words), 2) Update chapter-status.json with actual word count, 3) Update plot-progress.json with current position, 4) Use LS to verify file structure, 5) Continue to next action. PREVENT DUPLICATION.</system_reminder>' >> .claude/context-injection.txt"
          },
          {
            "type": "command",
            "command": "automation/quality-check.sh"
          }
        ]
      },
      {
        "matcher": "LS",
        "hooks": [
          {
            "type": "command",
            "command": "echo '<system_reminder>File listing complete. Use this information to: 1) Identify highest existing chapter number, 2) Check for gaps or duplicates, 3) Update progress tracking to match reality, 4) Determine next chapter to work on. Never create files that already exist with substantial content.</system_reminder>' >> .claude/context-injection.txt"
          }
        ]
      },
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "echo '<system_reminder>Content read successfully. If this was a progress file or chapter file: 1) Note actual word counts and status, 2) Identify any discrepancies with tracking, 3) Plan corrections to align tracking with reality, 4) Never duplicate existing substantial content (>2000 words).</system_reminder>' >> .claude/context-injection.txt"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "automation/auto-backup.sh"
          },
          {
            "type": "command",
            "command": "claude --continue --dangerously-skip-permissions -p 'CRITICAL: Start with state synchronization. Use LS to check existing chapters, Read progress files, update tracking to match reality, then continue novel generation. Never duplicate existing work. Check files first, then proceed with next required chapter.'",
            "run_in_background": true
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "automation/system-health-check.sh"
          },
          {
            "type": "command",
            "command": "echo '<system_reminder>Session started. You are the MASTER ORCHESTRATOR. FIRST ACTION: Synchronize state by using LS manuscript/chapters/, Read progress files, update tracking to match reality. Then continue novel generation. CRITICAL: Never duplicate existing chapters with substantial content.</system_reminder>' >> .claude/context-injection.txt"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF

# Create empty context injection file
touch .claude/context-injection.txt

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

# Make scripts executable
chmod +x automation/dashboard.py

echo "💾 All essential files created successfully!"

echo ""
echo "✅ Fantasy Novel Writing System v3.1 ready!"
echo ""
echo "📋 Files created:"
echo "   ✅ CLAUDE.md - Master Orchestrator configuration"
echo "   ✅ README.md - Complete system documentation"
echo "   ✅ automation/dashboard.py - Real-time monitoring dashboard"
echo "   ✅ sync-state.sh - State synchronization script"
echo "   ✅ .claude/settings.json - Enhanced automation hooks"
echo "   ✅ All progress tracking files initialized"
echo ""
echo "🎯 Next steps:"
echo "1. Run: ./setup-enhancements.sh (for advanced features)"
echo "2. Run: claude --dangerously-skip-permissions --continue"
echo "3. Monitor progress with: python3 automation/dashboard.py --monitor"
echo ""
echo "📝 The complete system will:"
echo "   ✅ Always check existing files before creating new ones"
echo "   ✅ Prevent chapter duplication through state synchronization"
echo "   ✅ Maintain accurate progress tracking"
echo "   ✅ Self-correct any inconsistencies automatically"
echo "   ✅ Provide real-time monitoring and quality control"
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