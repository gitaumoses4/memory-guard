#!/bin/bash
# Install memory-guard for the current user and protect the desktop from oomd.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
mkdir -p ~/.local/bin ~/.config/systemd/user
ln -sf "$here/memory-guard" ~/.local/bin/memory-guard
ln -sf "$here/memory-guard.service" ~/.config/systemd/user/memory-guard.service
"$here/protect-desktop.sh"
systemctl --user daemon-reload
systemctl --user enable --now memory-guard.service
echo "memory-guard is running. Try: memory-guard --test"
