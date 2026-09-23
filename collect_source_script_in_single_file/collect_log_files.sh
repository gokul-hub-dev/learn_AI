#!/bin/bash

# ============================================================
# Log File Collector
#
# Generates:
#   log_files.txt
#
# Recursively collects all regular files under the current
# directory, including files inside subdirectories such as
# PreviousLogs/.
#
# Format:
#   Path:<relative file path>
#   <complete original file content>
# ============================================================

set -e

ROOT_DIR="."
OUTPUT_FILE="log_files.txt"
SELF_SCRIPT="collect_log_files.sh"

# Remove old generated file
rm -f "$OUTPUT_FILE"

# Create empty output file
touch "$OUTPUT_FILE"

find "$ROOT_DIR" -type f \
    ! -name "$OUTPUT_FILE" \
    ! -name "$SELF_SCRIPT" \
    -print0 |
sort -z |
while IFS= read -r -d '' file
do
    relative_path="${file#./}"

    if [ -s "$OUTPUT_FILE" ]; then
        printf "\n\n" >> "$OUTPUT_FILE"
    fi

    printf "Path:%s\n" "$relative_path" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    printf "\n" >> "$OUTPUT_FILE"
done

echo
echo "=========================================="
echo " Log collection completed"
echo "=========================================="
echo
echo "Generated:"
echo "  $OUTPUT_FILE"
echo
echo "File count: $(grep -c '^Path:' "$OUTPUT_FILE" 2>/dev/null || true)"
echo