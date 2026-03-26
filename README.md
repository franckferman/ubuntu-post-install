<div align="center">

# ubuntu-post-install

**A bash script that automates the setup of a fresh Ubuntu installation — system hardening, GNOME configuration, developer tooling, privacy settings, and optional third-party software.**

[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)](ubuntu-post-install.sh)
[![License](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](LICENSE)

</div>

Designed for personal workstations and security-conscious desktops. Idempotent where possible: safe to run more than once, skips what is already done.

---

## Table of contents

- [Requirements](#requirements)
- [Quick start](#quick-start)
- [How it works](#how-it-works)
- [Steps](#steps)
- [All options](#all-options)
  - [General](#general)
  - [Display and desktop](#display-and-desktop)
  - [Firewall](#firewall)
  - [System hardening](#system-hardening)
  - [Power and peripherals](#power-and-peripherals)
  - [Applications](#applications)
  - [Firefox](#firefox)
  - [Editor (Vim / Neovim)](#editor-vim--neovim)
  - [Zsh and terminal](#zsh-and-terminal)
  - [Extras](#extras)
- [Extras catalog](#extras-catalog)
  - [Groups](#groups)
  - [Individual extras](#individual-extras)
- [Examples](#examples)
- [Environment variables](#environment-variables)

---

## Requirements

- Ubuntu 22.04 or 24.04 (desktop or server, amd64)
- A user account with `sudo` access
- Internet connection (most steps require it)
- `curl` and `git` available (usually present on a fresh install)

The script will not run as root directly. It calls `sudo` internally where needed and keeps a background `sudo -v` refresh loop alive for the duration of the run.

---

## Quick start

```bash
# Download
curl -O https://raw.githubusercontent.com/franckferman/ubuntu-post-install/stable/ubuntu-post-install.sh

# Review before running (always a good idea)
less ubuntu-post-install.sh

# Run with defaults
bash ubuntu-post-install.sh

# Common desktop setup: dark theme, performance, devops tools
bash ubuntu-post-install.sh --theme dark --power-profile performance --extras devops,signal

# Privacy-focused machine
bash ubuntu-post-install.sh \
  --theme dark \
  --extras privacy \
  --firefox-profiles main \
  --firefox-hardened-profiles main

# Minimal install, steps 1-5 only
bash ubuntu-post-install.sh --apps-profile minimal --steps 1-5
```

---

## How it works

The script runs 15 steps in sequence. Each step is a self-contained function. Steps can be run individually or in combination with `--steps`. The global option order does not matter — all flags are parsed before execution begins.

Before the first apt operation, the script checks that no other package manager (apt, dpkg, synaptic, packagekit) is running. If one is found, it exits cleanly rather than failing mid-operation.

A `sudo` keepalive loop runs in the background throughout execution so that long-running steps do not prompt for a password mid-flight. The loop is killed on exit.

Ctrl+C (SIGINT) and SIGTERM are trapped: the script prints elapsed time and exits with code 130 instead of leaving the system in an inconsistent state.

Output uses emoji symbols by default (`✅ ➡️ ⚠️ ❌`). Pass `--no-emojis` to get plain text (`[+] [=] [!] [x]`) for logging or CI environments.

---

## Steps

Steps can be selectively run with `--steps`. Examples: `--steps 4`, `--steps 1-5`, `--steps 1,3,7-10`.

| # | Name | What it does |
|---|------|-------------|
| 1 | System update | `apt update`, `full-upgrade`, `autoclean`, `autoremove` |
| 2 | Firewall | Installs and configures ufw / nftables / iptables with hardened or transparent profile |
| 3 | System settings | GNOME preferences: theme, privacy, audio, power, night light, keyboard layouts, dock |
| 4 | System hardening | Locks root account, installs USBGuard, stops and masks risky services, removes legacy packages |
| 5 | Basic apps | Installs APT packages (profile-driven), Snap packages, Mullvad VPN |
| 6 | Firefox profiles | Creates Firefox profiles, applies arkenfox user.js, installs extensions |
| 7 | Vim config | Installs vim-plug, gruvbox theme, NERDTree, vim-airline (or minimal/bare preset) |
| 8 | LazyVim | Installs Neovim + LazyVim starter distribution |
| 9 | Nerd Fonts | Downloads the latest Nerd Fonts release from GitHub, installs to `~/.local/share/fonts` |
| 10 | Oh My Zsh | Unattended Oh My Zsh installation |
| 11 | Zsh customization | Powerlevel10k theme + autosuggestions, syntax-highlighting, completions plugins |
| 12 | Zsh plugins update | Extended Zsh plugin set |
| 13 | Zsh aliases | Writes a custom alias block to `.zshrc` |
| 14 | Powerlevel10k config | Applies a bundled p10k preset, with optional custom segment overrides |
| 15 | Extra software | Installs extras specified with `--extras` (third-party APT repos + packages) |

---

## All options

### General

| Flag | Default | Description |
|------|---------|-------------|
| `-h`, `--help` | — | Print help and exit |
| `--no-emojis` | off | Use plain text symbols instead of emoji |
| `--steps <spec>` | all | Run only specific steps. Accepts: `1`, `1,2,4`, `2-8`, `1,3-12` |

### Display and desktop

| Flag | Default | Description |
|------|---------|-------------|
| `--theme <mode>` | `dark` | Color scheme: `dark`, `light`, `auto` (reads system preference) |
| `--gtk-theme <name>` | auto | Override GTK theme. See full list below |
| `--bg-color <#rrggbb>` | `#000000` (dark) | Desktop background color. Example: `--bg-color '#1a1a2e'` |
| `--dock-icon-size <n>` | `42` | Dash-to-Dock icon size in pixels, 16–128 |
| `--keep-recent-files` | off | Keep GNOME recent files history (disabled by default for privacy) |
| `--enable-remote-desktop` | off | Keep RDP and VNC services enabled |
| `--no-hidden-files` | off | Hide dotfiles in Nautilus (shown by default) |
| `--enable-spellcheck` | off | Enable spellcheck in GNOME Text Editor |
| `--terminal-profile-name <n>` | `root` | GNOME Terminal profile name |

**GTK theme names:** `Yaru`, `Yaru-dark`, `Yaru-red`, `Yaru-red-dark`, `Yaru-blue`, `Yaru-blue-dark`, `Yaru-green`, `Yaru-green-dark`, `Yaru-orange`, `Yaru-orange-dark`, `Yaru-purple`, `Yaru-purple-dark`, `Yaru-sage`, `Yaru-sage-dark`, `Adwaita`, `Adwaita-dark`, `HighContrast`, `HighContrastInverse`.

### Firewall

| Flag | Default | Description |
|------|---------|-------------|
| `--firewall <engine>` | `ufw` | Firewall engine: `ufw`, `nftables`, `iptables` |
| `--firewall-profile <p>` | `hardened` | `hardened` (drop all incoming) or `transparent` (allow all) |
| `--allow-ssh` | off | Open port 22 in hardened profile. Has no effect in transparent profile |

`hardened` drops all inbound connections and allows all outbound + established/related traffic. `transparent` is a passthrough — useful on trusted LANs or for testing.

### System hardening

Hardening follows CIS Ubuntu Benchmark recommendations. The `--hardening-profile` sets what is preserved by default. All individual flags override the profile.

| Flag | Default | Description |
|------|---------|-------------|
| `--hardening-profile <p>` | `desktop` | See profiles below |
| `--keep-avahi` | off | Keep avahi-daemon (mDNS/zeroconf). CIS 2.2.2 |
| `--keep-cups` | off | Keep CUPS printing service. CIS 2.2.4 |
| `--no-lock-root` | off | Skip locking the root account. CIS 5.4.2 |
| `--no-usbguard` | off | Skip USBGuard installation |
| `--no-harden-services` | off | Skip stopping and masking risky services |
| `--no-harden-packages` | off | Skip removing legacy/insecure packages |
| `--skip-services <list>` | — | Comma-separated services to keep when hardening is active |
| `--skip-packages <list>` | — | Comma-separated packages to keep when hardening is active |

**Hardening profiles:**

- `desktop` — Maximum hardening. All non-essential services disabled. Suited for personal workstations and privacy-sensitive machines.
- `enterprise` — Conservative. Preserves services common in corporate environments: CUPS, avahi, Samba, NFS, postfix, snmpd, rsync, ldap-utils.
- `server` — Server-oriented. Preserves: apache2, bind9, slapd, dovecot, postfix, squid, snmpd, rsync, NFS. Root lock and USBGuard disabled by default (intended for VPS/headless).

**CIS-referenced services** (can be passed to `--skip-services`): `autofs`, `xinetd`, `avahi-daemon`, `cups`, `slapd`, `nfs-server`, `rpcbind`, `bind9`, `vsftpd`, `apache2`, `smbd`, `dovecot`, `cyrus-imap`, `exim`, `postfix`, `sendmail`, `squid`, `snmpd`, `nis`, `rsync`.

**CIS-referenced packages** (can be passed to `--skip-packages`): `xinetd`, `nis`, `rsh-client`, `talk`, `telnet`, `tftp`, `ldap-utils`.

### Power and peripherals

| Flag | Default | Description |
|------|---------|-------------|
| `--power-profile <p>` | `performance` | `performance`, `balanced`, `power-saver`. Set via `powerprofilesctl` |
| `--allow-suspend` | off | Keep automatic suspend enabled |
| `--no-mute` | off | Keep system audio output unmuted (muted by default) |
| `--keep-mic` | off | Keep microphone input enabled |
| `--no-night-light` | off | Disable Night Light (enabled at sunset by default) |
| `--night-light-temp <K>` | `2700` | Night Light color temperature in Kelvin, 1000–6500 |
| `--keyboard-layouts <l>` | `us` | Comma-separated xkb layout codes. Examples: `us,fr+azerty`, `us,de,fr` |

### Applications

#### APT packages

| Flag | Default | Description |
|------|---------|-------------|
| `--apps-profile <p>` | `default` | Package selection depth |
| `--extra-packages <l>` | — | Comma-separated APT packages to add on top of the profile |
| `--skip-apt-packages <l>` | — | Comma-separated APT packages to remove from the profile list |

**APT profiles:**

- `minimal` — Essentials only: `git`, `curl`, `wget`, `vim`, `zsh`, `tmux`, `python3`, `net-tools`, `unzip`, `fzf`, `ripgrep`, `lsd`.
- `default` — Full list: adds `nala`, `keepassxc`, `zulucrypt-gui`, `mat2`, `rssguard`, `taskwarrior`, `python3-pip`, `python3-venv`, and more.
- `extra` — Default + `firejail` (application sandboxing) + `lynis` (security audit tool).

#### Snap packages

| Flag | Default | Description |
|------|---------|-------------|
| `--no-snap` | off | Skip all Snap installation |
| `--skip-snap-packages <l>` | — | Comma-separated Snaps to skip |

Default Snaps installed: `obsidian` (--classic), `onlyoffice-desktopeditors`. With `--apps-profile extra`: also `xmind` (--classic).

#### Mullvad VPN

| Flag | Default | Description |
|------|---------|-------------|
| `--no-mullvad` | off | Skip Mullvad VPN installation |
| `--mullvad-source <m>` | auto | Install method: `apt`, `direct`, `github` |

Without `--mullvad-source`, the script tries `apt → direct → github` and stops at the first success. With the flag, only that method is used — no fallback.

- `apt` — Official APT repository. Most secure: signature verified on every `apt upgrade`. Persistent repo added.
- `direct` — Downloads the `.deb` directly from mullvad.net. No repo added.
- `github` — GitHub releases (third-party CDN). Last resort.

### Firefox

| Flag | Default | Description |
|------|---------|-------------|
| `--firefox-profiles <l>` | `root` | Comma-separated profile names to create |
| `--firefox-hardened-profiles <l>` | — | Profiles to apply pure arkenfox user.js (max privacy, no overrides) |
| `--firefox-relaxed-profiles <l>` | — | Profiles to apply arkenfox + practical overrides for daily use |
| `--keep-firefox-backup` | off | Keep the profile backup directory after a successful setup |
| `--firefox-extra-extensions` | off | Install extra extensions on top of the defaults |

Both `--firefox-hardened-profiles` and `--firefox-relaxed-profiles` must be subsets of `--firefox-profiles`.

**Default extensions** (all profiles): uBlock Origin, Privacy Badger.

**Extra extensions** (`--firefox-extra-extensions`): ClearURLs, FoxyProxy Standard, Return YouTube Dislikes, Flagfox, CanvasBlocker, Facebook Container, Multi-Account Containers, SponsorBlock, Port Authority, Tab Reloader, View Page Archive.

**Relaxed profile overrides** (arkenfox with usability restored): sessions, WebRTC, DRM/streaming, fonts, form fill, search suggestions, OCSP soft-fail, default downloads directory.

### Editor (Vim / Neovim)

| Flag | Default | Description |
|------|---------|-------------|
| `--editor <mode>` | `both` | `both`, `vim`, `neovim`, `none` |
| `--vim-preset <preset>` | `full` | Vim configuration depth (ignored for `neovim` and `none`) |
| `--vim-colorscheme <name>` | `desert` | Built-in colorscheme for `bare` preset only |

**Editor modes:**
- `both` — Installs Vim config (steps 7) and LazyVim/Neovim (step 8).
- `vim` — Vim only.
- `neovim` — LazyVim only.
- `none` — Skip both.

**Vim presets:**
- `full` — vim-plug + gruvbox + NERDTree + vim-airline + extras. Requires internet.
- `minimal` — gruvbox via native packages + settings. No plugin manager.
- `bare` — Settings only, built-in colorscheme. Zero external dependencies.

**Colorscheme** (bare preset): `desert`, `elflord`, `torte`, `koehler`, `evening`, or any built-in name.

### Zsh and terminal

| Flag | Default | Description |
|------|---------|-------------|
| `--zsh-plugins-profile` | `default` | Plugin set depth (see script internals) |
| `--p10k-preset <p>` | `classic` | Powerlevel10k prompt preset |
| `--no-p10k-custom` | off | Skip custom p10k segment overrides |
| `--p10k-segments` | off | Apply extended segment configuration |

Nerd Fonts (step 9) are required for Powerlevel10k glyphs to render correctly. If step 9 is skipped, use a pre-installed Nerd Font in your terminal emulator.

### Extras

| Flag | Default | Description |
|------|---------|-------------|
| `--extras <list>` | — | Comma-separated extras or groups to install |
| `--skip-extras <list>` | — | Extras to exclude from group expansion |

Installs third-party software via official APT repositories or Snap. Each item sets up the keyring and sources file (idempotent — skipped if already present) then installs the package.

The argument is a comma-separated list of individual names or group names. Groups expand to their members. Duplicates across groups and individual names are deduplicated automatically.

```bash
# Meta-group: everyday dev setup
--extras default

# Atomic group
--extras devops

# Multiple groups
--extras browsers,messaging

# Mix of groups and individuals
--extras microsoft,signal,spotify

# Install everything
--extras all

# Specific tools
--extras docker,gh,vscode

# Group minus specific extras
--extras devops --skip-extras podman,azurecli
--extras messaging --skip-extras telegram
```

---

## Extras catalog

### Groups

**Atomic groups** — install a specific category:

| Group | Members |
|-------|---------|
| `devops` | docker, gh, hashicorp, podman, azurecli |
| `containers` | docker, podman |
| `browsers` | brave, chrome, vivaldi, edge |
| `messaging` | signal, telegram, element, slack, teams |
| `privacy` | protonvpn, brave, signal, element |
| `microsoft` | vscode, azurecli, edge, teams |
| `editors` | vscode, sublime, antigravity |
| `office` | teams, slack, wine |
| `media` | spotify |
| `security` | protonvpn, signal, element |

**Meta-groups** — curated bundles:

| Group | Members | Use case |
|-------|---------|----------|
| `minimal` | docker, gh, vscode, signal | Bare essentials |
| `default` | docker, gh, vscode, brave, signal, telegram, element | Everyday dev setup |
| `all` | Everything in the catalog | Install everything |

### Individual extras

| Key | Package | Method | Notes |
|-----|---------|--------|-------|
| `docker` | docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin | APT | Official Docker repo. Adds `docker.gpg` keyring |
| `gh` | gh | APT | GitHub CLI. Official GitHub repo |
| `brave` | brave-browser | APT | Brave browser. Official Brave repo |
| `signal` | signal-desktop | APT | Signal Desktop. Official Signal repo |
| `telegram` | telegram-desktop | Snap | No official APT repo — installed via Snap |
| `vscode` | code | APT | VS Code. Shares `microsoft.gpg` keyring with azurecli, edge, teams |
| `element` | element-desktop | APT | Element (Matrix client). Official Element repo |
| `protonvpn` | proton-vpn-gnome-desktop | APT | ProtonVPN Linux app. Official Proton repo |
| `podman` | podman | APT | Podman container runtime. Kubic repo |
| `hashicorp` | terraform, vault, packer, consul, nomad | APT | HashiCorp suite. Official HashiCorp repo |
| `spotify` | spotify-client | APT | Spotify. Official Spotify repo |
| `slack` | slack-desktop | APT | Slack. Official Slack repo |
| `chrome` | google-chrome-stable | APT | Google Chrome. Official Google repo |
| `sublime` | sublime-text | APT | Sublime Text. Official Sublime repo |
| `azurecli` | azure-cli | APT | Azure CLI. Shares `microsoft.gpg` keyring |
| `teams` | teams-for-linux | APT | Microsoft Teams for Linux. Shares `microsoft.gpg` keyring |
| `vivaldi` | vivaldi-stable | APT | Vivaldi browser. Official Vivaldi repo |
| `edge` | microsoft-edge-stable | APT | Microsoft Edge. Shares `microsoft.gpg` keyring |
| `wine` | wine, winehq-stable | APT | WineHQ stable. Official WineHQ repo |
| `antigravity` | antigravity | APT | AntiGravity. AI developer tool. Google Cloud APT repo (`/etc/apt/keyrings`) |

**Shared keyring note:** `vscode`, `azurecli`, `edge`, and `teams` all use the same Microsoft signing key (`microsoft.gpg`). The keyring is downloaded once; subsequent Microsoft products reuse it.

---

## Examples

```bash
# Default run — dark theme, performance profile, all 15 steps
bash ubuntu-post-install.sh

# Privacy workstation
bash ubuntu-post-install.sh \
  --theme dark \
  --hardening-profile desktop \
  --extras privacy \
  --firefox-profiles work,personal \
  --firefox-hardened-profiles work \
  --firefox-relaxed-profiles personal

# Development machine — devops tools + VS Code + signal
bash ubuntu-post-install.sh \
  --apps-profile extra \
  --extras devops,vscode,signal \
  --editor both \
  --power-profile performance

# Install all extras
bash ubuntu-post-install.sh --extras all

# Servers / VPS — no GUI, no snaps, no Mullvad, hardening without root lock
bash ubuntu-post-install.sh \
  --hardening-profile server \
  --no-lock-root \
  --no-snap \
  --no-mullvad \
  --steps 1,2,4,5

# Enterprise laptop — preserve CUPS and avahi, conservative hardening
bash ubuntu-post-install.sh \
  --hardening-profile enterprise \
  --keep-avahi \
  --keep-cups \
  --keyboard-layouts us,fr

# Re-run only hardening and apps (e.g. after adding a new machine)
bash ubuntu-post-install.sh --steps 4,5

# CI / logging — no emoji, minimal packages, steps 1 and 4 only
bash ubuntu-post-install.sh \
  --no-emojis \
  --apps-profile minimal \
  --steps 1,4

# Light theme, custom dock size, French + US keyboard, no suspend
bash ubuntu-post-install.sh \
  --theme light \
  --dock-icon-size 48 \
  --keyboard-layouts fr+azerty,us \
  --allow-suspend

# Custom background, custom GTK theme, night light at 3200K
bash ubuntu-post-install.sh \
  --bg-color '#1e1e2e' \
  --gtk-theme Yaru-purple-dark \
  --night-light-temp 3200

# Skip specific packages from the default profile
bash ubuntu-post-install.sh \
  --apps-profile default \
  --skip-apt-packages taskwarrior,rssguard \
  --skip-snap-packages xmind

# Add packages on top of the minimal profile
bash ubuntu-post-install.sh \
  --apps-profile minimal \
  --extra-packages htop,ncdu,jq,bat

# Vim bare preset with a custom colorscheme — no internet needed for editor
bash ubuntu-post-install.sh \
  --editor vim \
  --vim-preset bare \
  --vim-colorscheme torte

# Multiple Firefox profiles: one hardened, one relaxed
bash ubuntu-post-install.sh \
  --firefox-profiles anon,daily \
  --firefox-hardened-profiles anon \
  --firefox-relaxed-profiles daily \
  --firefox-extra-extensions

# UFW transparent profile on a trusted LAN
bash ubuntu-post-install.sh \
  --firewall ufw \
  --firewall-profile transparent

# nftables firewall, SSH allowed
bash ubuntu-post-install.sh \
  --firewall nftables \
  --firewall-profile hardened \
  --allow-ssh

# Mullvad via direct download (no APT repo)
bash ubuntu-post-install.sh --mullvad-source direct

# Skip Mullvad entirely
bash ubuntu-post-install.sh --no-mullvad

# Power saver mode, night light disabled, mic kept on
bash ubuntu-post-install.sh \
  --power-profile power-saver \
  --no-night-light \
  --keep-mic

# Keep recent files, enable remote desktop, unmute audio
bash ubuntu-post-install.sh \
  --keep-recent-files \
  --enable-remote-desktop \
  --no-mute
```

---

## Environment variables

There are no required environment variables. All configuration is done through command-line flags.

The script sets `DEBIAN_FRONTEND=noninteractive` internally during package installation to suppress interactive prompts. Do not set it externally before running the script — it will be overridden.

---

## Author

Franck FERMAN — v2.0.0 — Last updated 2026-03-18
