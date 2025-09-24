#!/bin/bash

# Script to check 16KB page size alignment for native libraries
echo "Checking 16KB page size alignment for native libraries..."

# Function to check ELF alignment
check_elf_alignment() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Checking: $file"
        
        # Check if file is ELF
        if file "$file" | grep -q "ELF"; then
            # Use readelf to check section alignment
            readelf -S "$file" 2>/dev/null | grep -E "(LOAD|TEXT|DATA)" | while read line; do
                echo "  $line"
            done
            
            # Check for 16KB alignment (16384 = 0x4000)
            if readelf -S "$file" 2>/dev/null | grep -q "0x4000"; then
                echo "  ✓ 16KB alignment detected"
            else
                echo "  ⚠ No 16KB alignment detected"
            fi
        else
            echo "  Not an ELF file"
        fi
        echo ""
    fi
}

# Check Flutter app.so files
echo "=== Checking Flutter app.so files ==="
find ./build/app/intermediates/flutter -name "app.so" | head -5 | while read file; do
    check_elf_alignment "$file"
done

# Check for any other .so files
echo "=== Checking other .so files ==="
find . -name "*.so" -not -path "./build/app/intermediates/flutter/*" | head -5 | while read file; do
    check_elf_alignment "$file"
done

echo "16KB alignment check completed."
