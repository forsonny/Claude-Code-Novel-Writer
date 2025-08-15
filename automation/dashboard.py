#!/usr/bin/env python3
"""
Novel Writing System Dashboard
Simple monitoring dashboard for the autonomous novel writing system
"""

import json
import os
import time
from pathlib import Path
import argparse

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
    
    def count_manuscript_words(self):
        """Count total words in manuscript files"""
        total_words = 0
        chapters_path = self.manuscript_path / "chapters"
        
        if not chapters_path.exists():
            return 0
            
        for chapter_file in chapters_path.glob("*.md"):
            try:
                with open(chapter_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    words = len(content.split())
                    total_words += words
            except Exception as e:
                print(f"Error reading {chapter_file}: {e}")
                
        return total_words
    
    def display_status(self):
        """Display current novel writing status"""
        progress = self.load_progress()
        chapters = self.load_chapter_status()
        manuscript_words = self.count_manuscript_words()
        
        print("\n" + "="*60)
        print("📚 FANTASY NOVEL WRITING SYSTEM - STATUS DASHBOARD")
        print("="*60)
        
        if "error" in progress:
            print("❌ Error: Progress tracking not initialized")
            return
            
        # Basic info
        print(f"📖 Novel Title: {progress.get('novel_title', 'Untitled')}")
        print(f"🎯 Target Words: {progress.get('target_words', 100000):,}")
        print(f"📝 Current Words: {manuscript_words:,}")
        
        # Calculate progress percentage
        target = progress.get('target_words', 100000)
        percentage = (manuscript_words / target) * 100 if target > 0 else 0
        print(f"📊 Progress: {percentage:.1f}%")
        
        # Progress bar
        bar_length = 40
        filled_length = int(bar_length * percentage / 100)
        bar = "█" * filled_length + "░" * (bar_length - filled_length)
        print(f"📈 [{bar}] {percentage:.1f}%")
        
        print()
        
        # Current status
        print(f"📌 Current Chapter: {progress.get('current_chapter', 1)}")
        print(f"🔍 Current Scene: {progress.get('current_scene', 1)}")
        print(f"📋 Chapter Status: {progress.get('chapter_status', 'unknown')}")
        print(f"🎯 Next Milestone: {progress.get('next_milestone', 'unknown')}")
        print(f"⏰ Last Action: {progress.get('last_action', 'unknown')}")
        
        print()
        
        # Chapter breakdown
        print("📚 CHAPTER STATUS:")
        print("-" * 40)
        
        if chapters:
            for chapter, info in sorted(chapters.items()):
                status = info.get('status', 'unknown')
                words = info.get('words', 0)
                status_icon = {
                    'complete': '✅',
                    'in_progress': '🔄',
                    'not_started': '⭕',
                    'unknown': '❓'
                }.get(status, '❓')
                
                print(f"{status_icon} {chapter}: {status} ({words:,} words)")
        else:
            print("   No chapters tracked yet")
            
        print()
        
        # File system status
        print("📁 FILE SYSTEM STATUS:")
        print("-" * 40)
        
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
            
        print("\n" + "="*60)
        print(f"⏰ Dashboard updated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        print("="*60)
    
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
    parser = argparse.ArgumentParser(description="Novel Writing System Dashboard")
    parser.add_argument("--path", default=".", help="Path to novel project")
    parser.add_argument("--monitor", "-m", action="store_true", 
                       help="Continuous monitoring mode")
    parser.add_argument("--interval", "-i", type=int, default=30,
                       help="Monitoring refresh interval (seconds)")
    
    args = parser.parse_args()
    
    dashboard = NovelDashboard(args.path)
    
    if args.monitor:
        dashboard.monitor_continuous(args.interval)
    else:
        dashboard.display_status()

if __name__ == "__main__":
    main()
