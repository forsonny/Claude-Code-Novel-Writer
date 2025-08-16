#!/bin/bash
# automation/duplicate-checker.sh - Detect and report duplicate chapter files

echo "🔍 Checking for duplicate chapter files..."

# Create this file in your automation directory
mkdir -p automation

# Check for chapter files
mapfile -t chapter_files < <(ls manuscript/chapters/chapter-*.md 2>/dev/null | sort)

if [ ${#chapter_files[@]} -eq 0 ]; then
    echo "✅ No chapter files found - no duplicates possible"
    exit 0
fi

echo "📁 Found ${#chapter_files[@]} chapter files:"
printf '   %s\n' "${chapter_files[@]}"

# Track chapter numbers
declare -A chapter_numbers
duplicates_found=false

for file in "${chapter_files[@]}"; do
    # Extract chapter number
    if [[ $file =~ chapter-([0-9]+)\.md$ ]]; then
        chapter_num=${BASH_REMATCH[1]}
        # Remove leading zeros for comparison
        chapter_num=$((10#$chapter_num))
        
        if [ -n "${chapter_numbers[$chapter_num]}" ]; then
            echo "🚨 DUPLICATE FOUND: Chapter $chapter_num exists in multiple files:"
            echo "   ${chapter_numbers[$chapter_num]}"
            echo "   $file"
            duplicates_found=true
            
            # Check word counts to determine which to keep
            words1=$(wc -w < "${chapter_numbers[$chapter_num]}" 2>/dev/null || echo "0")
            words2=$(wc -w < "$file" 2>/dev/null || echo "0")
            echo "   File 1: $words1 words"
            echo "   File 2: $words2 words"
            
            if [ $words1 -gt $words2 ]; then
                echo "   📝 Recommendation: Keep ${chapter_numbers[$chapter_num]} (more content)"
            elif [ $words2 -gt $words1 ]; then
                echo "   📝 Recommendation: Keep $file (more content)"
            else
                echo "   📝 Recommendation: Manual review needed (similar word counts)"
            fi
            echo ""
        else
            chapter_numbers[$chapter_num]="$file"
        fi
    else
        echo "⚠️  Unrecognized file format: $file"
    fi
done

# Check for gaps in sequence
if [ ${#chapter_numbers[@]} -gt 0 ]; then
    max_chapter=$(printf '%s\n' "${!chapter_numbers[@]}" | sort -n | tail -1)
    echo "📊 Chapter sequence analysis (1 to $max_chapter):"
    
    for (( i=1; i<=max_chapter; i++ )); do
        if [ -n "${chapter_numbers[$i]}" ]; then
            words=$(wc -w < "${chapter_numbers[$i]}" 2>/dev/null || echo "0")
            if [ $words -ge 3000 ]; then
                echo "   ✅ Chapter $i: Complete ($words words)"
            elif [ $words -ge 500 ]; then
                echo "   🔄 Chapter $i: In progress ($words words)"
            else
                echo "   ⭕ Chapter $i: Minimal content ($words words)"
            fi
        else
            echo "   ❌ Chapter $i: Missing"
        fi
    done
fi

# Generate context injection based on findings
if [ "$duplicates_found" = true ]; then
    echo "🚨 CRITICAL: Duplicates detected - system needs immediate attention!"
    echo '<system_reminder>🚨 DUPLICATE FILES DETECTED: Multiple files exist for the same chapter numbers. IMMEDIATE ACTION REQUIRED: 1) Use error-recovery agent to analyze and resolve duplicates, 2) Run sync-state.sh to fix tracking, 3) Remove/merge duplicate files manually if needed, 4) DO NOT CREATE NEW CHAPTERS until duplicates resolved.</system_reminder>' >> .claude/context-injection.txt
    exit 1
else
    echo "✅ No duplicate chapter numbers detected"
    echo '<system_reminder>✅ DUPLICATE CHECK: No duplicate chapter files detected. Continue normal operation with confidence. Current chapter sequence verified.</system_reminder>' >> .claude/context-injection.txt
    exit 0
fi