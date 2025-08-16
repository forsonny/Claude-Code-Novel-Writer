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