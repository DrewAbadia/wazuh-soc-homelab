#!/bin/bash
# cleanup.sh — Docker disk recovery + LVM expansion
#
# Problem this solves:
#   During Wazuh deployment, the root partition (/dev/sda) hit 100% capacity.
#   /var/lib/docker was consuming ~16 GB from pulled images, stopped containers,
#   and build cache accumulated across multiple deployment attempts.
#   Docker operations were failing silently as a result.
#
# What this script does:
#   1. Prunes all unused Docker artifacts (images, containers, volumes, cache)
#   2. Vacuums systemd journal logs down to 50 MB
#   3. Expands the LVM physical volume and logical volume to use all free disk space
#
# WARNING:
#   Step 1 removes ALL unused Docker images and stopped containers.
#   If you have containers you intend to restart, do NOT run docker system prune -a.
#   Review running containers first: docker ps -a
#
# Usage:
#   chmod +x cleanup.sh
#   sudo ./cleanup.sh
#
# Environment this was run in:
#   Ubuntu 22.04 VM on Proxmox VE
#   Disk: /dev/sda (resized from 40GB to 60GB at the Proxmox level first)
#   Volume group: pve  |  Logical volume: /dev/pve/data

set -e  # Exit immediately if any command fails

echo "=== Step 1: Pruning Docker artifacts ==="
echo "This will remove all unused images, stopped containers, and build cache."
docker system prune -a --force
echo "Docker cleanup complete."
echo ""

echo "=== Step 2: Vacuuming systemd journal logs ==="
journalctl --vacuum-size=50M
echo "Journal logs trimmed."
echo ""

echo "=== Step 3: Expanding LVM to use available disk space ==="
echo "Expanding partition 3..."
growpart /dev/sda 3

echo "Resizing physical volume..."
pvresize /dev/sda3

echo "Extending logical volume to 100% of free space..."
lvextend -l +100%FREE /dev/pve/data

echo "Resizing filesystem..."
resize2fs /dev/pve/data

echo ""
echo "=== Done. Checking disk usage ==="
df -h /
echo ""
echo "Recovery complete. Check the output above to confirm free space."
