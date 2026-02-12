#!/bin/bash

# Script to optimize video compression for web
# This will create optimized versions with better compression

VIDEO_DIR="/Users/sungjaepark/Desktop/Research/p-demodiffusion/demodiffusion.github.io/static/videos"

if ! command -v ffmpeg &> /dev/null; then
    echo "FFmpeg is required but not installed. Please install FFmpeg first:"
    echo "  brew install ffmpeg"
    exit 1
fi

echo "Optimizing videos for web performance..."

# Function to optimize a single video
optimize_video() {
    local input_file="$1"
    local output_file="${input_file%.*}_optimized.mp4"
    
    if [[ -f "$output_file" ]]; then
        echo "Skipping $input_file (optimized version already exists)"
        return
    fi
    
    echo "Optimizing: $(basename "$input_file")"
    
    # Optimize with good compression while maintaining quality
    ffmpeg -i "$input_file" \
        -c:v libx264 \
        -preset medium \
        -crf 28 \
        -c:a aac \
        -b:a 128k \
        -movflags +faststart \
        -pix_fmt yuv420p \
        -vf "scale=iw*min(1280/iw\,720/ih):ih*min(1280/iw\,720/ih)" \
        "$output_file" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        local original_size=$(stat -f%z "$input_file" 2>/dev/null || stat -c%s "$input_file")
        local optimized_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file")
        local reduction=$((100 - (optimized_size * 100 / original_size)))
        
        echo "  Original: $(numfmt --to=iec-i --suffix=B $original_size)"
        echo "  Optimized: $(numfmt --to=iec-i --suffix=B $optimized_size)"
        echo "  Reduction: ${reduction}%"
    else
        echo "  Failed to optimize $input_file"
        rm -f "$output_file"
    fi
}

# Find and optimize all MP4 files
find "$VIDEO_DIR" -name "*.mp4" -not -name "*_optimized.mp4" | while read -r video_file; do
    optimize_video "$video_file"
done

echo ""
echo "Video optimization complete!"
echo ""
echo "To use optimized videos, update your HTML to point to the *_optimized.mp4 files"
echo "or run the replacement script that will be created next."