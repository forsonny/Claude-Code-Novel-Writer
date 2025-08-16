#!/bin/bash
# automation/quality-check.sh - Automated quality monitoring
# FIXED VERSION: Safe JSON updates and improved error handling

# Get the most recently modified chapter file
latest_chapter=$(ls -t manuscript/chapters/chapter-*.md 2>/dev/null | head -n 1)

if [ -z "$latest_chapter" ]; then
    echo "No chapters found for quality check"
    exit 0
fi

echo "🔍 Running quality check on $latest_chapter"

# Extract chapter number safely
chapter_num=$(basename "$latest_chapter" | grep -o '[0-9]\+' | head -1)
if [ -z "$chapter_num" ]; then
    echo "Could not extract chapter number from $latest_chapter"
    exit 1
fi

# Ensure planning directory exists
mkdir -p planning

# Quality metrics with error handling
word_count=$(wc -w < "$latest_chapter" 2>/dev/null || echo "0")
char_count=$(wc -c < "$latest_chapter" 2>/dev/null || echo "0")
line_count=$(wc -l < "$latest_chapter" 2>/dev/null || echo "0")

# Dialogue analysis
dialogue_lines=$(grep -c '".*"' "$latest_chapter" 2>/dev/null || echo "0")
total_paragraphs=$(grep -c '^[[:space:]]*[^[:space:]]' "$latest_chapter" 2>/dev/null || echo "1")

# Prevent division by zero
if [ "$total_paragraphs" -eq 0 ]; then
    total_paragraphs=1
fi

# Calculate dialogue ratio safely
if command -v bc >/dev/null 2>&1; then
    dialogue_ratio=$(echo "scale=2; ($dialogue_lines * 100) / $total_paragraphs" | bc -l 2>/dev/null || echo "0")
else
    dialogue_ratio=$(awk "BEGIN {printf \"%.2f\", ($dialogue_lines * 100) / $total_paragraphs}" 2>/dev/null || echo "0")
fi

# Sensory detail analysis
sight_words=$(grep -i -c '\(saw\|looked\|appeared\|visible\|bright\|dark\|color\|light\)' "$latest_chapter" 2>/dev/null || echo "0")
sound_words=$(grep -i -c '\(heard\|sound\|noise\|whisper\|shout\|echo\|silent\)' "$latest_chapter" 2>/dev/null || echo "0")
touch_words=$(grep -i -c '\(felt\|touch\|rough\|smooth\|cold\|warm\|soft\|hard\)' "$latest_chapter" 2>/dev/null || echo "0")
smell_words=$(grep -i -c '\(smell\|scent\|aroma\|stench\|fragrant\)' "$latest_chapter" 2>/dev/null || echo "0")

# Calculate sensory density (per 1000 words)
sensory_total=$((sight_words + sound_words + touch_words + smell_words))
if [ $word_count -gt 0 ]; then
    if command -v bc >/dev/null 2>&1; then
        sensory_density=$(echo "scale=2; ($sensory_total * 1000) / $word_count" | bc -l 2>/dev/null || echo "0")
    else
        sensory_density=$(awk "BEGIN {printf \"%.2f\", ($sensory_total * 1000) / $word_count}" 2>/dev/null || echo "0")
    fi
else
    sensory_density=0
fi

# Paragraph length analysis
if command -v bc >/dev/null 2>&1; then
    avg_words_per_paragraph=$(echo "scale=1; $word_count / $total_paragraphs" | bc -l 2>/dev/null || echo "0")
else
    avg_words_per_paragraph=$(awk "BEGIN {printf \"%.1f\", $word_count / $total_paragraphs}" 2>/dev/null || echo "0")
fi

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

# Calculate quality score
quality_score=$(echo "scale=1; (100 - ${#quality_issues[@]} * 15)" | bc -l 2>/dev/null || echo "100")
if [ $(echo "$quality_score < 0" | bc -l 2>/dev/null || echo "0") -eq 1 ]; then
    quality_score=0
fi

# Update quality tracking file safely
quality_file="planning/quality-metrics.json"
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Create or update quality metrics with safe JSON handling
temp_file=$(mktemp)

# Create base structure if file doesn't exist or is invalid
if [ ! -f "$quality_file" ] || ! python3 -m json.tool "$quality_file" >/dev/null 2>&1; then
    echo '{"chapters": {}}' > "$quality_file"
fi

# Build new chapter entry
chapter_entry=$(cat << EOF
{
  "timestamp": "$timestamp",
  "word_count": $word_count,
  "dialogue_ratio": $dialogue_ratio,
  "sensory_density": $sensory_density,
  "avg_paragraph_length": $avg_words_per_paragraph,
  "quality_score": $quality_score,
  "issues": [$(printf '"%s",' "${quality_issues[@]}" | sed 's/,$//')],
  "sensory_breakdown": {
    "sight": $sight_words,
    "sound": $sound_words,
    "touch": $touch_words,
    "smell": $smell_words
  }
}
EOF
)

# Use Python to safely update JSON if available
if command -v python3 >/dev/null 2>&1; then
    python3 << EOF
import json
import sys

try:
    # Read existing data
    with open('$quality_file', 'r') as f:
        data = json.load(f)
    
    # Add new chapter data
    data['chapters']['chapter_$chapter_num'] = $chapter_entry
    
    # Write back safely
    with open('$temp_file', 'w') as f:
        json.dump(data, f, indent=2)
        
    print("JSON updated successfully")
except Exception as e:
    print(f"Error updating JSON: {e}", file=sys.stderr)
    sys.exit(1)
EOF

    if [ $? -eq 0 ]; then
        mv "$temp_file" "$quality_file"
    else
        echo "Failed to update quality metrics with Python, using fallback"
        rm -f "$temp_file"
        # Fallback to manual JSON construction
        echo '{"chapters": {"chapter_'$chapter_num'": '$chapter_entry'}}' > "$quality_file"
    fi
else
    # Fallback for systems without Python
    echo '{"chapters": {"chapter_'$chapter_num'": '$chapter_entry'}}' > "$quality_file"
fi

# Report results
echo "📊 Quality Analysis Results for Chapter $chapter_num:"
echo "   Words: $word_count"
echo "   Dialogue: ${dialogue_ratio}%"
echo "   Sensory density: ${sensory_density}/1000 words"
echo "   Avg paragraph: ${avg_words_per_paragraph} words"
echo "   Quality score: $quality_score/100"

if [ ${#quality_issues[@]} -eq 0 ]; then
    echo "✅ Quality check passed - no issues detected"
    
    # Inject positive feedback
    echo '<system_reminder>✅ QUALITY CHECK PASSED: Latest chapter meets all quality standards. Continue with confidence. Maintain current writing quality level. Quality score: '$quality_score'/100.</system_reminder>' >> .claude/context-injection.txt 2>/dev/null || true
else
    echo "⚠️  Quality issues detected:"
    printf '   %s\n' "${quality_issues[@]}"
    
    # Inject improvement suggestions
    improvement_prompt="<system_reminder>📝 QUALITY IMPROVEMENTS NEEDED: Latest chapter has ${#quality_issues[@]} quality issues: $(printf '%s; ' "${quality_issues[@]}" | sed 's/; $//'). Quality score: $quality_score/100. Consider using the task tool with scene-writer to revise and improve this chapter before proceeding.</system_reminder>"
    echo "$improvement_prompt" >> .claude/context-injection.txt 2>/dev/null || true
fi

echo "💾 Quality metrics saved to $quality_file"

# Return appropriate exit code based on quality
if [ ${#quality_issues[@]} -eq 0 ]; then
    exit 0
elif [ ${#quality_issues[@]} -le 2 ]; then
    exit 1  # Minor issues
else
    exit 2  # Major issues
fi