set dotenv-load

hostname := `hostname`
project_root := justfile_dir()

show_hostname:
    echo "Hostname is {{hostname}}"

show_project_root:
    echo "Project root is {{project_root}}"

fix_pve_stuck: 
    echo "Fixing PVE stuck issue..."
    echo "Killing git index-pack processes..."
    # sudo pkill -f 'git.*index-pack' || true
    echo "Restarting nix-daemon..."
    sudo systemctl restart nix-daemon
    echo "Deleting problematic store paths..."
    sudo nix-store --delete /nix/store/84s8c0n9drynvs6mgb9qq7lv12rh6wpi-pve-qemu-e096998 2>/dev/null || true
    echo "Clearing Nix caches..."
    sudo rm -rf /root/.cache/nix/eval-cache-v5 /root/.cache/nix/git 2>/dev/null || true

deploy:
    git add .
    sudo nixos-rebuild switch --flake {{project_root}}/nix#{{hostname}}
    git commit -m "Deploy to {{hostname}} on `date +'%Y-%m-%d %H:%M:%S'`"
    git push
