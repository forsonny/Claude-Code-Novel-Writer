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