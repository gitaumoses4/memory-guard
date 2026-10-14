#!/bin/bash
# Remove memory-guard. Leaves the desktop oomd protection in place; delete
# ~/.config/systemd/user/*.d/50-oomd-omit.conf to remove that too.
set -euo pipefail
systemctl --user disable --now memory-guard.service || true
rm -f ~/.local/bin/memory-guard ~/.config/systemd/user/memory-guard.service
systemctl --user daemon-reload
