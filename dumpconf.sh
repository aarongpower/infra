#!/usr/bin/env nix-shell
#! nix-shell -i bash -p xclip

output=$(while IFS= read -r -d '' file; do
    echo "File: $file"
    echo '```'
    cat "$file"
    echo ""
    echo '```'
    echo ""
done < <(find . -type d \( -name .git \) -prune -o -type f \( -name "*.nix" -o -name "*.flake" \) -print0))

echo "$output"
