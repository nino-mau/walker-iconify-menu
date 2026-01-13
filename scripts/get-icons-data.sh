#!/usr/bin/env bash

# Script to generate a JSON file containing all Iconify icon names
# Format: {"collection1": ["icon1", "icon2"], "collection2": [...]}

set -euo pipefail

# Directory of the script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTFILE="$DIR/../data/icons.json"

echo "Fetching all Iconify collections..." >&2

# Get all collection prefixes
collections=$(curl -s "https://api.iconify.design/collections" | jq -r 'keys[]')

# Count total collections
total_collections=$(echo "$collections" | wc -l)
echo "Found $total_collections collections" >&2

# Start JSON object
echo "{" >"$OUTFILE"

# Track if we need to add comma
first_collection=true
collection_count=0
total_icons=0

# Process each collection
for collection in $collections; do
  collection_count=$((collection_count + 1))
  echo "[$collection_count/$total_collections] Processing collection: $collection" >&2

  # Get all icons in this collection
  icons=$(curl -s "https://api.iconify.design/collection?prefix=$collection" | jq -r '.uncategorized[]?' 2>/dev/null || echo "")

  # If no icons in uncategorized, try categories
  if [ -z "$icons" ]; then
    icons=$(curl -s "https://api.iconify.design/collection?prefix=$collection" | jq -r '.categories | to_entries[] | .value[]' 2>/dev/null || echo "")
  fi

  # Count icons in this collection
  icon_count=$(echo "$icons" | grep -c . || echo "0")

  if [ "$icon_count" -gt 0 ]; then
    echo "  Found $icon_count icons" >&2
    total_icons=$((total_icons + icon_count))

    # Add comma if not first collection
    if [ "$first_collection" = true ]; then
      first_collection=false
    else
      echo "," >>"$OUTFILE"
    fi

    # Write collection name and start array
    echo -n "\"$collection\":[" >>"$OUTFILE"

    # Add icons to array
    first_icon=true
    for icon in $icons; do
      if [ "$first_icon" = true ]; then
        first_icon=false
      else
        echo -n "," >>"$OUTFILE"
      fi
      echo -n "\"$icon\"" >>"$OUTFILE"
    done

    # Close array
    echo -n "]" >>"$OUTFILE"
  else
    echo "  No icons found (skipping)" >&2
  fi
done

# Close JSON object
echo "}" >>"$OUTFILE"

echo "" >&2
echo "Done! All icons saved to $OUTFILE" >&2
echo "Total collections: $collection_count" >&2
echo "Total icons: $total_icons" >&2
echo "JSON file size: $(du -h "$OUTFILE" | cut -f1)" >&2

# Create gzip compressed version
echo "" >&2
echo "Creating gzip compressed version..." >&2
gzip -c "$OUTFILE" >"${OUTFILE}.gz"
echo "Compressed file: ${OUTFILE}.gz" >&2
echo "Compressed size: $(du -h "${OUTFILE}.gz" | cut -f1)" >&2
echo "Compression ratio: $(echo "scale=1; $(stat -c%s "${OUTFILE}.gz") * 100 / $(stat -c%s "$OUTFILE")" | bc)%" >&2
