#!/bin/bash
# Mark the GNOME desktop as never-kill for systemd-oomd.
#
# Ubuntu's user@.service has oomd kill something in the session once memory
# pressure is above 50% for 20s. It picks by reclaim activity, not size, and has
# picked init.scope (the user's systemd), which logs you out. With
# ManagedOOMPreference=omit on the desktop's units, only apps can be picked.
#
# Re-run after a GNOME upgrade adds new session services.
set -euo pipefail
dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
session="/sys/fs/cgroup/user.slice/user-$(id -u).slice/user@$(id -u).service/session.slice"

units=(init.scope org.gnome.Shell@.service gnome-session-manager@.service
       gnome-session-monitor.service gnome-terminal-server.service)
for u in "$session"/*.service; do
  u=$(basename "$u")
  [[ $u == org.gnome.Shell@* ]] || units+=("$u")
done

for u in "${units[@]}"; do
  sec=Service; [[ $u == *.scope ]] && sec=Scope
  mkdir -p "$dir/$u.d"
  printf '# Written by memory-guard/protect-desktop.sh: never let systemd-oomd kill the desktop.\n[%s]\nManagedOOMPreference=omit\n' \
    "$sec" > "$dir/$u.d/50-oomd-omit.conf"
done
systemctl --user daemon-reload
echo "Protected ${#units[@]} desktop units from systemd-oomd."
