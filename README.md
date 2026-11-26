# dotfiles

Steve Beaty's dotfiles: shell config, editor/terminal settings, personal
scripts, and a `fix.sh` that applies the desktop/terminal preferences that
can't live in a plain config file. Targets Linux (Mint/Cinnamon), macOS, and
a Raspberry Pi running labwc/Wayland.

## Install model

This repo is checked out **with `$HOME` as its working tree** — the files live
directly where they belong (`~/.bashrc`, `~/bin/*`, `~/.vimrc`, …). There is
**no symlink or copy step** for the dotfiles themselves. Installing is just:

1. point a git working tree at `$HOME`, then
2. run `fix.sh` to apply the settings that can't live in a tracked file
   (desktop/terminal gsettings, labwc config, macOS key remap, browser
   `userChrome.css`).

## Installing on a new machine

You can't `git clone` into a non-empty directory, so initialise the working
tree in place instead:

```bash
cd ~
git init -b main
git remote add origin https://github.com/drsjb80/dotfiles.git
git fetch --depth 1 origin
git reset --hard origin/main                 # writes the files into ~
git branch --set-upstream-to=origin/main main
```

> **Heads up:** `git reset --hard` overwrites any existing files that collide
> with tracked ones (`.bashrc`, `.vimrc`, …) — that's the intent on a fresh
> machine. Back up anything in `~` you want to keep first.

Then apply the settings and reload your shell:

```bash
~/fix.sh
source ~/.bashrc      # or just open a new terminal
```

## Keeping `git status` sane

Because `$HOME` is the working tree, `git status` would otherwise list every
file in your home directory as untracked. Tell this clone to show only tracked
files:

```bash
git config --local status.showUntrackedFiles no
```

## What `fix.sh` does

Everything in `fix.sh` is guarded and idempotent: it no-ops the settings for
tools you don't have, and re-running it is safe.

- **Linux — Cinnamon / GNOME Terminal:** block cursor, Solarized Light terminal
  theme, 80×44 window, focus-follows-mouse + auto-raise, Caps Lock → Control,
  and a few `<Super>` window keybindings.
- **Raspberry Pi — labwc:** focus-follows-mouse + raise-on-focus in `rc.xml`,
  Caps Lock → Control in `environment` (seeded from the system defaults, then
  patched in place).
- **macOS:** Caps Lock → Control via `hidutil` (for the current login session;
  add a LaunchAgent to make it survive reboots).
- **Firefox / Thunderbird:** copies `userChrome.css` / `TBuserChrome.css` into
  each profile's `chrome/` directory and sets a couple of related prefs.

## Updating later

```bash
cd ~
git pull
~/fix.sh      # only if settings changed
```

## Notable files

| File | What it is |
|------|------------|
| `.bashrc` | interactive-shell setup; sources the two below |
| `.bash_aliases` | all shell aliases |
| `.bash_functions` | all shell functions |
| `.bash_profile` | login-shell setup |
| `.vimrc`, `.screenrc`, `.gtkrc-2.0` | editor / tool config |
| `fix.sh` | applies desktop/terminal settings (see above) |
| `userChrome.css`, `TBuserChrome.css` | Firefox / Thunderbird chrome tweaks |
| `RandomSignature.ini` | copyq command for a random e-mail signature |
| `bin/` | personal scripts |
| `.brews` | Homebrew package list |

## Machine-local overrides

`~/.bashrc_private` is sourced by `.bashrc` if it exists and is **not** tracked
in this repo — put per-machine paths or secrets there.
