#!/bin/bash

PAGE_SIZE=$(vm_stat | awk '/page size of/ {print $8}')
TOTAL_BYTES=$(sysctl -n hw.memsize)

if [[ -z "$PAGE_SIZE" || -z "$TOTAL_BYTES" || "$PAGE_SIZE" -eq 0 ]]; then
  exit 0
fi

USED_PAGES=$(vm_stat | awk '
  /Pages active/ { active = $3 }
  /Pages wired down/ { wired = $4 }
  /Pages occupied by compressor/ { compressed = $5 }
  END {
    gsub(/[^0-9]/, "", active)
    gsub(/[^0-9]/, "", wired)
    gsub(/[^0-9]/, "", compressed)
    print active + wired + compressed
  }
')

TOTAL_PAGES=$(awk -v bytes="$TOTAL_BYTES" -v page_size="$PAGE_SIZE" \
  'BEGIN { printf "%.0f", bytes / page_size }')
MEMORY_PERCENT=$(awk -v used="$USED_PAGES" -v total="$TOTAL_PAGES" \
  'BEGIN { printf "%.0f", (used / total) * 100 }')

sketchybar --set "$NAME" label="$MEMORY_PERCENT%"
