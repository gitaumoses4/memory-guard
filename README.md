# memory-guard

macOS-style "Force Quit Applications" prompt for Ubuntu/GNOME when memory runs low.

On Ubuntu, `systemd-oomd` kills something in your session when memory pressure stays
above 50% for 20 seconds. It never asks, and it picks by reclaim activity rather than
size, so it can kill the session itself (`init.scope`) and log you out, taking every
open app with it.

memory-guard does two things:

1. **Asks first.** It watches the same pressure signal oomd uses. When pressure passes
   20% for 6 seconds, or RAM plus swap drops under 2 GB, it shows a dialog listing your
   apps by memory use. Tick the ones to close and they're stopped gracefully (SIGTERM,
   so IDEs can save). "Not now" snoozes it for 2 minutes unless pressure keeps rising.
2. **Protects the desktop.** `protect-desktop.sh` marks gnome-shell, gnome-session, the
   user manager, terminal server and every `session.slice` service with
   `ManagedOOMPreference=omit`, so when oomd does act it can only pick an app.

## Install

```sh
./install.sh
memory-guard --test   # show the dialog now
memory-guard --list   # print what it would offer
```

The script and unit are symlinked into `~/.local/bin` and `~/.config/systemd/user`, so
`git pull` updates them. Run `systemctl --user restart memory-guard` afterwards.

Re-run `./protect-desktop.sh` after a GNOME upgrade that adds new session services.

## Tuning

Set these with `systemctl --user edit memory-guard` (`Environment=NAME=value`):

| Variable | Default | Meaning |
|---|---|---|
| `MG_WARN_PRESSURE` | `20` | "full" memory pressure (avg10, %) that counts as high |
| `MG_WARN_SECONDS` | `6` | how long it must stay high before asking |
| `MG_LOW_AVAILABLE_MB` | `2048` | also ask when RAM + swap left drops below this |

## Requirements

GNOME on a systemd distro with cgroup v2 (Ubuntu 22.04+), `zenity`, `notify-send`,
Python 3.8+. No root needed.
