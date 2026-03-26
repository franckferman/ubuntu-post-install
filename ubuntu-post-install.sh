#!/bin/bash

: '
Ubuntu Post-Installation Script

Automates system configuration, hardening, and tooling setup after a fresh Ubuntu install.

Author  : Franck FERMAN
Created : 06/12/2023
Updated : 18/03/2026
Version : 2.0.0
'


# ----------------------------------------------
# URLs
# ----------------------------------------------
URL_OHMYZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
URL_VIM_PLUG="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
URL_POWERLEVEL10K="https://github.com/romkatv/powerlevel10k.git"
URL_PLUGIN_AUTOSUGGESTIONS="https://github.com/zsh-users/zsh-autosuggestions"
URL_PLUGIN_SYNTAX_HIGHLIGHTING="https://github.com/zsh-users/zsh-syntax-highlighting"
URL_PLUGIN_COMPLETIONS="https://github.com/zsh-users/zsh-completions"
URL_MULLVAD="https://mullvad.net/download/app/deb/latest"
URL_MULLVAD_KEYRING="https://repository.mullvad.net/deb/mullvad-keyring.asc"
URL_MULLVAD_REPO="https://repository.mullvad.net/deb/stable"
URL_MULLVAD_GITHUB_API="https://api.github.com/repos/mullvad/mullvadvpn-app/releases/latest"
URL_LAZYVIM="https://github.com/LazyVim/starter"
URL_ARKENFOX="https://raw.githubusercontent.com/arkenfox/user.js/master/user.js"
URL_NERD_FONTS_API="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"

# ----------------------------------------------
# Output Symbols
# ----------------------------------------------
USE_EMOJIS=true
ICON_INFO=""
ICON_OK=""
ICON_SKIP=""
ICON_WARN=""
ICON_ERR=""
SEPARATOR="-----------------------------"
SELECTED_STEPS=""
EDITOR_MODE="both"
VIM_PRESET="full"
COLOR_SCHEME="dark"
VIM_COLORSCHEME="desert"
FIREWALL="ufw"
FIREWALL_PROFILE="hardened"
ALLOW_SSH=false
GTK_THEME=""
BG_COLOR=""
DOCK_ICON_SIZE=42
KEEP_RECENT_FILES=false
ENABLE_REMOTE_DESKTOP=false
MUTE_OUTPUT=true
MUTE_MIC=true
POWER_PROFILE="performance"
ALLOW_SUSPEND=false
NIGHT_LIGHT=true
NIGHT_LIGHT_TEMP=2700
KEYBOARD_LAYOUTS="us"
SHOW_HIDDEN_FILES=true
TERMINAL_PROFILE_NAME="root"
ENABLE_SPELLCHECK=false
HARDENING_PROFILE="desktop"
KEEP_AVAHI=false
KEEP_CUPS=false
LOCK_ROOT=true
INSTALL_USBGUARD=true
HARDEN_SERVICES=true
HARDEN_PACKAGES=true
SKIP_SERVICES=""
SKIP_PACKAGES=""
_LOCK_ROOT_EXPLICIT=false
_USBGUARD_EXPLICIT=false
APPS_PROFILE="default"
EXTRA_PACKAGES=""
SKIP_APT_PACKAGES=""
INSTALL_SNAP=true
SKIP_SNAP_PACKAGES=""
INSTALL_MULLVAD=true
MULLVAD_SOURCE="apt"
_MULLVAD_SOURCE_EXPLICIT=false
FIREFOX_PROFILES="root"
FIREFOX_HARDENED_PROFILES=""
FIREFOX_RELAXED_PROFILES=""
KEEP_FIREFOX_BACKUP=false
FIREFOX_EXTRA_EXTENSIONS=false
NERD_FONTS_PROFILE="default"
CLEAR_BASH_HISTORY=true
ZSH_PLUGINS_PROFILE="default"
P10K_PRESET="classic"
P10K_CUSTOM=true
P10K_SEGMENTS=false
EXTRA_REPOS=""
SKIP_EXTRAS=""

log_section() {
    echo "$SEPARATOR"
    echo "${ICON_INFO} $1"
    echo "$SEPARATOR"
}

_init_symbols() {
    if $USE_EMOJIS; then
        ICON_INFO="ℹ️ "
        ICON_OK="✅"
        ICON_SKIP="➡️ "
        ICON_WARN="⚠️ "
        ICON_ERR="❌"
    else
        ICON_INFO="[*]"
        ICON_OK="[+]"
        ICON_SKIP="[=]"
        ICON_WARN="[!]"
        ICON_ERR="[x]"
    fi
}

show_help() {
    # Print usage information and exit.
    cat << EOF
Ubuntu Post-Installation Script v2.0.0
Automates system configuration, hardening, and tooling setup after a fresh Ubuntu install.

Usage:
  $(basename "$0") [options]

Options:
  -h, --help           Show this help message and exit.
  --no-emojis          Use plain text prefixes instead of emoji output symbols.
  --steps <spec>       Run only the specified steps (default: all).
                       Accepts numbers, ranges, and combinations:
                         --steps 1           Run step 1 only.
                         --steps 1,2,4       Run steps 1, 2, and 4.
                         --steps 2-8         Run steps 2 through 8.
                         --steps 1,3-12      Run step 1 and steps 3 through 12.
  --editor <mode>      Select which editor(s) to install (default: both).
                         both    Install Vim config and LazyVim (Neovim).
                         vim     Install Vim config only.
                         neovim  Install LazyVim only.
                         none    Skip editor installation entirely.
  --firewall <engine>    Firewall engine to configure (default: ufw).
                         ufw          UFW — simple, recommended for desktops.
                         nftables     Native nftables — modern kernel-level firewall.
                         iptables     Legacy iptables — widely known, still supported.
  --firewall-profile <p> Firewall ruleset profile (default: hardened).
                         hardened     Drop all incoming, allow outgoing + established.
                         transparent  Allow all traffic — for testing or trusted networks.
  --allow-ssh            Open port 22 in hardened profile. Use on servers to avoid lockout.
                         No effect in transparent profile.
  --theme <mode>         Color scheme preference (default: dark).
                         dark    Force dark background and dark GTK theme.
                         light   Force light background and light GTK theme.
                         auto    Read current system preference and align to it.
  --gtk-theme <name>    Override GTK theme (default: auto-detected from --theme).
                         Yaru, Yaru-dark, Yaru-red, Yaru-red-dark,
                         Yaru-blue, Yaru-blue-dark, Yaru-green, Yaru-green-dark,
                         Yaru-orange, Yaru-orange-dark, Yaru-purple, Yaru-purple-dark,
                         Yaru-sage, Yaru-sage-dark, Adwaita, Adwaita-dark,
                         HighContrast, HighContrastInverse.
  --bg-color <#rrggbb>  Override desktop background color (default: #000000 dark / #ffffff light).
                         Example: --bg-color '#1a1a2e'
  --dock-icon-size <n>  Dash-to-Dock icon size in pixels, 16–128 (default: 42).
  --keep-recent-files   Keep GNOME recent files history enabled (default: disabled).
  --enable-remote-desktop  Keep RDP and VNC services enabled (default: disabled).
  --no-mute              Keep system audio output unmuted (default: muted).
  --keep-mic             Keep microphone input enabled (default: disabled).
  --power-profile <p>    GNOME power profile (default: performance).
                         performance   Maximum performance.
                         balanced      Balance performance and battery.
                         power-saver   Prioritise battery life.
  --allow-suspend        Keep automatic suspend enabled (default: disabled).
  --no-night-light       Disable Night Light (default: enabled at sunset, 2700K).
  --night-light-temp <K> Night Light colour temperature in Kelvin, 1000–6500 (default: 2700).
  --keyboard-layouts <l> Comma-separated xkb layout codes (default: us).
                         Examples: --keyboard-layouts us,fr+azerty
                                   --keyboard-layouts us,de,fr
  --no-hidden-files      Hide dotfiles in Nautilus and file chooser (default: visible).
  --terminal-profile-name <n>  GNOME Terminal profile name (default: root).
  --enable-spellcheck    Enable spellcheck in GNOME Text Editor (default: disabled).
  --hardening-profile <p> Hardening baseline — sets which services are preserved by default (default: desktop).
                         desktop     Maximum hardening. All non-essential services disabled.
                                     Suited for personal workstations and privacy-sensitive machines.
                         enterprise  Conservative hardening. Preserves services common in corporate
                                     environments: CUPS, avahi, Samba, NFS, postfix, snmpd, rsync.
                                     ldap-utils kept for Active Directory / LDAP queries.
                         server      Server-oriented hardening. Preserves server services: apache2,
                                     bind9, slapd, dovecot, postfix, squid, snmpd, rsync, NFS.
                                     Root lock and USBGuard disabled by default (VPS / headless).
                                     ldap-utils kept.
                         All profiles: --skip-services, --skip-packages, --no-harden-* flags
                         remain available and always take priority over profile defaults.
  --keep-avahi           Keep avahi-daemon enabled (default: disabled — CIS 2.2.2).
  --keep-cups            Keep CUPS printing service enabled (default: disabled — CIS 2.2.4).
  --no-lock-root         Do not lock the root account (default: locked — CIS 5.4.2).
                         Useful on VPS/cloud instances that require root SSH access.
  --no-usbguard          Do not install USBGuard (default: installed).
                         USBGuard blocks unauthorised USB devices at the kernel level.
  --no-harden-services   Skip stopping and masking all risky services (default: hardened).
  --no-harden-packages   Skip removing all legacy/insecure packages (default: hardened).
  --skip-services <list> Comma-separated services to keep even when hardening is active.
                         CIS-referenced services: autofs, xinetd, avahi-daemon, cups,
                         slapd, nfs-server, rpcbind, bind9, vsftpd, apache2, smbd,
                         dovecot, cyrus-imap, exim, postfix, sendmail, squid, snmpd,
                         nis, rsync.
                         Example: --skip-services slapd,bind9
  --skip-packages <list> Comma-separated packages to keep even when hardening is active.
                         CIS-referenced packages: xinetd, nis, rsh-client, talk, telnet,
                         tftp, ldap-utils.
                         Example: --skip-packages telnet,tftp
  --vim-preset <preset>  Vim configuration depth (default: full, ignored if --editor neovim|none).
                         full    vim-plug + gruvbox + NERDTree + airline + extras.
                         minimal gruvbox (native packages) + settings only, no plugin manager.
                         bare    Settings only, built-in colorscheme — zero external dependencies.
  --vim-colorscheme <name>  Built-in vim colorscheme for bare preset (default: desert).
                         Examples: desert, elflord, torte, koehler, evening.
                         Ignored unless --vim-preset bare is set.
  --apps-profile <p>     APT package selection profile (default: default).
                         minimal   Essentials only: git, curl, wget, vim, zsh, tmux, python3, net-tools,
                                   unzip, fzf, ripgrep, lsd.
                         default   Full list: adds nala, keepassxc, zulucrypt-gui, mat2, rssguard,
                                   taskwarrior, python3-pip, python3-venv and more.
                         extra     Default + firejail (app sandboxing) + lynis (security audit).
  --extra-packages <l>   Comma-separated APT packages to add on top of the profile.
                         Example: --extra-packages htop,ncdu,jq
  --extras <l>           Comma-separated extras (individuals and/or groups) to install.
                         Each adds the official APT/snap repo and the package.
                         Groups expand automatically, duplicates are deduplicated.
                         Individuals : docker, gh, brave, signal, telegram, vscode, element,
                                       protonvpn, podman, hashicorp, spotify, slack,
                                       chrome, sublime, azurecli, teams, vivaldi, edge, wine,
                                       antigravity
                         Atomic groups  : browsers, messaging, privacy, editors, devops,
                                          containers, microsoft, office, media, security
                         Meta-groups    : minimal, default, all
                         Example: --extras devops,signal
                                  --extras default
                                  --extras all
                                  --extras docker,gh,signal
  --skip-extras <l>      Comma-separated extras to exclude from a group expansion.
                         Example: --extras devops --skip-extras podman,azurecli
                                  --extras default --skip-extras telegram,wine
  --skip-apt-packages <l> Comma-separated APT packages to remove from the profile list.
                         Example: --skip-apt-packages taskwarrior,rssguard
  --no-snap              Skip all Snap package installation.
  --skip-snap-packages <l> Comma-separated Snap packages to skip (default: xmind obsidian lsd).
                         Example: --skip-snap-packages xmind,obsidian
  --no-mullvad           Skip Mullvad VPN installation.
  --firefox-profiles <l>       Comma-separated Firefox profile names to create (default: root).
                               Example: --firefox-profiles root,nietzsche,schopenhauer
  --firefox-hardened-profiles <l> Apply pure arkenfox user.js with zero overrides (max privacy).
                               Must be a subset of --firefox-profiles.
                               Example: --firefox-hardened-profiles root
  --firefox-relaxed-profiles <l>  Apply arkenfox + practical overrides for daily browsing.
                               Restores: sessions, WebRTC, DRM/streaming, fonts, form fill,
                               search suggestions, OCSP soft-fail, default downloads dir.
                               Must be a subset of --firefox-profiles.
                               Example: --firefox-relaxed-profiles nietzsche
  --keep-firefox-backup        Keep the Firefox profile backup even if setup succeeds.
                               By default: removed on success, preserved on error.
  --firefox-extra-extensions   Install extra Firefox extensions in addition to the defaults.
                               Default (all profiles): uBlock Origin, Privacy Badger.
                               Extra: ClearURLs, FoxyProxy Standard, Return YouTube Dislikes,
                               Flagfox, CanvasBlocker, Facebook Container, Multi-Account Containers,
                               SponsorBlock, Port Authority, Tab Reloader, View Page Archive.
  --mullvad-source <m>   Mullvad install method (default: apt with auto-fallback).
                         apt     Official APT repository — most secure. Signature verified on every
                                 apt operation. Automatic updates via apt upgrade.
                         direct  Direct .deb from mullvad.net — no persistent repo added.
                         github  GitHub releases — third-party CDN, use as last resort.
                         Without this flag: tries apt → direct → github (stops at first success).
                         With this flag: uses the chosen method only — no fallback.

Steps executed:
  1.  System update          (apt update, full-upgrade, autoclean, autoremove)
  2.  Firewall configuration (engine: ufw|nftables|iptables, profile: hardened|transparent)
  3.  System settings        (GNOME theme, privacy, sound, power, display, keyboard...)
  4.  System hardening       (lock root, USBGuard, disable risky services/packages)
  5.  Basic apps             (APT + Snap packages, Mullvad VPN)
  6.  Firefox profiles       (clean profile + custom user.js)
  7.  Vim config             (gruvbox + NERDTree + airline via vim-plug — see --editor)
  8.  LazyVim                (Neovim distribution — see --editor)
  9.  Nerd Fonts             (download from GitHub releases, install to ~/.local/share/fonts)
  10. Oh My Zsh              (unattended install)
  11. Zsh customization      (Powerlevel10k + core plugins)
  12. Zsh plugins update     (extended plugin list)
  13. Zsh aliases update     (custom alias block)
  14. Powerlevel10k config   (apply bundled preset, optional custom overrides)
  15. Extra software         (optional repos + packages — see --extras)

Author : Franck FERMAN
EOF
    exit 0
}

parse_step_selection() {
    # Expand a step specification (e.g. "1,3-5,8") into a sorted list of unique integers.
    # Args:    $1 = step spec string.
    # Returns: space-separated list of step numbers, or exits with code 1 on invalid input.

    local input="$1"
    local -a result=()

    IFS=',' read -ra parts <<< "$input"
    for part in "${parts[@]}"; do
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            if (( start > end )); then
                echo "Invalid range: $part (start must be <= end)."
                exit 1
            fi
            for (( i=start; i<=end; i++ )); do
                result+=("$i")
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            result+=("$part")
        else
            echo "Invalid step specification: '$part'."
            echo "Run '$(basename "$0") --help' for usage."
            exit 1
        fi
    done

    # Sort and deduplicate
    printf '%s\n' "${result[@]}" | sort -nu | tr '\n' ' '
}

parse_args() {
    # Parse script arguments. Supports -h/--help, --no-emojis, --steps, --editor, --vim-preset.
    # Returns: exits with code 1 on unknown argument.

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                ;;
            --no-emojis)
                USE_EMOJIS=false
                ;;
            --steps)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --steps requires a value (e.g. --steps 1,3-5)."
                    exit 1
                fi
                SELECTED_STEPS="$2"
                shift
                ;;
            --editor)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --editor requires a value (both|vim|neovim|none)."
                    exit 1
                fi
                case "$2" in
                    both|vim|neovim|none) EDITOR_MODE="$2" ;;
                    *)
                        echo "Error: invalid --editor value '$2'. Use: both, vim, neovim, none."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --vim-preset)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --vim-preset requires a value (full|minimal|bare)."
                    exit 1
                fi
                case "$2" in
                    full|minimal|bare) VIM_PRESET="$2" ;;
                    *)
                        echo "Error: invalid --vim-preset value '$2'. Use: full, minimal, bare."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --theme)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --theme requires a value (dark|light|auto)."
                    exit 1
                fi
                case "$2" in
                    dark|light|auto) COLOR_SCHEME="$2" ;;
                    *)
                        echo "Error: invalid --theme value '$2'. Use: dark, light, auto."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --vim-colorscheme)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --vim-colorscheme requires a colorscheme name."
                    exit 1
                fi
                VIM_COLORSCHEME="$2"
                shift
                ;;
            --firewall)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firewall requires a value (ufw|nftables|iptables)."
                    exit 1
                fi
                case "$2" in
                    ufw|nftables|iptables) FIREWALL="$2" ;;
                    *)
                        echo "Error: invalid --firewall value '$2'. Use: ufw, nftables, iptables."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --firewall-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firewall-profile requires a value (hardened|transparent)."
                    exit 1
                fi
                case "$2" in
                    hardened|transparent) FIREWALL_PROFILE="$2" ;;
                    *)
                        echo "Error: invalid --firewall-profile value '$2'. Use: hardened, transparent."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --allow-ssh)
                ALLOW_SSH=true
                ;;
            --gtk-theme)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --gtk-theme requires a theme name."
                    exit 1
                fi
                case "$2" in
                    Yaru|Yaru-dark|\
                    Yaru-red|Yaru-red-dark|\
                    Yaru-blue|Yaru-blue-dark|\
                    Yaru-green|Yaru-green-dark|\
                    Yaru-orange|Yaru-orange-dark|\
                    Yaru-purple|Yaru-purple-dark|\
                    Yaru-sage|Yaru-sage-dark|\
                    Adwaita|Adwaita-dark|\
                    HighContrast|HighContrastInverse)
                        GTK_THEME="$2" ;;
                    *)
                        echo "Error: unknown GTK theme '$2'."
                        echo "Valid themes: Yaru, Yaru-dark, Yaru-red, Yaru-red-dark, Yaru-blue, Yaru-blue-dark,"
                        echo "              Yaru-green, Yaru-green-dark, Yaru-orange, Yaru-orange-dark,"
                        echo "              Yaru-purple, Yaru-purple-dark, Yaru-sage, Yaru-sage-dark,"
                        echo "              Adwaita, Adwaita-dark, HighContrast, HighContrastInverse."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --bg-color)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --bg-color requires a hex color (e.g. --bg-color '#1a1a2e')."
                    exit 1
                fi
                if [[ ! "$2" =~ ^#[0-9a-fA-F]{6}$ ]]; then
                    echo "Error: invalid color '$2'. Expected format: #rrggbb (e.g. #1a1a2e)."
                    exit 1
                fi
                BG_COLOR="$2"
                shift
                ;;
            --dock-icon-size)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --dock-icon-size requires an integer (e.g. --dock-icon-size 36)."
                    exit 1
                fi
                if [[ ! "$2" =~ ^[0-9]+$ ]] || (( "$2" < 16 || "$2" > 128 )); then
                    echo "Error: invalid dock icon size '$2'. Expected an integer between 16 and 128."
                    exit 1
                fi
                DOCK_ICON_SIZE="$2"
                shift
                ;;
            --keep-recent-files)
                KEEP_RECENT_FILES=true
                ;;
            --enable-remote-desktop)
                ENABLE_REMOTE_DESKTOP=true
                ;;
            --no-mute)
                MUTE_OUTPUT=false
                ;;
            --keep-mic)
                MUTE_MIC=false
                ;;
            --power-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --power-profile requires a value (performance|balanced|power-saver)."
                    exit 1
                fi
                case "$2" in
                    performance|balanced|power-saver) POWER_PROFILE="$2" ;;
                    *)
                        echo "Error: invalid --power-profile value '$2'. Use: performance, balanced, power-saver."
                        exit 1
                        ;;
                esac
                shift
                ;;
            --allow-suspend)
                ALLOW_SUSPEND=true
                ;;
            --no-night-light)
                NIGHT_LIGHT=false
                ;;
            --keyboard-layouts)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --keyboard-layouts requires a comma-separated list (e.g. us,fr+azerty)."
                    exit 1
                fi
                KEYBOARD_LAYOUTS="$2"
                shift
                ;;
            --no-hidden-files)
                SHOW_HIDDEN_FILES=false
                ;;
            --terminal-profile-name)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --terminal-profile-name requires a name."
                    exit 1
                fi
                TERMINAL_PROFILE_NAME="$2"
                shift
                ;;
            --enable-spellcheck)
                ENABLE_SPELLCHECK=true
                ;;
            --keep-avahi)
                KEEP_AVAHI=true
                ;;
            --keep-cups)
                KEEP_CUPS=true
                ;;
            --hardening-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --hardening-profile requires a value (desktop|enterprise|server)."
                    exit 1
                fi
                case "$2" in
                    desktop|enterprise|server) HARDENING_PROFILE="$2" ;;
                    *) echo "Error: invalid --hardening-profile value '$2'. Use: desktop, enterprise, server."; exit 1 ;;
                esac
                shift
                ;;
            --no-lock-root)
                LOCK_ROOT=false
                _LOCK_ROOT_EXPLICIT=true
                ;;
            --no-usbguard)
                INSTALL_USBGUARD=false
                _USBGUARD_EXPLICIT=true
                ;;
            --no-harden-services)
                HARDEN_SERVICES=false
                ;;
            --no-harden-packages)
                HARDEN_PACKAGES=false
                ;;
            --skip-services)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-services requires a comma-separated list (e.g. slapd,bind9)."
                    exit 1
                fi
                SKIP_SERVICES="$2"
                shift
                ;;
            --skip-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-packages requires a comma-separated list (e.g. telnet,tftp)."
                    exit 1
                fi
                SKIP_PACKAGES="$2"
                shift
                ;;
            --night-light-temp)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --night-light-temp requires a value in Kelvin (1000–6500)."
                    exit 1
                fi
                if [[ ! "$2" =~ ^[0-9]+$ ]] || (( "$2" < 1000 || "$2" > 6500 )); then
                    echo "Error: invalid temperature '$2'. Expected an integer between 1000 and 6500."
                    exit 1
                fi
                NIGHT_LIGHT_TEMP="$2"
                shift
                ;;
            --apps-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --apps-profile requires a value (minimal|default|extra)."
                    exit 1
                fi
                case "$2" in
                    default|minimal|extra) APPS_PROFILE="$2" ;;
                    *) echo "Error: invalid --apps-profile value '$2'. Use: default, minimal, extra."; exit 1 ;;
                esac
                shift
                ;;
            --extra-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --extra-packages requires a comma-separated list (e.g. htop,ncdu)."
                    exit 1
                fi
                EXTRA_PACKAGES="$2"
                shift
                ;;
            --extras)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --extras requires a comma-separated list (e.g. docker,gh,brave)."
                    exit 1
                fi
                EXTRA_REPOS="$2"
                shift
                ;;
            --skip-apt-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-apt-packages requires a comma-separated list (e.g. taskwarrior,rssguard)."
                    exit 1
                fi
                SKIP_APT_PACKAGES="$2"
                shift
                ;;
            --skip-extras)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-extras requires a comma-separated list (e.g. podman,azurecli)."
                    exit 1
                fi
                SKIP_EXTRAS="$2"
                shift
                ;;
            --no-snap)
                INSTALL_SNAP=false
                ;;
            --skip-snap-packages)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --skip-snap-packages requires a comma-separated list (e.g. xmind,obsidian)."
                    exit 1
                fi
                SKIP_SNAP_PACKAGES="$2"
                shift
                ;;
            --no-mullvad)
                INSTALL_MULLVAD=false
                ;;
            --mullvad-source)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --mullvad-source requires a value (apt|direct|github)."
                    exit 1
                fi
                case "$2" in
                    apt|direct|github) MULLVAD_SOURCE="$2"; _MULLVAD_SOURCE_EXPLICIT=true ;;
                    *) echo "Error: invalid --mullvad-source value '$2'. Use: apt, direct, github."; exit 1 ;;
                esac
                shift
                ;;
            --firefox-profiles)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firefox-profiles requires a comma-separated list of profile names."
                    exit 1
                fi
                FIREFOX_PROFILES="$2"
                shift
                ;;
            --firefox-hardened-profiles)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firefox-hardened-profiles requires a comma-separated list."
                    exit 1
                fi
                FIREFOX_HARDENED_PROFILES="$2"
                shift
                ;;
            --firefox-relaxed-profiles)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --firefox-relaxed-profiles requires a comma-separated list."
                    exit 1
                fi
                FIREFOX_RELAXED_PROFILES="$2"
                shift
                ;;
            --keep-firefox-backup)
                KEEP_FIREFOX_BACKUP=true
                ;;
            --firefox-extra-extensions)
                FIREFOX_EXTRA_EXTENSIONS=true
                ;;
            --nerd-fonts-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --nerd-fonts-profile requires a value (default|extra)."
                    exit 1
                fi
                case "$2" in
                    default|extra) NERD_FONTS_PROFILE="$2" ;;
                    *) echo "Error: invalid --nerd-fonts-profile value '$2'. Use: default, extra."; exit 1 ;;
                esac
                shift
                ;;
            --keep-bash-history)
                CLEAR_BASH_HISTORY=false
                ;;
            --zsh-plugins-profile)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --zsh-plugins-profile requires a value (minimal|default|full)."
                    exit 1
                fi
                case "$2" in
                    minimal|default|full) ZSH_PLUGINS_PROFILE="$2" ;;
                    *) echo "Error: invalid --zsh-plugins-profile value '$2'. Use: minimal, default, full."; exit 1 ;;
                esac
                shift
                ;;
            --p10k-preset)
                if [[ -z "$2" || "$2" == --* ]]; then
                    echo "Error: --p10k-preset requires a value (classic|lean|lean-8colors|rainbow|pure|robbyrussell)."
                    exit 1
                fi
                case "$2" in
                    classic|lean|lean-8colors|rainbow|pure|robbyrussell) P10K_PRESET="$2" ;;
                    *) echo "Error: invalid --p10k-preset value '$2'. Use: classic, lean, lean-8colors, rainbow, pure, robbyrussell."; exit 1 ;;
                esac
                shift
                ;;
            --no-p10k-custom)
                P10K_CUSTOM=false
                ;;
            --p10k-segments)
                P10K_SEGMENTS=true
                ;;
            *)
                echo "Unknown argument: $1"
                echo "Run '$(basename "$0") --help' for usage."
                exit 1
                ;;
        esac
        shift
    done
    _init_symbols

    # Resolve --theme auto → read current system preference
    if [[ "$COLOR_SCHEME" == "auto" ]]; then
        local sys
        sys=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)
        [[ "$sys" == *"dark"* ]] && COLOR_SCHEME="dark" || COLOR_SCHEME="light"
    fi
}

_check_apt_lock() {
    local procs=(apt apt-get dpkg synaptic packagekit)
    for p in "${procs[@]}"; do
        if pgrep -x "$p" &>/dev/null; then
            echo "${ICON_ERR} '$p' is already running. Stop it first and re-run the script."
            exit 1
        fi
    done
}


require_admin_rights() {
    # Verify sudo privileges, keep session alive via background refresh loop,
    # and register a trap to clean up the background process on exit.

    _check_apt_lock

    # ---[ Step 1: Initial sudo access check ]---
    # Prompt for sudo access. Exit if user cannot elevate privileges.
    if ! sudo -v; then
        echo "${ICON_ERR} This script requires administrative privileges. Please run it as a user with sudo rights."
        exit 1
    fi

    # ---[ Step 2: Keep sudo session alive in background ]---
    # Launch a background loop to refresh sudo timestamp every 60 seconds.
    # This prevents sudo from timing out during long script execution.
    while true; do
        sudo -n true      # Refresh sudo timestamp without prompting for password
        sleep 60
    done 2>/dev/null &

    # ---[ Step 3: Register cleanup trap ]---
    # Store the PID of the background process and kill it on any exit
    # (normal completion, error, or Ctrl+C / SIGTERM).
    local sudo_refresh_pid=$!
    trap "kill '$sudo_refresh_pid' 2>/dev/null" EXIT
}


show_banner() {
    # Print ASCII art banner at script startup.

    # ---[ Display ASCII art banner ]---
    # Decorative header to indicate script start.
    cat << "EOF"
     ,-O
    O(_)) Ubuntu post-install script
     `-O
EOF
}


check_internet_connectivity() {
    # Check internet connectivity by pinging a host (default: 1.1.1.1).
    # Args:    $1 (optional) — host to ping.
    # Returns: 0 if reachable, 1 otherwise.

    # ---[ Define host to ping, defaulting to 1.1.1.1 ]---
    local host="${1:-1.1.1.1}"

    # ---[ Perform ping test ]---
    # -c 2 : Send 2 ICMP packets.
    # -W 5 : Wait up to 5 seconds for a response (per packet).
    # Redirect output to /dev/null for silent operation.
    ping -c 2 -W 5 "$host" > /dev/null 2>&1

    # ---[ Return ping command exit status ]---
    # Return 0 if successful, 1 otherwise.
    return $?
}


perform_system_update() {
    # Run apt update, full-upgrade, autoclean, and autoremove if internet is available.

    log_section "System update process initiated."

    # ---[ Step 1: Check internet connectivity before updating ]---
    if check_internet_connectivity; then
        echo "${ICON_OK} Internet connectivity confirmed. Proceeding with system updates..."

        # ---[ Step 2: Update package lists ]---
        echo "${ICON_OK} Updating package lists (apt update)..."
        sudo apt update

        # ---[ Step 3: Upgrade all packages ]---
        echo "${ICON_OK} Upgrading all packages (apt full-upgrade)..."
        sudo apt full-upgrade -y

        # ---[ Step 4: Clean up partial and unnecessary files ]---
        echo "${ICON_OK} Cleaning up package cache (apt autoclean)..."
        sudo apt autoclean -y

        # ---[ Step 5: Remove unused packages and dependencies ]---
        echo "${ICON_OK} Removing unused packages (apt autoremove)..."
        sudo apt autoremove -y

        echo "${ICON_OK} System update process completed successfully."
    else
        echo "${ICON_WARN} Skipping system update: No internet connection detected."
    fi

    echo "$SEPARATOR"
}


_fw_disable_all() {
    # Disable UFW, stop nftables service, flush iptables and ip6tables to a clean accept-all state.

    if command -v ufw &>/dev/null; then
        echo "${ICON_OK} Disabling UFW..."
        sudo ufw --force disable 2>/dev/null || true
    fi

    if systemctl is-active --quiet nftables 2>/dev/null; then
        echo "${ICON_OK} Stopping nftables service..."
        sudo systemctl stop nftables
        sudo systemctl disable nftables
    fi

    if command -v iptables &>/dev/null; then
        echo "${ICON_OK} Flushing iptables (IPv4) rules..."
        sudo iptables -F
        sudo iptables -X
        sudo iptables -Z
        sudo iptables -P INPUT ACCEPT
        sudo iptables -P FORWARD ACCEPT
        sudo iptables -P OUTPUT ACCEPT
    fi

    if command -v ip6tables &>/dev/null; then
        echo "${ICON_OK} Flushing ip6tables (IPv6) rules..."
        sudo ip6tables -F
        sudo ip6tables -X
        sudo ip6tables -Z
        sudo ip6tables -P INPUT ACCEPT
        sudo ip6tables -P FORWARD ACCEPT
        sudo ip6tables -P OUTPUT ACCEPT
    fi
}

_fw_ufw_hardened() {
    # UFW: deny incoming, allow outgoing, optionally allow SSH.

    if ! command -v ufw &>/dev/null; then
        echo "${ICON_OK} Installing UFW..."
        sudo apt install -y ufw
    fi

    sudo ufw --force reset
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    if $ALLOW_SSH; then
        echo "${ICON_OK} Adding SSH allow rule (port 22)..."
        sudo ufw allow ssh
    fi
    sudo ufw --force enable
    echo "${ICON_INFO} UFW status:"
    sudo ufw status verbose
}

_fw_ufw_transparent() {
    # UFW: allow all incoming and outgoing.

    if ! command -v ufw &>/dev/null; then
        echo "${ICON_OK} Installing UFW..."
        sudo apt install -y ufw
    fi

    sudo ufw --force reset
    sudo ufw default allow incoming
    sudo ufw default allow outgoing
    sudo ufw --force enable
    echo "${ICON_INFO} UFW status:"
    sudo ufw status verbose
}

_fw_iptables_hardened() {
    # iptables + ip6tables: DROP INPUT/FORWARD, ACCEPT OUTPUT, allow established + loopback + ICMP/ICMPv6.

    if ! command -v iptables &>/dev/null; then
        echo "${ICON_OK} Installing iptables..."
        sudo apt install -y iptables
    fi

    # ---[ IPv4 rules ]---
    echo "${ICON_OK} Applying IPv4 hardened rules..."
    sudo iptables -F
    sudo iptables -X
    sudo iptables -Z
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT ACCEPT

    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
    sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

    if $ALLOW_SSH; then
        echo "${ICON_OK} Adding SSH allow rule for IPv4 (port 22)..."
        sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
    fi

    # ---[ IPv6 rules ]---
    echo "${ICON_OK} Applying IPv6 hardened rules..."
    sudo ip6tables -F
    sudo ip6tables -X
    sudo ip6tables -Z
    sudo ip6tables -P INPUT DROP
    sudo ip6tables -P FORWARD DROP
    sudo ip6tables -P OUTPUT ACCEPT

    sudo ip6tables -A INPUT -i lo -j ACCEPT
    sudo ip6tables -A OUTPUT -o lo -j ACCEPT
    sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
    # ICMPv6 ping
    sudo ip6tables -A INPUT -p icmpv6 --icmpv6-type echo-request -j ACCEPT
    # ICMPv6 neighbor discovery (required for IPv6 to function)
    sudo ip6tables -A INPUT -p icmpv6 --icmpv6-type 133 -j ACCEPT  # Router Solicitation
    sudo ip6tables -A INPUT -p icmpv6 --icmpv6-type 134 -j ACCEPT  # Router Advertisement
    sudo ip6tables -A INPUT -p icmpv6 --icmpv6-type 135 -j ACCEPT  # Neighbor Solicitation
    sudo ip6tables -A INPUT -p icmpv6 --icmpv6-type 136 -j ACCEPT  # Neighbor Advertisement

    if $ALLOW_SSH; then
        echo "${ICON_OK} Adding SSH allow rule for IPv6 (port 22)..."
        sudo ip6tables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
    fi

    # ---[ Persist both rulesets ]---
    if ! command -v netfilter-persistent &>/dev/null; then
        echo "${ICON_OK} Installing iptables-persistent..."
        sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
    fi
    sudo netfilter-persistent save
    echo "${ICON_INFO} iptables/ip6tables rules saved (rules.v4 + rules.v6)."
}

_fw_iptables_transparent() {
    # iptables + ip6tables: ACCEPT all — no restrictions on IPv4 or IPv6.

    if ! command -v iptables &>/dev/null; then
        echo "${ICON_OK} Installing iptables..."
        sudo apt install -y iptables
    fi

    echo "${ICON_OK} Applying IPv4 transparent rules..."
    sudo iptables -F
    sudo iptables -X
    sudo iptables -Z
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P OUTPUT ACCEPT

    echo "${ICON_OK} Applying IPv6 transparent rules..."
    sudo ip6tables -F
    sudo ip6tables -X
    sudo ip6tables -Z
    sudo ip6tables -P INPUT ACCEPT
    sudo ip6tables -P FORWARD ACCEPT
    sudo ip6tables -P OUTPUT ACCEPT

    if command -v netfilter-persistent &>/dev/null; then
        sudo netfilter-persistent save
    fi
    echo "${ICON_INFO} iptables/ip6tables set to transparent (accept all)."
}

_fw_nftables_hardened() {
    # nftables: drop input/forward, accept output, allow established + loopback + ICMP.

    if ! command -v nft &>/dev/null; then
        echo "${ICON_OK} Installing nftables..."
        sudo apt install -y nftables
    fi

    local ssh_rule=""
    if $ALLOW_SSH; then
        echo "${ICON_OK} Adding SSH allow rule (port 22)..."
        ssh_rule="        tcp dport 22 ct state new accept"
    fi

    sudo tee /etc/nftables.conf > /dev/null << NFTEOF
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        ct state established,related accept
        ct state invalid drop
        icmp type echo-request accept
        icmpv6 type { echo-request, nd-neighbor-solicit, nd-neighbor-advert, nd-router-solicit, nd-router-advert } accept
${ssh_rule}
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
NFTEOF

    sudo systemctl enable --now nftables
    sudo systemctl restart nftables
    echo "${ICON_INFO} nftables rules applied."
}

_fw_nftables_transparent() {
    # nftables: accept all — no restrictions.

    if ! command -v nft &>/dev/null; then
        echo "${ICON_OK} Installing nftables..."
        sudo apt install -y nftables
    fi

    sudo tee /etc/nftables.conf > /dev/null << 'NFTEOF'
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy accept;
    }
    chain forward {
        type filter hook forward priority 0; policy accept;
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
NFTEOF

    sudo systemctl enable --now nftables
    sudo systemctl restart nftables
    echo "${ICON_INFO} nftables set to transparent (accept all)."
}

configure_firewall() {
    # Configure the selected firewall engine with the selected profile.

    log_section "Starting firewall configuration (engine: $FIREWALL, profile: $FIREWALL_PROFILE)."

    # ---[ Step 1: Disable all active firewalls before switching ]---
    _fw_disable_all

    # ---[ Step 2: Apply selected engine + profile ]---
    case "${FIREWALL}:${FIREWALL_PROFILE}" in
        ufw:hardened)          _fw_ufw_hardened          ;;
        ufw:transparent)       _fw_ufw_transparent       ;;
        iptables:hardened)     _fw_iptables_hardened     ;;
        iptables:transparent)  _fw_iptables_transparent  ;;
        nftables:hardened)     _fw_nftables_hardened     ;;
        nftables:transparent)  _fw_nftables_transparent  ;;
    esac

    echo "$SEPARATOR"
}


set_gsetting() {
    # Set a gsettings key only if the current value differs.
    # Args: $1 = key, $2 = value.

    local key=$1
    local value=$2
    local current_value

    echo "${ICON_INFO} Processing gsetting for key: $key"

    # ---[ Step 1: Get the current value of the gsettings key ]---
    current_value=$(gsettings get $key 2> /dev/null)

    # ---[ Step 2: Check if the key exists ]---
    if [ $? -ne 0 ]; then
        echo "${ICON_WARN} The key $key does not exist."
        return
    fi

    # ---[ Step 3: Update the key if necessary ]---
    if [ "$current_value" != "$value" ]; then
        echo "${ICON_OK} Setting $key to $value."

        # Handle numeric values without quotes, otherwise quote strings
        if [[ "$value" =~ ^[0-9]+$ ]]; then
            gsettings set $key $value
        else
            gsettings set $key "$value"
        fi
    else
        echo "${ICON_SKIP} $key is already set to $value."
    fi
}


configure_theme() {
    # Apply GNOME color scheme and GTK theme based on COLOR_SCHEME (dark or light).

    log_section "Starting GNOME theme configuration."

    # ---[ Step 1: Apply color scheme preference ]---
    echo "${ICON_OK} Applying ${COLOR_SCHEME} color scheme..."
    if [[ "$COLOR_SCHEME" == "dark" ]]; then
        set_gsetting "org.gnome.desktop.interface color-scheme" "'prefer-dark'"
    else
        set_gsetting "org.gnome.desktop.interface color-scheme" "'prefer-light'"
    fi

    # ---[ Step 2: Apply GTK theme ]---
    local themes
    themes=$(ls -d /usr/share/themes/* 2>/dev/null | xargs -L 1 basename)

    if [[ -z "$themes" ]]; then
        echo "${ICON_WARN} No GTK themes found. Skipping theme setup."
    elif [[ -n "$GTK_THEME" ]]; then
        # User specified a theme — check it's installed then apply
        if echo "$themes" | grep -qx "$GTK_THEME"; then
            echo "${ICON_OK} Applying user-specified theme '$GTK_THEME'."
            set_gsetting "org.gnome.desktop.interface gtk-theme" "'$GTK_THEME'"
        else
            echo "${ICON_WARN} Theme '$GTK_THEME' not installed. Falling back to auto-detection."
            GTK_THEME=""
        fi
    fi

    if [[ -z "$GTK_THEME" && -n "$themes" ]]; then
        # Auto-detect based on COLOR_SCHEME
        echo "${ICON_INFO} Auto-detecting GTK theme for ${COLOR_SCHEME} mode..."
        if [[ "$COLOR_SCHEME" == "dark" ]]; then
            if echo "$themes" | grep -qx "Yaru-red-dark"; then
                echo "${ICON_OK} Applying 'Yaru-red-dark' theme."
                set_gsetting "org.gnome.desktop.interface gtk-theme" "'Yaru-red-dark'"
            elif echo "$themes" | grep -qx "Adwaita-dark"; then
                echo "${ICON_OK} Applying fallback 'Adwaita-dark' theme."
                set_gsetting "org.gnome.desktop.interface gtk-theme" "'Adwaita-dark'"
            else
                echo "${ICON_WARN} No suitable dark theme found. Theme remains unchanged."
            fi
        else
            if echo "$themes" | grep -qx "Yaru-red"; then
                echo "${ICON_OK} Applying 'Yaru-red' theme."
                set_gsetting "org.gnome.desktop.interface gtk-theme" "'Yaru-red'"
            elif echo "$themes" | grep -qx "Yaru"; then
                echo "${ICON_OK} Applying 'Yaru' theme."
                set_gsetting "org.gnome.desktop.interface gtk-theme" "'Yaru'"
            elif echo "$themes" | grep -qx "Adwaita"; then
                echo "${ICON_OK} Applying fallback 'Adwaita' theme."
                set_gsetting "org.gnome.desktop.interface gtk-theme" "'Adwaita'"
            else
                echo "${ICON_WARN} No suitable light theme found. Theme remains unchanged."
            fi
        fi
    fi

    # ---[ Step 3: Set desktop background color ]---
    local bg_color
    if [[ -n "$BG_COLOR" ]]; then
        bg_color="$BG_COLOR"
        echo "${ICON_INFO} Setting custom background color ${bg_color}..."
    elif [[ "$COLOR_SCHEME" == "dark" ]]; then
        bg_color="#000000"
        echo "${ICON_INFO} Setting solid black as desktop background..."
    else
        bg_color="#ffffff"
        echo "${ICON_INFO} Setting solid white as desktop background..."
    fi

    for key in primary-color secondary-color; do
        if gsettings writable org.gnome.desktop.background "$key" > /dev/null 2>&1; then
            echo "${ICON_OK} Setting $key to $bg_color."
            set_gsetting "org.gnome.desktop.background $key" "'$bg_color'"
        else
            echo "${ICON_WARN} Cannot write to $key. Skipping."
        fi
    done

    # Clear picture-uri and picture-uri-dark to ensure no background image
    for key in picture-uri picture-uri-dark; do
        if gsettings writable org.gnome.desktop.background "$key" > /dev/null 2>&1; then
            echo "${ICON_OK} Clearing $key (no background image)."
            set_gsetting "org.gnome.desktop.background $key" "''"
        else
            echo "${ICON_WARN} Cannot write to $key. Skipping."
        fi
    done

    echo "${ICON_INFO} GNOME theme configuration completed."
    echo "$SEPARATOR"
}


configure_ubuntu_desktop() {
    # Configure Dock and icon placement: top-left icons, disable panel mode, set icon size.

    log_section "Starting Ubuntu desktop configuration."

    # ---[ Step 1: Set new icons placement ]---
    echo "${ICON_OK} Setting new icons to appear at the top-left corner."
    set_gsetting "org.gnome.shell.extensions.ding start-corner" "'top-left'"

    # ---[ Step 2: Disable panel mode (Dash to Dock) ]---
    echo "${ICON_OK} Disabling panel mode (Dash to Dock)."
    set_gsetting "org.gnome.shell.extensions.dash-to-dock extend-height" false

    # ---[ Step 3: Set Dash to Dock icon size ]---
    echo "${ICON_OK} Setting Dash to Dock icon size to ${DOCK_ICON_SIZE}."
    set_gsetting "org.gnome.shell.extensions.dash-to-dock dash-max-icon-size" "$DOCK_ICON_SIZE"

    echo "${ICON_INFO} Ubuntu desktop configuration completed."
    echo "$SEPARATOR"
}


configure_privacy_settings() {
    # Harden GNOME privacy: disable location, reporting, remote desktop, and minimize data retention.

    log_section "Starting privacy configuration."

    # ---[ Step 1: Disable connectivity checking ]---
    echo "${ICON_OK} Disabling connectivity checking."
    busctl --system set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled "b" 0

    # ---[ Step 2: Configure screen lock and session idle settings ]---
    echo "${ICON_OK} Configuring screen lock settings."
    set_gsetting "org.gnome.desktop.screensaver lock-enabled" true
    set_gsetting "org.gnome.desktop.screensaver lock-delay" "uint32 0"
    set_gsetting "org.gnome.desktop.screensaver idle-activation-enabled" true
    set_gsetting "org.gnome.desktop.session idle-delay" "uint32 300"

    # ---[ Step 3: Disable location services ]---
    echo "${ICON_OK} Disabling location services."
    set_gsetting "org.gnome.system.location enabled" false

    # ---[ Step 4: Configure file history and recent files settings ]---
    if $KEEP_RECENT_FILES; then
        echo "${ICON_OK} Keeping recent files history enabled."
        set_gsetting "org.gnome.desktop.privacy remember-recent-files" true
    else
        echo "${ICON_OK} Disabling recent files history."
        # Enable first so GNOME accepts the max-age write, then disable.
        set_gsetting "org.gnome.desktop.privacy remember-recent-files" true
        set_gsetting "org.gnome.desktop.privacy recent-files-max-age" 1
        set_gsetting "org.gnome.desktop.privacy remember-recent-files" false
    fi

    # ---[ Step 5: Enable automatic cleanup of old files ]---
    echo "${ICON_OK} Enabling automatic removal of old trash and temporary files."
    set_gsetting "org.gnome.desktop.privacy remove-old-trash-files" true
    set_gsetting "org.gnome.desktop.privacy remove-old-temp-files" true

    echo "${ICON_OK} Setting old files age to 0 (immediate cleanup)."
    set_gsetting "org.gnome.desktop.privacy old-files-age" "uint32 0"

    # ---[ Step 6: Disable technical reports and usage stats ]---
    echo "${ICON_OK} Disabling technical problem reports."
    set_gsetting "org.gnome.desktop.privacy report-technical-problems" false

    echo "${ICON_OK} Disabling software usage statistics."
    set_gsetting "org.gnome.desktop.privacy send-software-usage-stats" false

    # ---[ Step 7: Hide user identity ]---
    echo "${ICON_OK} Hiding user identity."
    set_gsetting "org.gnome.desktop.privacy hide-identity" true

    # ---[ Step 8: Remote desktop services (RDP and VNC) ]---
    if $ENABLE_REMOTE_DESKTOP; then
        echo "${ICON_SKIP} Keeping remote desktop services enabled (--enable-remote-desktop)."
    else
        echo "${ICON_OK} Disabling remote desktop services (RDP and VNC)."
        set_gsetting "org.gnome.desktop.remote-desktop.rdp enable" false
        set_gsetting "org.gnome.desktop.remote-desktop.vnc enable" false
    fi

    # ---[ Step 9: Prevent remembering app usage ]---
    echo "${ICON_OK} Disabling remembering app usage."
    set_gsetting "org.gnome.desktop.privacy remember-app-usage" false

    echo "${ICON_INFO} Privacy configuration completed."
    echo "$SEPARATOR"
}


configure_sound_settings() {
    # Mute system audio output and disable microphone input via amixer.

    log_section "Starting sound configuration."

    # ---[ Step 1: Ensure amixer is available ]---
    if ! command -v amixer &>/dev/null; then
        echo "${ICON_WARN} amixer not found. Installing alsa-utils..."
        sudo apt install -y alsa-utils
    fi

    # ---[ Step 2: System output ]---
    if $MUTE_OUTPUT; then
        echo "${ICON_OK} Muting system output (Master)."
        amixer set Master mute
    else
        echo "${ICON_SKIP} Keeping system output unmuted (--no-mute)."
    fi

    # ---[ Step 3: Microphone input ]---
    if $MUTE_MIC; then
        echo "${ICON_OK} Disabling microphone input (Capture)."
        amixer set Capture nocap
    else
        echo "${ICON_SKIP} Keeping microphone enabled (--keep-mic)."
    fi

    echo "${ICON_INFO} Sound configuration completed."
    echo "$SEPARATOR"
}


configure_power_perfs_settings() {
    # Set power profile, configure inactivity timeouts, and manage suspend behaviour.

    log_section "Starting power and performance configuration."

    # ---[ Step 1: Set power profile ]---
    echo "${ICON_OK} Setting power profile to ${POWER_PROFILE}."
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set "${POWER_PROFILE}" || echo "${ICON_WARN} powerprofilesctl failed — power profile not set."
    else
        echo "${ICON_WARN} powerprofilesctl not found — power profile not set."
    fi
    set_gsetting "org.gnome.shell last-selected-power-profile" "'${POWER_PROFILE}'"

    # ---[ Step 2: Enable screen dimming and battery saver ]---
    echo "${ICON_OK} Enabling screen dimming."
    set_gsetting "org.gnome.settings-daemon.plugins.power idle-dim" true

    echo "${ICON_OK} Enabling automatic power saver on low battery."
    set_gsetting "org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery" true

    # ---[ Step 3: Temporarily set suspend mode to allow timeout writes ]---
    # GNOME ignores timeout values when sleep type is 'nothing' — set temporarily then revert.
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type" "'suspend'"
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type" "'suspend'"

    # ---[ Step 4: Set logout delay and sleep timeouts ]---
    echo "${ICON_OK} Setting logout delay to 2 hours."
    set_gsetting "org.gnome.desktop.screensaver logout-delay" "uint32 7200"

    echo "${ICON_OK} Setting sleep inactive timeout to 2 hours (AC and battery)."
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout" 7200
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout" 7200

    # ---[ Step 5: Apply suspend preference ]---
    if $ALLOW_SUSPEND; then
        echo "${ICON_OK} Keeping suspend enabled (--allow-suspend)."
    else
        echo "${ICON_OK} Disabling suspend."
        set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type" "'nothing'"
        set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type" "'nothing'"
    fi

    echo "${ICON_INFO} Power and performance configuration completed."
    echo "$SEPARATOR"
}


configure_display_settings() {
    # Show battery percentage and optionally configure Night Light.

    log_section "Starting display and interface configuration."

    # ---[ Step 1: Enable battery percentage display ]---
    echo "${ICON_OK} Enabling battery percentage display."
    set_gsetting "org.gnome.desktop.interface show-battery-percentage" true

    # ---[ Step 2: Night Light ]---
    if $NIGHT_LIGHT; then
        echo "${ICON_OK} Enabling Night Light (automatic from sunset to sunrise, ${NIGHT_LIGHT_TEMP}K)."
        set_gsetting "org.gnome.settings-daemon.plugins.color night-light-enabled" true
        set_gsetting "org.gnome.settings-daemon.plugins.color night-light-schedule-automatic" true
        set_gsetting "org.gnome.settings-daemon.plugins.color night-light-temperature" "uint32 ${NIGHT_LIGHT_TEMP}"
    else
        echo "${ICON_SKIP} Skipping Night Light (--no-night-light)."
        set_gsetting "org.gnome.settings-daemon.plugins.color night-light-enabled" false
    fi

    echo "${ICON_INFO} Display and interface configuration completed."
    echo "$SEPARATOR"
}


configure_keyboard_settings() {
    # Configure GNOME keyboard layouts from KEYBOARD_LAYOUTS (comma-separated xkb codes).

    log_section "Starting keyboard layout configuration."

    # ---[ Step 1: Build gsettings array from KEYBOARD_LAYOUTS ]---
    local gsettings_array=""
    IFS=',' read -ra layout_list <<< "$KEYBOARD_LAYOUTS"
    for layout in "${layout_list[@]}"; do
        layout="${layout// /}"  # trim spaces
        [[ -n "$gsettings_array" ]] && gsettings_array+=", "
        gsettings_array+="('xkb', '$layout')"
    done
    gsettings_array="[$gsettings_array]"

    echo "${ICON_OK} Applying keyboard layouts: $KEYBOARD_LAYOUTS"

    # ---[ Step 2: Apply layouts ]---
    set_gsetting "org.gnome.desktop.input-sources sources" "$gsettings_array"
    set_gsetting "org.gnome.desktop.input-sources mru-sources" "$gsettings_array"

    echo "${ICON_INFO} Keyboard layout configuration completed."
    echo "$SEPARATOR"
}


configure_calendar_clock_settings() {
    # Show weekday, date, and week numbers in the GNOME clock and calendar.

    log_section "Starting calendar and clock settings configuration."

    # ---[ Step 1: Enable weekday and date display in clock ]---
    echo "${ICON_OK} Enabling weekday display in clock..."
    set_gsetting "org.gnome.desktop.interface clock-show-weekday" true

    echo "${ICON_OK} Enabling date display in clock..."
    set_gsetting "org.gnome.desktop.interface clock-show-date" true

    # ---[ Step 2: Enable week numbers in calendar ]---
    echo "${ICON_OK} Enabling week numbers in calendar..."
    set_gsetting "org.gnome.desktop.calendar show-weekdate" true

    echo "${ICON_INFO} Calendar and clock settings configuration completed."
    echo "$SEPARATOR"
}


configure_file_manager_settings() {
    # Configure Nautilus and FileChooser: tree view, hidden files, context menus, search, and thumbnails.

    log_section "Starting file manager preferences configuration."

    # ---[ Step 1: Sorting and FileChooser preferences ]---
    echo "${ICON_OK} Sorting directories first in file chooser..."
    set_gsetting "org.gtk.Settings.FileChooser sort-directories-first" true
    set_gsetting "org.gtk.gtk4.Settings.FileChooser sort-directories-first" true

    # ---[ Step 2: Nautilus list view options ]---
    echo "${ICON_OK} Enabling tree view in list mode..."
    set_gsetting "org.gnome.nautilus.list-view use-tree-view" true

    # ---[ Step 3: Context menu options ]---
    echo "${ICON_OK} Enabling 'Create Link' in context menu..."
    set_gsetting "org.gnome.nautilus.preferences show-create-link" true

    echo "${ICON_OK} Enabling 'Delete Permanently' in context menu..."
    set_gsetting "org.gnome.nautilus.preferences show-delete-permanently" true

    # ---[ Step 4: Search, thumbnails, and directory item counts ]---
    echo "${ICON_OK} Enabling recursive search, image thumbnails, and directory item counts..."
    set_gsetting "org.gnome.nautilus.preferences recursive-search" "'always'"
    set_gsetting "org.gnome.nautilus.preferences show-image-thumbnails" "'always'"
    set_gsetting "org.gnome.nautilus.preferences show-directory-item-counts" "'always'"

    # ---[ Step 5: Icon view captions ]---
    echo "${ICON_OK} Configuring grid view captions (type, size, permissions)..."
    set_gsetting "org.gnome.nautilus.icon-view captions" "['detailed_type', 'size', 'permissions']"

    # ---[ Step 6: Show hidden files everywhere ]---
    if $SHOW_HIDDEN_FILES; then
        echo "${ICON_OK} Enabling display of hidden files everywhere..."
        set_gsetting "org.gtk.Settings.FileChooser show-hidden" true
        set_gsetting "org.gtk.gtk4.Settings.FileChooser show-hidden" true
        set_gsetting "org.gnome.nautilus.preferences show-hidden-files" true
    else
        echo "${ICON_SKIP} Keeping hidden files invisible (--no-hidden-files)."
    fi

    echo "${ICON_INFO} File manager preferences configuration completed."
    echo "$SEPARATOR"
}


configure_gnome_terminal_settings() {
    # Configure GNOME Terminal: rename profile, set colors based on theme, and apply palette.

    log_section "Starting GNOME Terminal preferences configuration."

    # ---[ Step 1: Retrieve default profile ID ]---
    echo "${ICON_INFO} Retrieving the ID of the default terminal profile..."
    local default_profile
    default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
    default_profile=${default_profile:1:-1}  # Remove leading and trailing single quotes

    local p="/org/gnome/terminal/legacy/profiles:/:${default_profile}"

    # ---[ Step 2: Rename profile ]---
    echo "${ICON_OK} Renaming the default profile to '${TERMINAL_PROFILE_NAME}'..."
    dconf write "${p}/visible-name" "'${TERMINAL_PROFILE_NAME}'"

    # ---[ Step 3: Set colors based on COLOR_SCHEME ]---
    echo "${ICON_OK} Disabling system theme colors..."
    dconf write "${p}/use-theme-colors" false

    if [[ "$COLOR_SCHEME" == "dark" ]]; then
        echo "${ICON_OK} Applying dark terminal colors..."
        dconf write "${p}/foreground-color" "'rgb(208,207,204)'"
        dconf write "${p}/background-color" "'rgb(23,20,33)'"
    else
        echo "${ICON_OK} Applying light terminal colors..."
        dconf write "${p}/foreground-color" "'rgb(23,20,33)'"
        dconf write "${p}/background-color" "'rgb(242,242,242)'"
    fi

    # ---[ Step 4: Disable transparent background ]---
    echo "${ICON_OK} Disabling transparent background."
    dconf write "${p}/use-transparent-background" false

    # ---[ Step 5: Set custom color palette ]---
    echo "${ICON_OK} Setting up the color palette..."
    dconf write "${p}/palette" "['rgb(23,20,33)', 'rgb(192,28,40)', 'rgb(38,162,105)', 'rgb(162,115,76)', 'rgb(18,72,139)', 'rgb(163,71,186)', 'rgb(42,161,179)', 'rgb(208,207,204)', 'rgb(94,92,100)', 'rgb(246,97,81)', 'rgb(51,209,122)', 'rgb(233,173,12)', 'rgb(42,123,222)', 'rgb(192,97,203)', 'rgb(51,199,222)', 'rgb(255,255,255)']"

    echo "${ICON_INFO} GNOME Terminal preferences configuration completed."
    echo "$SEPARATOR"
}


configure_gnome_shell_text_editor_settings() {
    # Set Dock favorites and configure Text Editor (dark theme, line numbers, grid, no spellcheck).

    log_section "Starting GNOME Shell favorites and Text Editor configuration."

    # ---[ Step 1: Configure GNOME Shell favorite applications ]---
    echo "${ICON_OK} Setting favorite applications in GNOME Shell..."
    set_gsetting "org.gnome.shell favorite-apps" "['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']"

    # ---[ Step 2: Configure GNOME Text Editor settings ]---
    echo "${ICON_OK} Enabling line numbers in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor show-line-numbers" true

    echo "${ICON_OK} Enabling right margin in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor show-right-margin" true

    echo "${ICON_OK} Applying ${COLOR_SCHEME} theme to GNOME Text Editor..."
    if [[ "$COLOR_SCHEME" == "dark" ]]; then
        set_gsetting "org.gnome.TextEditor style-variant" "'dark'"
        set_gsetting "org.gnome.TextEditor style-scheme" "'classic-dark'"
    else
        set_gsetting "org.gnome.TextEditor style-variant" "'light'"
        set_gsetting "org.gnome.TextEditor style-scheme" "'classic'"
    fi

    echo "${ICON_OK} Enabling grid pattern and line highlight in Text Editor..."
    set_gsetting "org.gnome.TextEditor highlight-current-line" true
    set_gsetting "org.gnome.TextEditor show-grid" true

    if $ENABLE_SPELLCHECK; then
        echo "${ICON_OK} Enabling spellcheck in GNOME Text Editor..."
        set_gsetting "org.gnome.TextEditor spellcheck" true
    else
        echo "${ICON_OK} Disabling spellcheck in GNOME Text Editor..."
        set_gsetting "org.gnome.TextEditor spellcheck" false
    fi

    echo "${ICON_OK} Enabling text wrapping in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor wrap-text" true

    echo "${ICON_INFO} GNOME Shell favorites and Text Editor configuration completed."
    echo "$SEPARATOR"
}


configure_system_settings() {
    # Orchestrate all GNOME/Ubuntu configuration functions in order.

    log_section "Starting system settings configuration."

    # ---[ Step 1: Theme and appearance ]---
    configure_theme
    configure_ubuntu_desktop

    # ---[ Step 2: Privacy and security ]---
    configure_privacy_settings

    # ---[ Step 3: System sound and performance ]---
    configure_sound_settings
    configure_power_perfs_settings

    # ---[ Step 4: Display, keyboard, and clock ]---
    configure_display_settings
    configure_keyboard_settings
    configure_calendar_clock_settings

    # ---[ Step 5: File manager and GNOME apps ]---
    configure_file_manager_settings
    configure_gnome_terminal_settings
    configure_gnome_shell_text_editor_settings

    echo "${ICON_INFO} All system settings configurations completed."
    echo "$SEPARATOR"
}


disable_service() {
    # Stop, disable, and mask a systemd service.
    # mask prevents restart by any means (socket activation, dependencies, manual start).
    # Args: $1 = service name.

    local service="$1"

    echo "${ICON_OK} Ensuring $service is stopped and masked..."

    # ---[ Step 1: Stop if currently active ]---
    if sudo systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "${ICON_OK} Stopping $service..."
        sudo systemctl stop "$service" 2>/dev/null || true
    fi

    # ---[ Step 2: Mask (implies disable) — prevents any future start ]---
    # systemctl mask creates a /dev/null symlink, stronger than disable alone.
    # is-masked returns 0 if already masked → skip to avoid noisy output.
    if sudo systemctl is-enabled "$service" 2>/dev/null | grep -q "masked"; then
        echo "${ICON_SKIP} $service is already masked."
    else
        sudo systemctl mask "$service" 2>/dev/null || true
        echo "${ICON_OK} $service stopped, disabled, and masked."
    fi
}


remove_package() {
    # Remove a package with --purge if installed.
    # Args: $1 = package name.

    local package="$1"

    echo "${ICON_OK} Ensuring $package is not installed..."

    # ---[ Step 1: Check if package is installed ]---
    if dpkg -s "$package" &>/dev/null; then
        # ---[ Step 2: Remove the package if present ]---
        echo "${ICON_OK} Removing $package..."
        sudo apt remove --purge -y "$package"
    else
        echo "${ICON_SKIP} $package is already not installed."
    fi
}


configure_hardening() {
    # Harden the system per CIS Ubuntu 22.04 Benchmark (Level 1).
    # Reference: https://www.cisecurity.org/benchmark/ubuntu_linux

    log_section "Starting system hardening configuration."

    # ---[ Profile: apply baseline defaults ]---
    # Profile sets sensible defaults per context; explicit CLI flags always win.
    # desktop   = max hardening (all risky services off, root locked, USBGuard on)
    # enterprise = keep corporate services (CUPS, Samba, NFS, avahi, postfix, snmpd, rsync)
    # server     = keep server services (apache2, bind9, slapd, postfix, squid, etc.)
    #              and disable root lock + USBGuard (no physical access on VPS)
    echo "${ICON_INFO} Applying hardening profile: ${HARDENING_PROFILE}"

    local -a profile_keep_services=()
    local keep_ldap_utils=false

    case "$HARDENING_PROFILE" in
        enterprise)
            profile_keep_services=(
                avahi-daemon    # office printer/device discovery
                cups            # printing
                cups-browsed    # CUPS network browsing
                smbd            # Windows file sharing (Samba)
                nfs-server      # NFS shared storage
                rpcbind         # required by NFS
                rsync           # backups/sync
                snmpd           # monitoring (Nagios, Zabbix...)
                postfix         # local mail delivery for cron/alerts
                exim            # alternative MTA
                sendmail        # alternative MTA
            )
            keep_ldap_utils=true  # needed to query AD/LDAP
            ;;
        server)
            profile_keep_services=(
                slapd           # LDAP server
                nfs-server      # NFS file server
                rpcbind         # required by NFS
                bind9           # DNS server
                apache2         # web server
                dovecot         # IMAP/POP3 server
                cyrus-imap      # alternative IMAP server
                postfix         # MTA / local mail
                exim            # alternative MTA
                sendmail        # alternative MTA
                squid           # HTTP proxy/gateway
                snmpd           # monitoring
                rsync           # backups/sync
            )
            keep_ldap_utils=true  # LDAP client tools useful on servers
            # Server profile: no physical console → root lock and USBGuard off by default
            # (overridable: pass --no-lock-root / --no-usbguard explicitly to confirm intent)
            $_LOCK_ROOT_EXPLICIT  || LOCK_ROOT=false
            $_USBGUARD_EXPLICIT   || INSTALL_USBGUARD=false
            ;;
        desktop|*)
            # Maximum hardening — nothing kept by default.
            ;;
    esac

    # ---[ Step 1: Lock root account ]---
    # CIS 5.4.2 — Ensure root is not directly accessible.
    if $LOCK_ROOT; then
        echo "${ICON_OK} Locking root account..."
        sudo passwd -l root  # Re-enable with: sudo passwd -u root
    else
        echo "${ICON_SKIP} Skipping root lock (--no-lock-root)."
    fi

    # ---[ Step 2: Install security tools ]---
    if $INSTALL_USBGUARD; then
        if check_internet_connectivity; then
            echo "${ICON_OK} Installing USBGuard (USB device whitelisting)..."
            sudo apt install -y usbguard
        else
            echo "${ICON_WARN} No internet connection. Skipping USBGuard installation."
        fi
    else
        echo "${ICON_SKIP} Skipping USBGuard installation (--no-usbguard)."
    fi

    # ---[ Step 3: Disable unnecessary and risky services ]---
    # Each entry references the CIS Ubuntu 22.04 Level 1 control number.
    if ! $HARDEN_SERVICES; then
        echo "${ICON_SKIP} Skipping service hardening (--no-harden-services)."
    else
        echo "${ICON_INFO} Disabling unnecessary services..."

        # Build skip-list from --skip-services
        local -a skip_services=()
        if [[ -n "$SKIP_SERVICES" ]]; then
            IFS=',' read -ra skip_services <<< "$SKIP_SERVICES"
        fi

        _should_skip_service() {
            local svc="$1"
            # CLI --skip-services takes priority
            for s in "${skip_services[@]}"; do
                [[ "${s// /}" == "$svc" ]] && return 0
            done
            # Profile-based keep list
            for s in "${profile_keep_services[@]}"; do
                [[ "$s" == "$svc" ]] && return 0
            done
            return 1
        }

        local services=(
            autofs      # CIS 1.1.23  — auto-mount (prevents removable media auto-mount)
            xinetd      # CIS 2.2.1   — legacy inetd super-server
            slapd       # CIS 2.2.6   — LDAP server
            nfs-server  # CIS 2.2.7   — NFS server
            rpcbind     # CIS 2.2.8   — RPC portmapper
            bind9       # CIS 2.2.9   — DNS server
            vsftpd      # CIS 2.2.10  — FTP server
            apache2     # CIS 2.2.11  — HTTP server
            smbd        # CIS 2.2.12  — Samba file sharing
            dovecot     # CIS 2.2.13  — IMAP/POP3 server
            cyrus-imap  # CIS 2.2.13  — IMAP server (alternative)
            exim        # CIS 2.2.14  — mail transfer agent
            postfix     # CIS 2.2.15  — mail transfer agent
            sendmail    # CIS 2.2.15  — mail transfer agent
            squid       # CIS 2.2.16  — HTTP proxy server
            snmpd       # CIS 2.2.17  — SNMP server
            nis         # CIS 2.2.18  — NIS/YP server
            rsync       # CIS 2.2.21  — rsync daemon
        )
        for service in "${services[@]}"; do
            if _should_skip_service "$service"; then
                echo "${ICON_SKIP} Skipping $service (--skip-services)."
            else
                disable_service "$service"
            fi
        done

        # CIS 2.2.2 — avahi-daemon — skippable via --keep-avahi or --skip-services
        if $KEEP_AVAHI || _should_skip_service "avahi-daemon"; then
            echo "${ICON_SKIP} Keeping avahi-daemon enabled."
        else
            disable_service "avahi-daemon"
        fi

        # CIS 2.2.4 — CUPS — skippable via --keep-cups or --skip-services
        if $KEEP_CUPS || _should_skip_service "cups"; then
            echo "${ICON_SKIP} Keeping CUPS enabled."
        else
            disable_service "cups"          # CIS 2.2.4
            disable_service "cups-browsed"  # CIS 2.2.4 — CUPS network browsing daemon
        fi
    fi

    # ---[ Step 4: Remove unnecessary and insecure packages ]---
    if ! $HARDEN_PACKAGES; then
        echo "${ICON_SKIP} Skipping package hardening (--no-harden-packages)."
    else
        echo "${ICON_INFO} Removing unnecessary and insecure packages..."

        # Build skip-list from --skip-packages
        local -a skip_packages=()
        if [[ -n "$SKIP_PACKAGES" ]]; then
            IFS=',' read -ra skip_packages <<< "$SKIP_PACKAGES"
        fi

        _should_skip_package() {
            local pkg="$1"
            for p in "${skip_packages[@]}"; do
                [[ "${p// /}" == "$pkg" ]] && return 0
            done
            return 1
        }

        local packages=(
            xinetd            # CIS 2.2.1  — legacy inetd super-server
            nis               # CIS 2.3.1  — NIS/YP client (obsolete, insecure auth)
            rsh-client        # CIS 2.3.2  — remote shell client (cleartext)
            rsh-redone-client # CIS 2.3.2  — rsh replacement (still insecure)
            talk              # CIS 2.3.4  — talk client (cleartext communication)
            telnet            # CIS 2.3.5  — telnet client (cleartext auth)
            tftp              # CIS 2.3.6  — TFTP client (no auth, cleartext)
        )
        for package in "${packages[@]}"; do
            if _should_skip_package "$package"; then
                echo "${ICON_SKIP} Skipping $package (--skip-packages)."
            else
                remove_package "$package"
            fi
        done

        # CIS 2.3.7 — ldap-utils: removed on desktop; kept on enterprise/server for AD/LDAP queries.
        if $keep_ldap_utils || _should_skip_package "ldap-utils"; then
            echo "${ICON_SKIP} Keeping ldap-utils (profile: ${HARDENING_PROFILE})."
        else
            remove_package "ldap-utils"
        fi
    fi

    echo "${ICON_INFO} System hardening completed."
    echo "$SEPARATOR"
}


install_deb_from_url() {
    # Download and install a .deb package from a URL, with dependency fix and cleanup.
    # Args:    $1 = URL to .deb file.
    # Returns: 0 on success, 1 on failure.

    local url="$1"
    local tmp_deb

    log_section "Attempting to install .deb package from URL: $url"

    # ---[ Step 1: Check Internet Connectivity ]---
    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connectivity. Skipping installation from $url."
        echo "$SEPARATOR"
        return 1
    fi

    echo "${ICON_OK} Internet connectivity confirmed. Downloading package..."

    # ---[ Step 2: Download the .deb Package ]---
    tmp_deb=$(mktemp --suffix=.deb)
    if ! curl -fsSL "$url" -o "$tmp_deb"; then
        echo "${ICON_WARN} Failed to download $url. Skipping."
        rm -f "$tmp_deb"
        echo "$SEPARATOR"
        return 1
    fi
    echo "${ICON_OK} Package downloaded to temporary file."

    # ---[ Step 3: Install the .deb Package ]---
    echo "${ICON_OK} Installing package..."
    if sudo dpkg -i "$tmp_deb"; then
        echo "${ICON_OK} Package installed successfully."
    else
        echo "${ICON_WARN} dpkg reported errors. Attempting to fix dependencies..."
        if ! sudo apt install -f -y; then
            echo "${ICON_ERR} Dependency fix failed. Installation incomplete."
            rm -f "$tmp_deb"
            echo "$SEPARATOR"
            return 1
        fi
    fi

    # ---[ Step 4: Cleanup ]---
    rm -f "$tmp_deb"
    echo "${ICON_OK} Temporary file removed."
    echo "$SEPARATOR"
}


_mullvad_apt() {
    # Install Mullvad via official APT repository.
    # Signature verified on every apt operation — most secure method.
    echo "${ICON_OK} Adding Mullvad APT repository..."
    local keyring="/usr/share/keyrings/mullvad-keyring.asc"
    local sources="/etc/apt/sources.list.d/mullvad.list"

    if ! sudo curl -fsSLo "$keyring" "$URL_MULLVAD_KEYRING"; then
        echo "${ICON_ERR} Failed to download Mullvad keyring."
        return 1
    fi
    echo "deb [signed-by=${keyring} arch=$(dpkg --print-architecture)] ${URL_MULLVAD_REPO} stable main" \
        | sudo tee "$sources" > /dev/null
    if ! sudo apt update; then
        echo "${ICON_ERR} Failed to update APT after adding Mullvad repo."
        sudo rm -f "$keyring" "$sources"
        return 1
    fi
    if ! sudo apt install -y mullvad-vpn; then
        echo "${ICON_ERR} Failed to install mullvad-vpn via APT."
        return 1
    fi
    echo "${ICON_OK} Mullvad VPN installed via APT repository."
}

_mullvad_direct() {
    # Install Mullvad via direct .deb from mullvad.net/download.
    echo "${ICON_OK} Installing Mullvad VPN from mullvad.net..."
    if ! install_deb_from_url "$URL_MULLVAD"; then
        echo "${ICON_ERR} Failed to install Mullvad via direct download."
        return 1
    fi
}

_mullvad_github() {
    # Install Mullvad via GitHub releases.
    echo "${ICON_OK} Resolving latest Mullvad release from GitHub API..."
    local gh_url
    gh_url=$(curl -fsSL "$URL_MULLVAD_GITHUB_API" \
        | grep -o '"browser_download_url": "[^"]*_amd64\.deb"' \
        | grep -o 'https://[^"]*' \
        | head -1)

    if [[ -z "$gh_url" ]]; then
        echo "${ICON_ERR} Could not resolve Mullvad .deb URL from GitHub API."
        return 1
    fi
    echo "${ICON_INFO} Resolved: $gh_url"
    if ! install_deb_from_url "$gh_url"; then
        echo "${ICON_ERR} Failed to install Mullvad via GitHub."
        return 1
    fi
}

install_mullvad() {
    # Dispatch Mullvad install based on MULLVAD_SOURCE.
    # If source was explicitly set via CLI: try that method only, no fallback.
    # If default (apt): try apt → direct → github in order of security.

    if dpkg -s mullvad-vpn &>/dev/null; then
        echo "${ICON_SKIP} Mullvad VPN is already installed. Skipping."
        return 0
    fi

    if $_MULLVAD_SOURCE_EXPLICIT; then
        # User explicitly chose a method — respect it, no fallback.
        echo "${ICON_INFO} Mullvad install method: ${MULLVAD_SOURCE} (explicit, no fallback)."
        case "$MULLVAD_SOURCE" in
            apt)    _mullvad_apt    ;;
            direct) _mullvad_direct ;;
            github) _mullvad_github ;;
        esac
    else
        # Default: try each method in order of security, stop on first success.
        echo "${ICON_INFO} Mullvad install method: auto (apt → direct → github)."
        if _mullvad_apt; then
            return 0
        fi
        echo "${ICON_WARN} APT method failed. Falling back to direct download..."
        if _mullvad_direct; then
            return 0
        fi
        echo "${ICON_WARN} Direct download failed. Falling back to GitHub..."
        if _mullvad_github; then
            return 0
        fi
        echo "${ICON_ERR} All Mullvad install methods failed."
        return 1
    fi
}


install_basic_apps() {
    # Install APT and Snap packages, and Mullvad VPN if not already present.

    log_section "Starting basic application installation."

    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connection. Skipping package installation."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 1: Build APT package list from profile ]---
    local -a apt_packages=()
    case "$APPS_PROFILE" in
        minimal)
            echo "${ICON_INFO} Apps profile: minimal."
            apt_packages=(
                git curl wget vim zsh tmux python3 net-tools
                unzip fzf ripgrep lsd build-essential
            )
            ;;
        extra)
            echo "${ICON_INFO} Apps profile: extra."
            apt_packages=(
                nala zulucrypt-gui keepassxc vim git curl wget tmux mat2 rssguard
                python3 python3-pip python3-venv zsh taskwarrior net-tools
                unzip fzf ripgrep lsd build-essential
                firejail lynis cmake gdb
                # Optional GNOME apps (uncomment if needed):
                # gnome-software gnome-shell-extension-manager gnome-tweaks
                # hicolor-icon-theme gnome-menus desktop-file-utils gnome-maps
                # gnome-weather gnome-calendar gnome-clocks
            )
            ;;
        default|*)
            echo "${ICON_INFO} Apps profile: default."
            apt_packages=(
                nala zulucrypt-gui keepassxc vim git curl wget tmux mat2 rssguard
                python3 python3-pip python3-venv zsh taskwarrior net-tools
                unzip fzf ripgrep lsd build-essential
                # Optional GNOME apps (uncomment if needed):
                # gnome-software gnome-shell-extension-manager gnome-tweaks
                # hicolor-icon-theme gnome-menus desktop-file-utils gnome-maps
                # gnome-weather gnome-calendar gnome-clocks
            )
            ;;
    esac

    # Append --extra-packages
    if [[ -n "$EXTRA_PACKAGES" ]]; then
        IFS=',' read -ra _extra <<< "$EXTRA_PACKAGES"
        for pkg in "${_extra[@]}"; do
            apt_packages+=( "${pkg// /}" )
        done
    fi

    # Remove --skip-apt-packages entries
    if [[ -n "$SKIP_APT_PACKAGES" ]]; then
        local -a _skip_apt=()
        IFS=',' read -ra _skip_apt <<< "$SKIP_APT_PACKAGES"
        local -a _filtered=()
        for pkg in "${apt_packages[@]}"; do
            local _skip=false
            for s in "${_skip_apt[@]}"; do
                [[ "${s// /}" == "$pkg" ]] && { _skip=true; break; }
            done
            $_skip || _filtered+=( "$pkg" )
        done
        apt_packages=( "${_filtered[@]}" )
    fi

    # ---[ Step 2: Install APT packages ]---
    echo "${ICON_OK} Updating package lists..."
    if ! sudo apt update; then
        echo "${ICON_WARN} apt update failed. Package list may be stale."
    fi
    echo "${ICON_OK} Installing APT packages..."
    sudo apt install -y "${apt_packages[@]}"
    echo "${ICON_OK} APT packages installed."

    # ---[ Step 3: Install Snap packages ]---
    # minimal profile skips snap entirely — profile drives which packages are included.
    if [[ "$APPS_PROFILE" == "minimal" ]]; then
        echo "${ICON_SKIP} Skipping Snap packages (profile: minimal)."
    elif ! $INSTALL_SNAP; then
        echo "${ICON_SKIP} Skipping Snap packages (--no-snap)."
    elif ! command -v snap &>/dev/null; then
        echo "${ICON_WARN} snap is not available. Skipping Snap packages."
    else
        sudo snap refresh

        # Two parallel arrays: names and flags (--classic or empty).
        local snap_names=( obsidian   onlyoffice-desktopeditors )
        local snap_flags=( --classic  ""                        )
        if [[ "$APPS_PROFILE" == "extra" ]]; then
            snap_names+=( xmind    )
            snap_flags+=( --classic )
        fi

        # Build snap skip-list from --skip-snap-packages
        local -a _skip_snap=()
        [[ -n "$SKIP_SNAP_PACKAGES" ]] && IFS=',' read -ra _skip_snap <<< "$SKIP_SNAP_PACKAGES"

        echo "${ICON_OK} Installing Snap packages..."
        local i
        for i in "${!snap_names[@]}"; do
            local pkg="${snap_names[$i]}"
            local flags="${snap_flags[$i]}"
            local _skip=false
            for s in "${_skip_snap[@]}"; do
                [[ "${s// /}" == "$pkg" ]] && { _skip=true; break; }
            done
            if $_skip; then
                echo "${ICON_SKIP} Skipping $pkg (--skip-snap-packages)."
            elif snap list "$pkg" &>/dev/null; then
                echo "${ICON_SKIP} $pkg is already installed (snap). Skipping."
            else
                echo "${ICON_INFO} Installing $pkg..."
                # flags intentionally unquoted — either --classic or empty string.
                # shellcheck disable=SC2086
                sudo snap install "$pkg" $flags
            fi
        done
        echo "${ICON_OK} Snap packages done."
    fi

    # ---[ Step 4: Install Mullvad VPN ]---
    if ! $INSTALL_MULLVAD; then
        echo "${ICON_SKIP} Skipping Mullvad VPN (--no-mullvad)."
    else
        install_mullvad
    fi

    log_section "Basic application installation completed."
}


# ----------------------------------------------
# Extra repositories
# ----------------------------------------------

_add_apt_repo() {
    # Args: <repo_name> <keyring_name> <key_url> <sources_line>
    # Idempotent: skips if sources file already exists.
    # Shared keyrings (e.g. microsoft) are downloaded once and reused.
    local repo_name="$1" key_name="$2" key_url="$3" sources_line="$4"
    local keyring="/usr/share/keyrings/${key_name}.gpg"
    local sources="/etc/apt/sources.list.d/${repo_name}.list"

    if [[ -f "$sources" ]]; then
        echo "${ICON_SKIP} Repo '${repo_name}' already configured."
        return 0
    fi

    if [[ ! -f "$keyring" ]]; then
        echo "${ICON_OK} Fetching keyring '${key_name}'..."
        local tmpkey
        tmpkey=$(mktemp)
        if ! curl -fsSL "$key_url" -o "$tmpkey"; then
            echo "${ICON_ERR} Failed to download key for '${repo_name}'."
            rm -f "$tmpkey"
            return 1
        fi
        if head -c 50 "$tmpkey" | grep -q "BEGIN PGP"; then
            gpg --dearmor < "$tmpkey" | sudo tee "$keyring" > /dev/null
        else
            sudo cp "$tmpkey" "$keyring"
        fi
        rm -f "$tmpkey"
        sudo chmod 644 "$keyring"
    fi

    echo "$sources_line" | sudo tee "$sources" > /dev/null
    echo "${ICON_OK} Repo '${repo_name}' configured."
}

_extra_docker() {
    echo "${ICON_INFO} Docker CE"
    local codename arch
    codename=$(lsb_release -cs)
    arch=$(dpkg --print-architecture)
    _add_apt_repo \
        "docker-ce" "docker-ce" \
        "https://download.docker.com/linux/ubuntu/gpg" \
        "deb [arch=${arch} signed-by=/usr/share/keyrings/docker-ce.gpg] https://download.docker.com/linux/ubuntu ${codename} stable" \
    || return 1
    sudo apt update -qq
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    if [[ -n "$SUDO_USER" ]]; then
        sudo usermod -aG docker "$SUDO_USER"
        echo "${ICON_INFO} Added '$SUDO_USER' to docker group (re-login required)."
    fi
}

_extra_gh() {
    echo "${ICON_INFO} GitHub CLI"
    local arch
    arch=$(dpkg --print-architecture)
    _add_apt_repo \
        "github-cli" "githubcli-archive-keyring" \
        "https://cli.github.com/packages/githubcli-archive-keyring.gpg" \
        "deb [arch=${arch} signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y gh
}

_extra_brave() {
    echo "${ICON_INFO} Brave Browser"
    local arch
    arch=$(dpkg --print-architecture)
    if [[ "$arch" != "amd64" ]]; then
        echo "${ICON_WARN} Brave Browser is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "brave-browser" "brave-browser-archive-keyring" \
        "https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
    || return 1
    printf 'repo_add_once="false"\nrepo_reenable_on_distupgrade="false"\n' | sudo tee /etc/default/brave-browser > /dev/null
    sudo apt update -qq
    sudo apt install -y brave-browser
}

_extra_signal() {
    echo "${ICON_INFO} Signal Desktop"
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} Signal Desktop is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "signal-desktop" "signal-desktop-keyring" \
        "https://updates.signal.org/desktop/apt/keys.asc" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y signal-desktop
}

_extra_vscode() {
    echo "${ICON_INFO} Visual Studio Code"
    local arch
    arch=$(dpkg --print-architecture)
    _add_apt_repo \
        "vscode" "microsoft" \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        "deb [arch=${arch} signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y code
}

_extra_element() {
    echo "${ICON_INFO} Element (Matrix client)"
    local arch
    arch=$(dpkg --print-architecture)
    _add_apt_repo \
        "element-io" "element-io-archive-keyring" \
        "https://packages.riot.im/debian/riot-im-archive-keyring.gpg" \
        "deb [arch=${arch} signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.riot.im/debian/ default main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y element-desktop
}

_extra_protonvpn() {
    echo "${ICON_INFO} ProtonVPN"
    local arch
    arch=$(dpkg --print-architecture)
    if [[ "$arch" != "amd64" ]]; then
        echo "${ICON_WARN} ProtonVPN repo is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "protonvpn-stable" "protonvpn-stable-archive-keyring" \
        "https://repo.protonvpn.com/debian/public_key.asc" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/protonvpn-stable-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y proton-vpn-gnome-desktop
}

_extra_podman() {
    echo "${ICON_INFO} Podman"
    sudo apt update -qq
    sudo apt install -y podman
}

_extra_hashicorp() {
    echo "${ICON_INFO} Hashicorp (Terraform + tools)"
    local codename arch
    codename=$(lsb_release -cs)
    arch=$(dpkg --print-architecture)
    if [[ "$arch" != "amd64" ]]; then
        echo "${ICON_WARN} Hashicorp repo is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "hashicorp" "hashicorp" \
        "https://apt.releases.hashicorp.com/gpg" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com ${codename} main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y terraform
    echo "${ICON_INFO} Other Hashicorp tools available: vault, consul, nomad, packer (same repo)."
}

_extra_spotify() {
    echo "${ICON_INFO} Spotify"
    local arch
    arch=$(dpkg --print-architecture)
    _add_apt_repo \
        "spotify" "spotify-keyring" \
        "https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg" \
        "deb [arch=${arch} signed-by=/usr/share/keyrings/spotify-keyring.gpg] http://repository.spotify.com stable non-free" \
    || return 1
    sudo apt update -qq
    sudo apt install -y spotify-client
}

_extra_slack() {
    echo "${ICON_INFO} Slack"
    local arch
    arch=$(dpkg --print-architecture)
    if [[ "$arch" != "amd64" ]]; then
        echo "${ICON_WARN} Slack repo is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "slack" "slack-archive-keyring" \
        "https://packagecloud.io/slacktechnologies/slack/gpgkey" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/slack-archive-keyring.gpg] https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y slack-desktop
}

_extra_chrome() {
    echo "${ICON_INFO} Google Chrome"
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} Google Chrome is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "google-chrome" "google-chrome" \
        "https://dl.google.com/linux/linux_signing_key.pub" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    || return 1
    for f in google-chrome google-chrome-beta google-chrome-dev; do
        printf 'repo_add_once="false"\nrepo_reenable_on_distupgrade="true"\n' | sudo tee /etc/default/"$f" > /dev/null
    done
    sudo apt update -qq
    sudo apt install -y google-chrome-stable
}

_extra_sublime() {
    echo "${ICON_INFO} Sublime Text"
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} Sublime Text repo is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "sublime-text" "sublime-text" \
        "https://download.sublimetext.com/sublimehq-pub.gpg" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/sublime-text.gpg] https://download.sublimetext.com/ apt/stable/" \
    || return 1
    sudo apt update -qq
    sudo apt install -y sublime-text
}

_extra_azurecli() {
    echo "${ICON_INFO} Azure CLI"
    local codename
    codename=$(lsb_release -cs)
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} Azure CLI repo is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "azure-cli" "microsoft" \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ ${codename} main" \
    || return 1
    sudo apt update -qq
    sudo apt install -y azure-cli
}

_extra_teams() {
    echo "${ICON_INFO} Teams for Linux"
    if ! command -v snap &>/dev/null; then
        echo "${ICON_WARN} snap not available — cannot install teams-for-linux."
        return 1
    fi
    if snap list teams-for-linux &>/dev/null; then
        echo "${ICON_SKIP} teams-for-linux already installed."
        return 0
    fi
    sudo snap install teams-for-linux
}

_extra_vivaldi() {
    echo "${ICON_INFO} Vivaldi Browser"
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} Vivaldi is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "vivaldi" "vivaldi-stable-keyring" \
        "https://repo.vivaldi.com/archive/linux_signing_key.pub" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/vivaldi-stable-keyring.gpg] https://repo.vivaldi.com/archive/deb/ stable main" \
    || return 1
    printf 'repo_add_once="false"\nrepo_reenable_on_distupgrade="false"\n' | sudo tee /etc/default/vivaldi > /dev/null
    sudo apt update -qq
    sudo apt install -y vivaldi-stable
}

_extra_edge() {
    echo "${ICON_INFO} Microsoft Edge"
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} Microsoft Edge is only available for amd64."
        return 1
    fi
    _add_apt_repo \
        "microsoft-edge" "microsoft" \
        "https://packages.microsoft.com/keys/microsoft.asc" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" \
    || return 1
    for f in microsoft-edge microsoft-edge-beta microsoft-edge-dev; do
        printf 'repo_add_once="false"\nrepo_reenable_on_distupgrade="false"\n' | sudo tee /etc/default/"$f" > /dev/null
    done
    sudo apt update -qq
    sudo apt install -y microsoft-edge-stable
}

_extra_telegram() {
    echo "${ICON_INFO} Telegram Desktop"
    if ! command -v snap &>/dev/null; then
        echo "${ICON_WARN} snap not available — cannot install telegram-desktop."
        return 1
    fi
    if snap list telegram-desktop &>/dev/null; then
        echo "${ICON_SKIP} telegram-desktop already installed."
        return 0
    fi
    sudo snap install telegram-desktop
}

_extra_wine() {
    echo "${ICON_INFO} WineHQ"
    if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
        echo "${ICON_WARN} WineHQ is only available for amd64."
        return 1
    fi
    local codename
    codename=$(lsb_release -cs)
    _add_apt_repo \
        "winehq" "wine-hq" \
        "https://dl.winehq.org/wine-builds/winehq.key" \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/wine-hq.gpg] https://dl.winehq.org/wine-builds/ubuntu/ ${codename} main" \
    || return 1
    echo "${ICON_OK} Enabling i386 architecture for WineHQ..."
    if ! sudo dpkg --add-architecture i386; then
        echo "${ICON_WARN} Failed to enable i386 — WineHQ packages may not install correctly."
    fi
    sudo apt update -qq
    sudo apt install -y --install-recommends winehq-stable
}

_extra_antigravity() {
    echo "${ICON_INFO} AntiGravity"
    local keyring="/etc/apt/keyrings/antigravity-repo-key.gpg"
    local sources="/etc/apt/sources.list.d/antigravity.list"

    if [[ -f "$sources" ]]; then
        echo "${ICON_SKIP} Repo 'antigravity' already configured."
    else
        echo "${ICON_OK} Fetching AntiGravity keyring..."
        sudo mkdir -p /etc/apt/keyrings
        local tmpkey
        tmpkey=$(mktemp)
        if ! curl -fsSL "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" -o "$tmpkey"; then
            echo "${ICON_ERR} Failed to download AntiGravity signing key."
            rm -f "$tmpkey"
            return 1
        fi
        if head -c 50 "$tmpkey" | grep -q "BEGIN PGP"; then
            gpg --dearmor < "$tmpkey" | sudo tee "$keyring" > /dev/null
        else
            sudo cp "$tmpkey" "$keyring"
        fi
        rm -f "$tmpkey"
        sudo chmod 644 "$keyring"
        echo "deb [signed-by=${keyring}] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
            sudo tee "$sources" > /dev/null
        echo "${ICON_OK} Repo 'antigravity' configured."
    fi
    sudo apt update -qq
    sudo apt install -y antigravity
}

install_extras() {
    if [[ -z "$EXTRA_REPOS" ]]; then
        return 0
    fi

    log_section "Installing extras."

    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connection. Skipping extras."
        echo "$SEPARATOR"
        return
    fi

    # Ensure umask is 0022 for APT keyring operations
    local _umask_pre
    _umask_pre=$(umask)
    [[ "$_umask_pre" != "0022" ]] && umask 0022

    # Individual extras → installer function
    local -A _extra_map=(
        [docker]=_extra_docker
        [gh]=_extra_gh
        [brave]=_extra_brave
        [signal]=_extra_signal
        [vscode]=_extra_vscode
        [element]=_extra_element
        [protonvpn]=_extra_protonvpn
        [podman]=_extra_podman
        [hashicorp]=_extra_hashicorp
        [spotify]=_extra_spotify
        [slack]=_extra_slack
        [chrome]=_extra_chrome
        [sublime]=_extra_sublime
        [azurecli]=_extra_azurecli
        [teams]=_extra_teams
        [vivaldi]=_extra_vivaldi
        [edge]=_extra_edge
        [wine]=_extra_wine
        [telegram]=_extra_telegram
        [antigravity]=_extra_antigravity
    )

    # Groups → space-separated list of individual keys
    local -A _extra_groups=(
        [all]="docker gh brave signal telegram vscode element protonvpn podman hashicorp spotify slack chrome sublime azurecli teams vivaldi edge wine antigravity"
        [devops]="docker gh hashicorp podman azurecli"
        [containers]="docker podman"
        [browsers]="brave chrome vivaldi edge"
        [messaging]="signal telegram element slack teams"
        [privacy]="protonvpn brave signal element"
        [microsoft]="vscode azurecli edge teams"
        [editors]="vscode sublime antigravity"
        [office]="teams slack wine"
        [media]="spotify"
        [security]="protonvpn signal element"
        [minimal]="docker gh vscode signal"
        [default]="docker gh vscode brave signal telegram element"
    )

    # Expand groups and deduplicate
    local -a _raw=()
    IFS=',' read -ra _raw <<< "$EXTRA_REPOS"

    local -a _to_install=()
    local -A _seen=()

    local -a _group_items=()
    for item in "${_raw[@]}"; do
        local key="${item// /}"
        if [[ -n "${_extra_groups[$key]+_}" ]]; then
            _group_items=()
            read -ra _group_items <<< "${_extra_groups[$key]}"
            for g in "${_group_items[@]}"; do
                if [[ -z "${_seen[$g]+_}" ]]; then
                    _to_install+=("$g")
                    _seen[$g]=1
                fi
            done
        elif [[ -n "${_extra_map[$key]+_}" ]]; then
            if [[ -z "${_seen[$key]+_}" ]]; then
                _to_install+=("$key")
                _seen[$key]=1
            fi
        else
            echo "${ICON_WARN} Unknown extra or group: '${key}'. Skipping."
            echo "${ICON_INFO} Individuals : docker gh brave signal telegram vscode element protonvpn podman"
            echo "${ICON_INFO}               hashicorp spotify slack chrome sublime azurecli teams vivaldi edge wine"
            echo "${ICON_INFO}               antigravity"
            echo "${ICON_INFO} Atomic groups : browsers messaging privacy editors devops containers microsoft office media security"
            echo "${ICON_INFO} Meta-groups   : minimal default all"
        fi
    done

    # Apply --skip-extras filter
    if [[ -n "$SKIP_EXTRAS" ]]; then
        local -A _skip_map=()
        local _sk
        IFS=',' read -ra _skip_arr <<< "$SKIP_EXTRAS"
        for _sk in "${_skip_arr[@]}"; do
            _skip_map["${_sk// /}"]=1
        done
        local -a _filtered=()
        for key in "${_to_install[@]}"; do
            if [[ -z "${_skip_map[$key]+_}" ]]; then
                _filtered+=("$key")
            else
                echo "${ICON_INFO} Skipping (--skip-extras): ${key}"
            fi
        done
        _to_install=("${_filtered[@]}")
    fi

    echo "${ICON_INFO} Will install (${#_to_install[@]}): ${_to_install[*]}"

    for key in "${_to_install[@]}"; do
        echo ""
        echo "${ICON_INFO} Installing: ${key}"
        "${_extra_map[$key]}" || echo "${ICON_WARN} Failed: ${key}"
    done

    [[ "$_umask_pre" != "0022" ]] && umask "$_umask_pre"
    echo "$SEPARATOR"
}


manage_firefox_profiles() {
    # Reset Firefox profiles: backup existing ones, delete them, create new profiles
    # (one or more), initialize each, and apply custom user.js to all.

    log_section "Starting Firefox profile management."

    # ---[ Step 1: Check Firefox is installed ]---
    if ! command -v firefox &>/dev/null; then
        echo "${ICON_WARN} Firefox is not installed. Skipping profile management."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 2: Parse profile lists ]---
    local -a profiles=()
    local -a hardened_profiles=()
    local -a relaxed_profiles=()
    IFS=',' read -ra profiles          <<< "$FIREFOX_PROFILES"
    IFS=',' read -ra hardened_profiles <<< "$FIREFOX_HARDENED_PROFILES"
    IFS=',' read -ra relaxed_profiles  <<< "$FIREFOX_RELAXED_PROFILES"

    echo "${ICON_INFO} Profiles to create: ${profiles[*]}"
    [[ -n "$FIREFOX_HARDENED_PROFILES" ]] && \
        echo "${ICON_INFO} Hardened (arkenfox, no overrides): ${hardened_profiles[*]}"
    [[ -n "$FIREFOX_RELAXED_PROFILES"  ]] && \
        echo "${ICON_INFO} Relaxed  (arkenfox + daily overrides): ${relaxed_profiles[*]}"

    # Helper: check if a profile name is in a given array.
    _in_list() {
        local needle="$1"; shift
        local item
        for item in "$@"; do
            [[ "${item// /}" == "$needle" ]] && return 0
        done
        return 1
    }

    # Helper: download an AMO extension XPI to a profile's extensions/ dir.
    # Requires: curl, unzip, python3.
    _install_extension() {
        local ppath="$1" slug="$2"
        local tmp_xpi ext_id
        tmp_xpi=$(mktemp --suffix=.xpi)
        if ! curl -fsSL -A "Mozilla/5.0" \
                "https://addons.mozilla.org/firefox/downloads/latest/${slug}/addon-latest.xpi" \
                -o "$tmp_xpi"; then
            echo "${ICON_WARN} Failed to download extension: ${slug}"
            rm -f "$tmp_xpi"
            return 1
        fi
        # Parse extension ID from manifest.json — handles both old (applications.gecko.id)
        # and new (browser_specific_settings.gecko.id) manifest format.
        ext_id=$(unzip -p "$tmp_xpi" manifest.json 2>/dev/null | \
            python3 -c "
import sys, json
d = json.load(sys.stdin)
bss = d.get('browser_specific_settings', d.get('applications', {}))
print(bss.get('gecko', {}).get('id', ''))
" 2>/dev/null)
        if [[ -z "$ext_id" ]]; then
            echo "${ICON_WARN} Could not extract extension ID for: ${slug} — skipping."
            rm -f "$tmp_xpi"
            return 1
        fi
        mkdir -p "$ppath/extensions"
        mv "$tmp_xpi" "$ppath/extensions/${ext_id}.xpi"
        echo "${ICON_OK} Extension installed: ${slug} (${ext_id})"
    }

    # ---[ Extension catalogue ]---
    # Default: installed in every profile.
    local -a _ext_default=( ublock-origin  privacy-badger17 )

    # Extra: installed when --firefox-extra-extensions is set.
    local -a _ext_extra=(
        clearurls
        foxyproxy-standard
        return-youtube-dislikes
        flagfox
        canvasblocker
        facebook-container
        multi-account-containers
        sponsorblock
        port-authority
        tab-reloader
        view-page-archive-cache
    )

    # ---[ Step 3: Locate / bootstrap profile directory ]---
    # Priority: existing directory > snap detection > deb fallback.
    # Snap Firefox is sandboxed and uses a different path than deb/system Firefox.
    local _snap_dir="$HOME/snap/firefox/common/.mozilla/firefox"
    local _deb_dir="$HOME/.mozilla/firefox"
    local profile_dir
    if [[ -d "$_snap_dir" ]]; then
        profile_dir="$_snap_dir"
        echo "${ICON_INFO} Found existing snap Firefox profile directory."
    elif [[ -d "$_deb_dir" ]]; then
        profile_dir="$_deb_dir"
        echo "${ICON_INFO} Found existing deb/system Firefox profile directory."
    elif snap list firefox &>/dev/null 2>&1; then
        profile_dir="$_snap_dir"
        echo "${ICON_INFO} No existing profiles — snap Firefox detected, using snap path."
    else
        profile_dir="$_deb_dir"
        echo "${ICON_INFO} No existing profiles — using default Firefox profile directory."
    fi
    local profiles_ini="$profile_dir/profiles.ini"

    # profiles.ini is created automatically by firefox -CreateProfile if missing.
    # We just need the directory to exist.
    mkdir -p "$profile_dir"
    echo "${ICON_OK} Profile directory: $profile_dir"

    # ---[ Step 4: Kill any running Firefox instances ]---
    # A running Firefox holds a lock on its profile — -P would silently fail or
    # use a temp profile instead, meaning prefs.js never appears in $ppath.
    if pkill -x firefox 2>/dev/null; then
        echo "${ICON_OK} Killed running Firefox instance(s). Waiting for full exit..."
        local _waited=0
        while pgrep -x firefox &>/dev/null && [[ $_waited -lt 10 ]]; do
            sleep 1; (( _waited++ ))
        done
    fi

    # ---[ Step 5: Backup existing profiles ]---
    local backup_dir="${profile_dir}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "${ICON_OK} Backing up existing profiles to $backup_dir..."
    cp -r "$profile_dir" "$backup_dir"
    echo "${ICON_OK} Backup done."

    # ---[ Step 6: Delete old profile directories and profiles.ini ]---
    # Also remove profiles.ini so firefox -CreateProfile starts with a clean slate.
    # Stale entries in profiles.ini cause "profile missing or invalid" on launch.
    echo "${ICON_OK} Removing old profile directories..."
    find "$profile_dir" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
    rm -f "$profiles_ini"
    echo "${ICON_OK} Old profiles removed."

    # ---[ Step 7: Pre-fetch arkenfox user.js once if any hardened profile requested ]---
    local tmp_arkenfox=""
    local arkenfox_ok=false
    local assets_dir
    assets_dir="$(dirname "$(realpath "$0")")/assets/firefox"
    local overrides_src="$assets_dir/user-overrides.js"

    if [[ -n "$FIREFOX_HARDENED_PROFILES" || -n "$FIREFOX_RELAXED_PROFILES" ]]; then
        tmp_arkenfox=$(mktemp)
        echo "${ICON_OK} Downloading arkenfox user.js..."
        if curl -fsSL "$URL_ARKENFOX" -o "$tmp_arkenfox"; then
            arkenfox_ok=true
            echo "${ICON_OK} arkenfox user.js downloaded."
        else
            echo "${ICON_WARN} Failed to download arkenfox. Hardened profiles will have no user.js."
        fi
    fi

    # ---[ Step 8: Create, initialize, and configure each profile ]---
    local had_error=false
    local pname ppath waited

    for pname in "${profiles[@]}"; do
        pname="${pname// /}"
        ppath="$profile_dir/$pname"

        echo "${ICON_INFO} --- Profile: ${pname} ---"

        # Register profile in profiles.ini
        if ! firefox -CreateProfile "${pname} ${ppath}" &>/dev/null; then
            echo "${ICON_WARN} Failed to register '${pname}'. Skipping."
            had_error=true
            continue
        fi
        echo "${ICON_OK} '${pname}' registered."

        # Launch Firefox to initialize the profile (prefs.js, sessionstore, etc.)
        # --no-remote forces a new instance even if Firefox is already open.
        firefox -P "$pname" --no-remote &>/dev/null &
        ff_pid=$!

        # Wait up to 30s for prefs.js.
        waited=0
        while [[ ! -f "$ppath/prefs.js" && $waited -lt 30 ]]; do
            sleep 1
            (( waited++ ))
        done

        kill "$ff_pid" 2>/dev/null
        wait "$ff_pid" 2>/dev/null

        if [[ ! -f "$ppath/prefs.js" ]]; then
            echo "${ICON_WARN} '${pname}' not populated in time."
            had_error=true
        else
            echo "${ICON_OK} '${pname}' initialized."
        fi

        # Apply user.js based on profile type:
        #   hardened → pure arkenfox, zero overrides — maximum privacy
        #   relaxed  → arkenfox + practical overrides for daily browsing
        #   default  → nothing applied
        if _in_list "$pname" "${hardened_profiles[@]}"; then
            if $arkenfox_ok; then
                cp "$tmp_arkenfox" "$ppath/user.js"
                echo "${ICON_OK} arkenfox user.js applied to '${pname}' (full hardening, no overrides)."
            else
                echo "${ICON_WARN} arkenfox download failed — no user.js applied to '${pname}'."
            fi
        elif _in_list "$pname" "${relaxed_profiles[@]}"; then
            if $arkenfox_ok; then
                cp "$tmp_arkenfox" "$ppath/user.js"
                # Append relaxed overrides inline.
                # These restore usability features arkenfox disables by default.
                # user-overrides.js is also written for future updater.sh compatibility.
                cat >> "$ppath/user.js" << 'RELAXED_OVERRIDES'

/*** user-overrides — relaxed profile (daily browsing) ***/

// [SESSIONS] Keep cookies and sessions across restarts
// arkenfox clears everything on exit — too aggressive for daily use
user_pref("privacy.sanitize.sanitizeOnShutdown", false);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", false);
user_pref("privacy.clearOnShutdown.cookies", false);
user_pref("privacy.clearOnShutdown.sessions", false);

// [SESSION RESTORE] Restore previous tabs on restart
user_pref("browser.sessionstore.privacy_level", 0);

// [WEBRTC] Re-enable for video conferencing (Zoom, Meet, Teams, Discord)
// arkenfox restricts ICE candidates — breaks calls on dual-interface setups
user_pref("media.peerconnection.ice.default_address_only", false);
user_pref("media.peerconnection.ice.no_host", false);
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", false);

// [DRM] Re-enable for streaming services (Netflix, Disney+, Prime Video, Spotify)
user_pref("media.eme.enabled", true);
user_pref("browser.eme.ui.enabled", true);

// [FONTS] Re-enable downloadable fonts — too many sites break without them
user_pref("gfx.downloadable_fonts.enabled", true);

// [FORMS] Re-enable form autocomplete
user_pref("browser.formfill.enable", true);

// [SEARCH] Re-enable search suggestions in address bar
user_pref("browser.search.suggest.enabled", true);
user_pref("browser.urlbar.suggest.searches", true);

// [OCSP] Soft-fail instead of hard-fail — avoids blocking legit sites when
// OCSP servers are slow or unreachable
user_pref("security.OCSP.require", false);

// [DOWNLOADS] Use default Downloads directory instead of always prompting
user_pref("browser.download.useDownloadDir", true);
user_pref("browser.download.start_downloads_in_tmp_dir", false);
RELAXED_OVERRIDES
                # Keep a copy as user-overrides.js for future updater.sh runs
                cp "$ppath/user.js" "$ppath/user-overrides.js"
                echo "${ICON_OK} arkenfox + relaxed overrides applied to '${pname}'."
            else
                echo "${ICON_WARN} arkenfox download failed — no user.js applied to '${pname}'."
            fi
        else
            echo "${ICON_SKIP} '${pname}': no user.js applied."
        fi

        # ---[ Install extensions ]---
        echo "${ICON_INFO} Installing default extensions for '${pname}'..."
        for slug in "${_ext_default[@]}"; do
            _install_extension "$ppath" "$slug"
        done
        if $FIREFOX_EXTRA_EXTENSIONS; then
            echo "${ICON_INFO} Installing extra extensions for '${pname}'..."
            for slug in "${_ext_extra[@]}"; do
                _install_extension "$ppath" "$slug"
            done
        fi
    done

    [[ -n "$tmp_arkenfox" ]] && rm -f "$tmp_arkenfox"

    # ---[ Step 9: Show profile selector at startup if more than one profile ]---
    if [[ "${#profiles[@]}" -gt 1 && -f "$profiles_ini" ]]; then
        if grep -q "^StartWithLastProfile=" "$profiles_ini"; then
            sed -i 's/^StartWithLastProfile=.*/StartWithLastProfile=0/' "$profiles_ini"
        else
            sed -i '/^\[General\]/a StartWithLastProfile=0' "$profiles_ini"
        fi
        echo "${ICON_OK} Profile selector enabled at startup (${#profiles[@]} profiles)."
    fi

    # ---[ Step 10: Remove backup unless errors or --keep-firefox-backup ]---
    if $KEEP_FIREFOX_BACKUP; then
        echo "${ICON_INFO} Keeping backup at $backup_dir (--keep-firefox-backup)."
    elif $had_error; then
        echo "${ICON_WARN} Errors occurred — backup preserved at $backup_dir."
    else
        rm -rf "$backup_dir"
        echo "${ICON_OK} Backup removed (no errors)."
    fi

    log_section "Firefox profile management completed."
}


_vim_ensure_installed() {
    # Install vim via apt if not present.
    if ! command -v vim &>/dev/null; then
        echo "${ICON_WARN} Vim is not installed. Installing..."
        sudo apt install -y vim
    fi
}

_vim_backup_vimrc() {
    # Backup existing .vimrc if present.
    local vimrc="$HOME/.vimrc"
    if [[ -f "$vimrc" ]]; then
        echo "${ICON_OK} Existing .vimrc found. Backing up to ${vimrc}.bak"
        cp "$vimrc" "${vimrc}.bak"
    fi
}

_vim_full() {
    # Install vim-plug and write a full vimrc with all plugins.

    # ---[ Step 1: Install vim-plug ]---
    local plug_dir="$HOME/.vim/autoload"
    local plug_file="$plug_dir/plug.vim"

    if [[ -f "$plug_file" ]]; then
        echo "${ICON_SKIP} vim-plug already installed."
    else
        echo "${ICON_OK} Installing vim-plug..."
        mkdir -p "$plug_dir"
        if curl -fLo "$plug_file" "$URL_VIM_PLUG"; then
            echo "${ICON_OK} vim-plug installed."
        else
            echo "${ICON_WARN} Failed to download vim-plug. Check connectivity."
            echo "$SEPARATOR"
            return 1
        fi
    fi

    mkdir -p "$HOME/.vim/undo"
    _vim_backup_vimrc

    # ---[ Step 2: Write vimrc ]---
    echo "${ICON_OK} Writing .vimrc (full preset)..."
    {
        cat << 'VIMRC_PLUGINS'
" ============================================================
" vimrc — full preset (vim-plug + plugins)
" ============================================================

" --- Plugin Manager (vim-plug) ---
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'                " Colorscheme
Plug 'vim-airline/vim-airline'        " Statusline
Plug 'vim-airline/vim-airline-themes' " Airline themes
Plug 'preservim/nerdtree'             " File explorer
Plug 'Yggdroot/indentLine'            " Indentation guides
Plug 'itchyny/vim-cursorword'         " Highlight word under cursor
Plug 'mhinz/vim-startify'             " Start screen
Plug 'preservim/nerdcommenter'        " Comment toggling
Plug 'andymass/vim-matchup'           " Enhanced bracket matching
call plug#end()
VIMRC_PLUGINS
        printf 'set background=%s\nsilent! colorscheme gruvbox\n' "$COLOR_SCHEME"
        cat << 'VIMRC'

" --- General ---
set nocompatible
set encoding=utf-8
set hidden
set autoread
set mouse=nv
set belloff=all
set ttimeout
set ttimeoutlen=50

" --- UI ---
set number
set laststatus=2
set wildmenu
set showmatch
set scrolloff=5
set sidescrolloff=5
set nowrap
set linebreak
set noshowcmd
set pumheight=15
set completeopt=menu,menuone,longest
set shortmess+=c

" --- Search ---
set incsearch
set hlsearch

" --- Indentation ---
set autoindent
set smartindent
set backspace=indent,eol,start
set nrformats-=octal

" --- Undo (no backup files) ---
set undofile
set undolevels=1000
set undodir=~/.vim/undo
set nobackup
set nowritebackup

" --- Airline ---
let g:airline_theme='gruvbox'
let g:airline_powerline_fonts=1

" --- NERDTree ---
let mapleader=" "
nnoremap <leader>e :NERDTreeToggle<CR>
let g:NERDTreeShowHidden=1

" --- indentLine ---
let g:indentLine_enabled=1

" --- Key Mappings ---
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>

" --- Auto-install plugins on first run ---
if empty(glob('~/.vim/plugged'))
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
VIMRC
    } > "$HOME/.vimrc"

    echo "${ICON_OK} .vimrc written. Plugins will auto-install on first vim launch."
}

_vim_minimal() {
    # Install gruvbox via native vim packages and write a lean vimrc (no plugin manager).

    # ---[ Step 1: Install gruvbox via vim8 native packages ]---
    local pack_dir="$HOME/.vim/pack/themes/start/gruvbox"
    if [[ -d "$pack_dir" ]]; then
        echo "${ICON_SKIP} gruvbox already installed."
    else
        echo "${ICON_OK} Installing gruvbox colorscheme..."
        mkdir -p "$(dirname "$pack_dir")"
        if git clone --depth=1 https://github.com/morhetz/gruvbox.git "$pack_dir"; then
            echo "${ICON_OK} gruvbox installed."
        else
            echo "${ICON_WARN} Failed to clone gruvbox. Check connectivity."
            echo "$SEPARATOR"
            return 1
        fi
    fi

    mkdir -p "$HOME/.vim/undo"
    _vim_backup_vimrc

    # ---[ Step 2: Write vimrc ]---
    echo "${ICON_OK} Writing .vimrc (minimal preset)..."
    {
        cat << 'VIMRC_HEADER'
" ============================================================
" vimrc — minimal preset (gruvbox + settings, no plugin manager)
" ============================================================
VIMRC_HEADER
        printf 'packadd gruvbox\nset background=%s\ncolorscheme gruvbox\n' "$COLOR_SCHEME"
        cat << 'VIMRC'

" --- General ---
set nocompatible
set encoding=utf-8
set hidden
set autoread
set mouse=nv
set belloff=all
set ttimeout
set ttimeoutlen=50

" --- UI ---
set number
set laststatus=2
set wildmenu
set showmatch
set scrolloff=5
set sidescrolloff=5
set nowrap
set linebreak
set noshowcmd
set shortmess+=c

" --- Search ---
set incsearch
set hlsearch

" --- Indentation ---
set autoindent
set smartindent
set backspace=indent,eol,start
set nrformats-=octal

" --- Undo (no backup files) ---
set undofile
set undolevels=1000
set undodir=~/.vim/undo
set nobackup
set nowritebackup

" --- Key Mappings ---
let mapleader=" "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
VIMRC
    } > "$HOME/.vimrc"

    echo "${ICON_OK} .vimrc written."
}

_vim_bare() {
    # Write a vimrc with settings only and a built-in colorscheme — no downloads, no git.

    _vim_backup_vimrc
    mkdir -p "$HOME/.vim/undo"

    echo "${ICON_OK} Writing .vimrc (bare preset)..."
    {
        printf 'set background=%s\ncolorscheme %s\n\n' "$COLOR_SCHEME" "$VIM_COLORSCHEME"
        cat << 'VIMRC'
" ============================================================
" vimrc — bare preset (zero external dependencies)
" ============================================================

" --- General ---
set nocompatible
set encoding=utf-8
set hidden
set autoread
set mouse=nv
set belloff=all
set ttimeout
set ttimeoutlen=50

" --- UI ---
set number
set laststatus=2
set wildmenu
set showmatch
set scrolloff=5
set sidescrolloff=5
set nowrap
set linebreak
set noshowcmd
set shortmess+=c

" --- Search ---
set incsearch
set hlsearch

" --- Indentation ---
set autoindent
set smartindent
set backspace=indent,eol,start
set nrformats-=octal

" --- Undo (no backup files) ---
set undofile
set undolevels=1000
set undodir=~/.vim/undo
set nobackup
set nowritebackup

" --- Key Mappings ---
let mapleader=" "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>h :nohlsearch<CR>
VIMRC
    } > "$HOME/.vimrc"

    echo "${ICON_OK} .vimrc written. No external downloads performed."
}

install_vim_config() {
    # Ensure Vim is installed, then configure it using the selected preset.

    log_section "Starting Vim configuration setup (preset: $VIM_PRESET)."

    _vim_ensure_installed

    case "$VIM_PRESET" in
        full)    _vim_full    ;;
        minimal) _vim_minimal ;;
        bare)    _vim_bare    ;;
    esac

    echo "$SEPARATOR"
}


install_lazyvim() {
    # Ensure Neovim is installed, then install LazyVim into ~/.config/nvim.

    log_section "Starting LazyVim installation."

    # ---[ Step 1: Check for Internet Connectivity ]---
    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connection. Skipping LazyVim installation."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 2: Check if neovim is installed ]---
    if ! command -v nvim &>/dev/null; then
        echo "${ICON_OK} Installing Neovim via snap..."
        sudo snap install nvim --classic
    fi

    # ---[ Step 3: Ensure /snap/bin is in PATH ]---
    # snap binaries land in /snap/bin which root's PATH often omits.
    if [[ ":$PATH:" != *":/snap/bin:"* ]]; then
        grep -q '/snap/bin' "$HOME/.bashrc" || \
            echo 'export PATH="$PATH:/snap/bin"' >> "$HOME/.bashrc"
        export PATH="$PATH:/snap/bin"
        echo "${ICON_OK} /snap/bin added to PATH."
        echo "${ICON_WARN} Run 'source ~/.bashrc' or open a new terminal to use nvim."
    fi

    # ---[ Step 4: Skip if LazyVim already installed ]---
    local nvim_config="$HOME/.config/nvim"
    if [[ -f "$nvim_config/lua/config/lazy.lua" ]]; then
        echo "${ICON_SKIP} LazyVim already installed. Skipping."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 5: Backup existing config if present ]---
    if [[ -d "$nvim_config" ]]; then
        local nvim_bak="${nvim_config}.bak.$(date +%Y%m%d_%H%M%S)"
        echo "${ICON_OK} Existing Neovim config found. Backing up to $nvim_bak..."
        mv "$nvim_config" "$nvim_bak"
    fi

    # ---[ Step 6: Clone LazyVim starter ]---
    echo "${ICON_OK} Cloning LazyVim starter..."
    if git clone "$URL_LAZYVIM" "$nvim_config"; then
        rm -rf "$nvim_config/.git"
        echo "${ICON_OK} LazyVim installed successfully."
    else
        echo "${ICON_WARN} LazyVim installation failed."
    fi

    echo "$SEPARATOR"
}


install_nerd_fonts() {
    # Download Nerd Fonts from GitHub releases and install to ~/.local/share/fonts/.

    log_section "Starting Nerd Fonts installation (profile: $NERD_FONTS_PROFILE)."

    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connection. Skipping Nerd Fonts installation."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 1: Resolve latest release version via GitHub API ]---
    local version
    version=$(curl -fsSL "$URL_NERD_FONTS_API" | python3 -c \
        "import sys,json; print(json.load(sys.stdin)['tag_name'])" 2>/dev/null)
    if [[ -z "$version" ]]; then
        echo "${ICON_WARN} Could not resolve latest Nerd Fonts version. Skipping."
        echo "$SEPARATOR"
        return
    fi
    echo "${ICON_INFO} Nerd Fonts $version"

    # ---[ Step 2: Build font list from profile ]---
    local -a fonts=( JetBrainsMono )
    if [[ "$NERD_FONTS_PROFILE" == "extra" ]]; then
        fonts+=( FiraCode Hack )
    fi

    # ---[ Step 3: Download, extract, install ]---
    local target_dir="$HOME/.local/share/fonts/NerdFonts"
    mkdir -p "$target_dir"
    local any_installed=false
    local tmp_dir
    tmp_dir=$(mktemp -d)

    for font in "${fonts[@]}"; do
        if compgen -G "$target_dir/${font}*" &>/dev/null; then
            echo "${ICON_SKIP} ${font} already installed."
            continue
        fi
        local url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font}.tar.xz"
        local tmp_archive="$tmp_dir/${font}.tar.xz"
        echo "${ICON_INFO} Downloading ${font}..."
        if ! curl -fsSL "$url" -o "$tmp_archive"; then
            echo "${ICON_WARN} Failed to download ${font}. Skipping."
            continue
        fi
        tar -xf "$tmp_archive" -C "$target_dir" --wildcards '*.ttf' 2>/dev/null
        echo "${ICON_OK} ${font} installed."
        any_installed=true
    done

    rm -rf "$tmp_dir"

    # ---[ Step 4: Refresh font cache ]---
    if $any_installed; then
        echo "${ICON_OK} Updating font cache..."
        fc-cache -f "$target_dir"
        echo "${ICON_OK} Font cache updated."
    fi

    echo "$SEPARATOR"
}


install_ohmyzsh() {
    # Install Oh My Zsh unattended, clear bash history, and set Zsh as default shell.

    log_section "Starting Oh My Zsh installation."

    # ---[ Step 1: Check internet ]---
    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connection. Skipping."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 2: Ensure Zsh is installed ]---
    if ! command -v zsh &>/dev/null; then
        echo "${ICON_WARN} Zsh not installed. Installing..."
        sudo apt install -y zsh
    fi

    # ---[ Step 3: Install Oh My Zsh ]---
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "${ICON_SKIP} Oh My Zsh is already installed."
    else
        local omz_installer
        omz_installer=$(mktemp)
        echo "${ICON_OK} Downloading Oh My Zsh installer..."
        if ! curl -fsSL "$URL_OHMYZSH" -o "$omz_installer"; then
            echo "${ICON_WARN} Failed to download Oh My Zsh installer."
            rm -f "$omz_installer"
            echo "$SEPARATOR"
            return
        fi
        if ! RUNZSH=no CHSH=no sh "$omz_installer" --unattended; then
            echo "${ICON_WARN} Oh My Zsh installation failed."
            rm -f "$omz_installer"
            echo "$SEPARATOR"
            return
        fi
        rm -f "$omz_installer"
        echo "${ICON_OK} Oh My Zsh installed."
    fi

    # ---[ Step 4: Clear bash history ]---
    if $CLEAR_BASH_HISTORY; then
        history -c
        rm -f "$HOME/.bash_history"
    fi

    # ---[ Step 5: Set Zsh as default shell ]---
    # $SHELL reflects the shell at login time — not updated by chsh until next session.
    # Read /etc/passwd via getent to get the actual current default shell.
    local zsh_path
    zsh_path=$(command -v zsh)
    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    if [[ "$current_shell" != "$zsh_path" ]]; then
        echo "${ICON_OK} Changing default shell to Zsh..."
        if sudo chsh -s "$zsh_path" "$USER"; then
            echo "${ICON_OK} Default shell changed to Zsh."
        else
            echo "${ICON_WARN} Failed to change default shell. Run manually: chsh -s $zsh_path"
        fi
    else
        echo "${ICON_SKIP} Zsh is already the default shell."
    fi

    echo "$SEPARATOR"
}


custom_zsh() {
    # Install Powerlevel10k theme and core Zsh plugins, then configure .zshrc.

    log_section "Starting Zsh customization."

    # ---[ Step 1: Ensure Zsh is installed ]---
    if ! command -v zsh &>/dev/null; then
        echo "${ICON_WARN} Zsh not installed. Installing..."
        sudo apt install -y zsh
    fi

    # ---[ Step 2: Check Oh My Zsh is installed ]---
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "${ICON_WARN} Oh My Zsh is not installed. Skipping."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 3: Check internet ]---
    if ! check_internet_connectivity; then
        echo "${ICON_WARN} No internet connection. Skipping."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 4: Ensure git is installed ]---
    if ! command -v git &>/dev/null; then
        echo "${ICON_WARN} git not installed. Installing..."
        sudo apt install -y git
    fi

    # ---[ Step 5: Install Powerlevel10k ]---
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]]; then
        echo "${ICON_SKIP} Powerlevel10k is already installed."
    else
        echo "${ICON_OK} Installing Powerlevel10k..."
        git clone --depth=1 "$URL_POWERLEVEL10K" "$p10k_dir" || \
            echo "${ICON_WARN} Failed to clone Powerlevel10k."
    fi

    # ---[ Step 6: Set Powerlevel10k as theme in .zshrc ]---
    local zshrc="$HOME/.zshrc"
    if grep -q '^ZSH_THEME=' "$zshrc"; then
        sed -i 's/^ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$zshrc"
    else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$zshrc"
    fi
    echo "${ICON_OK} Theme set to Powerlevel10k."

    # ---[ Step 7: Install plugins ]---
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    local -a plugin_names=( zsh-autosuggestions       zsh-syntax-highlighting       zsh-completions       )
    local -a plugin_urls=(  "$URL_PLUGIN_AUTOSUGGESTIONS" "$URL_PLUGIN_SYNTAX_HIGHLIGHTING" "$URL_PLUGIN_COMPLETIONS" )

    local i
    for i in "${!plugin_names[@]}"; do
        local name="${plugin_names[$i]}"
        local url="${plugin_urls[$i]}"
        if [[ -d "$plugins_dir/$name" ]]; then
            echo "${ICON_SKIP} $name already installed."
        else
            echo "${ICON_OK} Installing $name..."
            git clone --depth=1 "$url" "$plugins_dir/$name" || \
                echo "${ICON_WARN} Failed to clone $name."
        fi
    done

    # ---[ Step 8: Update plugins list in .zshrc ]---
    if grep -q '^plugins=' "$zshrc"; then
        sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' "$zshrc"
    else
        echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)" >> "$zshrc"
    fi
    echo "${ICON_OK} Plugins configured."

    # ---[ Step 9: Ensure ~/.local/bin is in PATH ]---
    if grep -q '\.local/bin' "$zshrc"; then
        echo "${ICON_SKIP} ~/.local/bin already in PATH."
    else
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$zshrc"
        echo "${ICON_OK} ~/.local/bin added to PATH in .zshrc."
    fi

    echo "$SEPARATOR"
}


update_zsh_plugins() {
    # Update .zshrc with a full plugin list, preserving essential plugins and removing duplicates.

    log_section "Starting Zsh plugins update."

    local zshrc="$HOME/.zshrc"

    # ---[ Step 1: Verify .zshrc exists ]---
    if [ ! -f "$zshrc" ]; then
        echo "${ICON_WARN} No .zshrc file found. Skipping plugin update."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 2: Build plugin list from profile ]---
    local -a plugins=()
    case "$ZSH_PLUGINS_PROFILE" in
        minimal)
            plugins=(
                git sudo history extract
                colored-man-pages command-not-found ubuntu
            )
            ;;
        full)
            plugins=(
                git aliases autopep8 aws colored-man-pages colorize command-not-found
                common-aliases compleat copybuffer copyfile copypath cp docker
                docker-compose emoji emoji-clock emotty encode64 extract fancy-ctrl-z
                fbterm genpass git-commit git-escape-magic gitignore git-prompt golang
                history hitokoto httpie jsontools kubectl kubectx lol man nmap pip
                qrcode python rust sublime sudo systemadmin systemd taskwarrior terraform
                themes timer tmux tmuxinator torrent transfer ubuntu ufw urltools
                vagrant vscode web-search
            )
            ;;
        default|*)
            plugins=(
                git sudo history extract
                common-aliases aliases colored-man-pages colorize command-not-found
                fancy-ctrl-z copybuffer copyfile copypath cp
                encode64 urltools web-search
                ubuntu ufw systemd systemadmin tmux timer man
                python pip taskwarrior
                git-commit gitignore git-prompt git-escape-magic
                httpie jsontools nmap
                transfer genpass emoji
            )
            ;;
    esac

    # ---[ Step 3: Append installed custom plugins ]---
    local custom_plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
        [[ -d "$custom_plugins_dir/$plugin" ]] && plugins+=("$plugin")
    done

    # ---[ Step 4: Deduplicate preserving order ]---
    local -a unique=()
    local seen=""
    for p in "${plugins[@]}"; do
        if [[ "$seen" != *"|$p|"* ]]; then
            unique+=("$p")
            seen+="|$p|"
        fi
    done

    # ---[ Step 5: Skip if already up to date ]---
    local plugins_line="plugins=(${unique[*]})"
    if grep -qF "$plugins_line" "$zshrc"; then
        echo "${ICON_SKIP} Plugins already up to date."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Step 6: Backup and update ]---
    local bak="${zshrc}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$zshrc" "$bak"

    if grep -q "^plugins=" "$zshrc"; then
        sed -i "s|^plugins=(.*)|${plugins_line}|" "$zshrc"
    else
        printf '\n%s\n' "$plugins_line" >> "$zshrc"
    fi
    echo "${ICON_OK} Plugins updated (${#unique[@]} plugins, profile: $ZSH_PLUGINS_PROFILE)."

    echo "$SEPARATOR"
}


update_zsh_aliases() {
    log_section "Starting Zsh aliases update."

    local zshrc="$HOME/.zshrc"

    if [[ ! -f "$zshrc" ]]; then
        echo "${ICON_WARN} No .zshrc found. Skipping aliases update."
        echo "$SEPARATOR"
        return
    fi

    if grep -q '# >>> CUSTOM ALIASES >>>' "$zshrc"; then
        echo "${ICON_SKIP} Aliases already configured."
        echo "$SEPARATOR"
        return
    fi

    # ---[ Backup ]---
    local backup="${zshrc}.$(date +%Y%m%d_%H%M%S).bak"
    cp "$zshrc" "$backup"

    # ---[ Remove existing block (safety) ]---
    sed -i '/# >>> CUSTOM ALIASES >>>/,/# <<< CUSTOM ALIASES <<</d' "$zshrc"

    # ---[ Static aliases ]---
    cat >> "$zshrc" << 'ALIASES'
# >>> CUSTOM ALIASES >>>

# Navigation
alias ..='cd ..'
alias cd..='cd ..'
alias mkdir='mkdir -p'

# Files
alias untar='tar -zxvf'
alias follow='tail -f -n +1'
alias less='less -R'
alias diff='diff --color=auto'
alias grep='grep --color=auto'

# Disk
alias df='df -h'
alias du='du -h'
alias biggest='du -h --max-depth=1 | sort -h'
alias folders='du -h --max-depth=1'
alias diskspace='du -S | sort -n -r | more'
alias mountedinfo='df -hT'

# System
alias mem='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias dmesg='dmesg --human'
alias j='jobs'
alias jctl='journalctl -p 3 -xb'
alias da='date "+%Y-%m-%d %A %T %Z"'

# Network
alias shpubip='curl -s http://ipecho.net/plain; echo'
command -v ip &>/dev/null && alias ip='ip -c'

# Misc
alias calc='bc -l'
alias getrand='openssl rand -base64 42'
alias countfiles='echo "Files: $(find . -maxdepth 1 -type f | wc -l) | Dirs: $(find . -maxdepth 1 -type d | wc -l)"'

# lsd — runtime check: fallback to --no-icons if no Nerd Font detected
if command -v lsd &>/dev/null; then
    _lsd=''
    fc-list 2>/dev/null | grep -qi 'nerd' || _lsd='--no-icons'
    alias ls="lsd ${_lsd}"
    alias la="lsd -A ${_lsd}"
    alias l="lsd ${_lsd}"
    alias ll="lsd -alFh ${_lsd}"
    alias lt="lsd -ltrh ${_lsd}"
    alias lk="lsd -lSrh ${_lsd}"
    alias lr="lsd -lRh ${_lsd}"
    alias lx="lsd -lXh ${_lsd}"
    alias lm="lsd -alh ${_lsd} | more"
    alias ldir="lsd -l ${_lsd} | grep -E '^d' --color=never"
    alias lf="lsd -l ${_lsd} | grep -Ev '^d'"
    unset _lsd
fi

# netstat
if command -v netstat &>/dev/null; then
    alias ports='sudo netstat -tulanp'
    alias openports='netstat -nape --inet'
fi

# Desktop
command -v xdg-open &>/dev/null && alias open='xdg-open'

# Mullvad
if command -v mullvad &>/dev/null; then
    alias checkmv='curl -s https://am.i.mullvad.net/connected'
    alias city='curl -s https://am.i.mullvad.net/city'
    alias country='curl -s https://am.i.mullvad.net/country'
fi

# ZuluCrypt
if command -v zuluCrypt-gui &>/dev/null; then
    alias zulu='zuluCrypt-gui'
    alias zulucli='zuluCrypt-cli'
fi

# <<< CUSTOM ALIASES <<<
ALIASES

    echo "${ICON_OK} Aliases updated."
    echo "$SEPARATOR"
}


copy_p10k_config() {
    log_section "Applying Powerlevel10k configuration."

    local target="$HOME/.p10k.zsh"
    local presets_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/config"

    if [[ -f "$target" ]]; then
        echo "${ICON_SKIP} .p10k.zsh already exists. Run 'p10k configure' to regenerate."
        echo "$SEPARATOR"
        return
    fi

    if [[ ! -d "$presets_dir" ]]; then
        echo "${ICON_WARN} Powerlevel10k not found at $presets_dir. Skipping."
        echo "$SEPARATOR"
        return
    fi

    local preset_file="${presets_dir}/p10k-${P10K_PRESET}.zsh"
    if [[ ! -f "$preset_file" ]]; then
        echo "${ICON_WARN} Preset '$P10K_PRESET' not found. Skipping."
        echo "$SEPARATOR"
        return
    fi

    cp "$preset_file" "$target"
    echo "${ICON_OK} p10k preset '$P10K_PRESET' applied."

    # ---[ Custom overrides ]---
    if [[ "$P10K_CUSTOM" == true ]]; then
        # Always show context (user@host) — default presets hide it for non-root, non-SSH.
        sed -i '/POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=/d' "$target"

        # WireGuard interface pattern — only if Mullvad is actually installed
        if command -v mullvad &>/dev/null; then
            local _wg_pattern="'(gpd|wg|(.*tun)|tailscale)[0-9]*|(zt.*)'"
            if grep -q 'POWERLEVEL9K_VPN_IP_INTERFACE' "$target"; then
                sed -i "s|typeset -g POWERLEVEL9K_VPN_IP_INTERFACE=.*|typeset -g POWERLEVEL9K_VPN_IP_INTERFACE=${_wg_pattern}|" "$target"
            else
                sed -i "/vpn_ip.*VPN/a\\  typeset -g POWERLEVEL9K_VPN_IP_INTERFACE=${_wg_pattern}" "$target"
            fi
        fi

        # Replace prompt element arrays — only if explicitly requested
        if [[ "$P10K_SEGMENTS" == true ]]; then
            if ! command -v python3 &>/dev/null; then
                echo "${ICON_WARN} python3 not found, skipping segment layout override."
            else
                python3 - "$target" << 'PYEOF'
import sys, re

path = sys.argv[1]
with open(path) as f:
    content = f.read()

left = """\
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon      # os identifier
    dir          # current directory
    vcs          # git status
    context      # user@hostname — bold red if root
    prompt_char  # ❯ green/red based on last exit code
  )"""

right = """\
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code
    command_execution_time  # duration of last command
    background_jobs         # background job count
    virtualenv              # python venv
    pyenv                   # pyenv version
    goenv                   # go version
    nodenv                  # node version (nodenv)
    nvm                     # node version (nvm)
    rbenv                   # ruby version
    kubecontext             # kubernetes context
    terraform               # terraform workspace
    aws                     # aws profile
    azure                   # azure account
    gcloud                  # gcloud project
    vpn_ip                  # VPN indicator (WireGuard/Mullvad)
    taskwarrior             # task count
    time                    # current time
  )"""

content = re.sub(
    r'typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=\(.*?\)',
    left, content, flags=re.DOTALL)
content = re.sub(
    r'typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=\(.*?\)',
    right, content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(content)
PYEOF
            fi
        fi

        echo "${ICON_OK} Custom overrides applied."
    fi

    echo "${ICON_INFO} Run 'p10k configure' to customize."
    echo "$SEPARATOR"
}


main() {
    clear
    show_banner
    echo

    echo "${ICON_INFO} Starting post-installation script..."

    local _start_time=$SECONDS
    trap 'echo ""; echo "${ICON_WARN} Interrupted after $(( SECONDS - _start_time ))s."; exit 130' INT TERM

    declare -A step_map=(
        [1]="perform_system_update"
        [2]="configure_firewall"
        [3]="configure_system_settings"
        [4]="configure_hardening"
        [5]="install_basic_apps"
        [6]="manage_firefox_profiles"
        [7]="install_vim_config"
        [8]="install_lazyvim"
        [9]="install_nerd_fonts"
        [10]="install_ohmyzsh"
        [11]="custom_zsh"
        [12]="update_zsh_plugins"
        [13]="update_zsh_aliases"
        [14]="copy_p10k_config"
        [15]="install_extras"
    )

    case "$EDITOR_MODE" in
        vim)    unset 'step_map[8]' ;;
        neovim) unset 'step_map[7]' ;;
        none)   unset 'step_map[7]'; unset 'step_map[8]' ;;
    esac
    [[ -z "$EXTRA_REPOS" ]] && unset 'step_map[15]'

    local ordered_keys
    ordered_keys=$(echo "${!step_map[@]}" | tr ' ' '\n' | sort -n | tr '\n' ' ')

    local -a selected_nums
    if [[ -n "$SELECTED_STEPS" ]]; then
        read -ra selected_nums <<< "$(parse_step_selection "$SELECTED_STEPS")"
    else
        read -ra selected_nums <<< "$ordered_keys"
    fi

    local -a _failed=()
    for num in "${selected_nums[@]}"; do
        if [[ -z "${step_map[$num]+_}" ]]; then
            echo "${ICON_WARN} Step $num not available. Skipping."
            continue
        fi
        local step="${step_map[$num]}"
        echo ""
        echo "${ICON_INFO} Step $num: $step"
        if ! $step; then
            echo "${ICON_WARN} Error in $step."
            _failed+=("$num: $step")
        fi
    done

    local _elapsed=$(( SECONDS - _start_time ))
    echo ""
    echo "$SEPARATOR"
    if [[ ${#_failed[@]} -eq 0 ]]; then
        echo "${ICON_OK} Done in ${_elapsed}s."
    else
        echo "${ICON_WARN} Done in ${_elapsed}s — ${#_failed[@]} failed:"
        for f in "${_failed[@]}"; do
            echo "   ${ICON_ERR} $f"
        done
    fi
    echo "$SEPARATOR"
}

parse_args "$@"
require_admin_rights
main
