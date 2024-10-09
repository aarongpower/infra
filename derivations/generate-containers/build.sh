# Create the output directory
mkdir -p $out

containersDir=$1
echo "Building docker-compose containers found in $1"
composeDirs=$(find $containersDir -type f -name 'docker-compose.yml' -exec dirname {} \; | sort -u)

# Create a temporary directory
TMPDIR=$(mktemp -d)

# Show the temp directory
echo "Using temporary directory: $TMPDIR"

echo "{ pkgs, lib, ... }:" > $out/containers.nix
# echo "let" >> $out/containers.nix
# echo "    pkgs = import <nixpkgs> {};" >> $out/containers.nix
# echo "in" >> $out/containers.nix
echo "{" >> $out/containers.nix
echo "  imports = [" >> $out/containers.nix

# Iterate over all directories and convert docker-compose.yml files
for dir in $composeDirs; do
  projectName=$(basename $dir)

  if [ -f "$dir/docker-compose.yml" ]; then
    echo "Processing $dir/docker-compose.yml"

    mkdir $TMPDIR/$projectName
    # Copy docker-compose.yml to the temp directory
    cp "$dir/docker-compose.yml" "$TMPDIR/$projectName/docker-compose.yml"

    # Run compose2nix in the temp directory
    cd "$TMPDIR/$projectName"
    compose2nix -project="$projectName"

    # Move the generated docker-compose.nix to the output directory
    mv "$TMPDIR/$projectName/docker-compose.nix" "$out/$projectName-docker-compose.nix"

    # Add an import statement for this project's docker-compose.nix in containers.nix
    echo "    \"$out/$projectName-docker-compose.nix\"" >> $out/containers.nix
  else
    echo "No docker-compose.yml found in $dir"
  fi
done

echo "  ];" >> $out/containers.nix
echo "}" >> $out/containers.nix

# Clean up the temporary directory
rm -rf "$TMPDIR"
