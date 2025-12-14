#!/bin/bash

# WinDiagKit for Mac - Diagnostic Script
# Saves report to Desktop or current dir

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="./Mac_Diagnostic_$TIMESTAMP.txt"

echo "=== System Diagnostic Report (Mac) ===" > "$REPORT_FILE"
echo "Date: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "gathering system info..."

# 1. System Info
echo "--- Hardware Information ---" >> "$REPORT_FILE"
sysctl hw.model hw.ncpu hw.memsize >> "$REPORT_FILE"
sw_vers >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. Disk Usage
echo "--- Disk Usage ---" >> "$REPORT_FILE"
df -h / >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 3. Memory Stats
echo "--- Memory Statistics ---" >> "$REPORT_FILE"
vm_stat >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 4. Top Processes (CPU)
echo "--- Top 5 CPU Consumers ---" >> "$REPORT_FILE"
ps -Aceo pid,pcpu,comm -r | head -n 6 >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 5. Home Directory Size
echo "--- User Home Directory Size ---" >> "$REPORT_FILE"
du -sh "$HOME" 2>/dev/null >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 6. Large Cache Folders
echo "--- Large Cache Folders (>500M) ---" >> "$REPORT_FILE"
du -sh "$HOME/Library/Caches"/* 2>/dev/null | grep "[0-9]G\|[5-9][0-9][0-9]M" >> "$REPORT_FILE"

echo "Diagnostic complete! Report saved to: $REPORT_FILE"
cat "$REPORT_FILE"
