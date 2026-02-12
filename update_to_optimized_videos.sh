#!/bin/bash

# Script to update index.html to use optimized video files
HTML_FILE="/Users/sungjaepark/Desktop/Research/p-demodiffusion/demodiffusion.github.io/index.html"
BACKUP_FILE="${HTML_FILE}.backup"

echo "Creating backup of original HTML..."
cp "$HTML_FILE" "$BACKUP_FILE"

echo "Updating HTML to use optimized videos..."

# Find all optimized videos and update the HTML
find "/Users/sungjaepark/Desktop/Research/p-demodiffusion/demodiffusion.github.io/static/videos" -name "*_optimized.mp4" | while read optimized_file; do
    # Extract the original filename (remove _optimized.mp4 and add .mp4)
    original_file=$(echo "$optimized_file" | sed 's/_optimized\.mp4$/.mp4/')
    
    # Get relative paths for HTML
    optimized_relative=$(echo "$optimized_file" | sed 's|.*/demodiffusion\.github\.io/||')
    original_relative=$(echo "$original_file" | sed 's|.*/demodiffusion\.github\.io/||')
    
    # Check if original file reference exists in HTML and replace it
    if grep -q "$original_relative" "$HTML_FILE"; then
        sed -i '' "s|$original_relative|$optimized_relative|g" "$HTML_FILE"
        echo "✓ Updated: $original_relative → $optimized_relative"
    fi
done

echo ""
echo "HTML update complete!"
echo "Backup saved as: $BACKUP_FILE"
echo ""

# Show some statistics
original_videos=$(grep -o 'src="[^"]*\.mp4"' "$BACKUP_FILE" | wc -l)
optimized_videos=$(grep -o 'src="[^"]*_optimized\.mp4"' "$HTML_FILE" | wc -l)

echo "Statistics:"
echo "  Original videos in backup: $original_videos"
echo "  Optimized videos now used: $optimized_videos"
echo ""
echo "Your website will now load much faster with optimized videos!"