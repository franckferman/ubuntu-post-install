#!/bin/bash

: '
Ubuntu Post-Installation Script

This script was originally developed on Ubuntu 23.10 (Mantic Minotaur),
and has also been tested and runs smoothly on Ubuntu 24.04 (Noble Numbat).
While it may work on other Ubuntu versions or derivatives,
full compatibility is only guaranteed on Ubuntu 23.10.

Author : Franck FERMAN
Date   : 06/12/2023
Version: 1.0.0
'

# include main components
. $(dirname "$0")/src/gnome.sh
. $(dirname "$0")/src/system.sh
. $(dirname "$0")/src/utility.sh

# include package components
. $(dirname "$0")/src/packages/gnome_calendar.sh
. $(dirname "$0")/src/packages/gnome_terminal.sh
. $(dirname "$0")/src/packages/nautilus.sh
. $(dirname "$0")/src/packages/ohmyzsh.sh
. $(dirname "$0")/src/packages/spacevim.sh
. $(dirname "$0")/src/packages/ufw.sh
. $(dirname "$0")/src/packages/zsh.sh


# ----------------------------------------------
# System Settings Global Configuration
# ----------------------------------------------
configure_system_settings() {
    : '
    Main function to configure all system settings.

    Description:
        - Apply global configuration for GNOME and Ubuntu desktop environment.
        - Covers appearance, privacy, performance, usability, and essential settings.
        - Calls all other dedicated configuration functions in a predefined order.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting system settings configuration."
    echo "-----------------------------"

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

    echo "[*] All system settings configurations completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Install Basic Applications and Useful Tools
# ----------------------------------------------
install_basic_apps() {
    : '
    Install a list of essential applications and tools for daily use.

    Description:
        - Install APT packages for system utilities, development, and productivity.
        - Refresh and install Snap packages, including classic confinement apps.
        - Check and install Mullvad VPN if not already present.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting basic application installation."
    echo "-----------------------------"

    # ---[ Step 1: Install APT Packages ]---
    local apt_packages=(
        nala zulucrypt-gui keepassxc vim git curl tmux mat2 rssguard
        python3 python3-pip python3-venv zsh taskwarrior net-tools
        # Optional GNOME apps (uncomment if needed):
        # gnome-software gnome-shell-extension-manager gnome-tweaks
        # hicolor-icon-theme gnome-menus desktop-file-utils gnome-maps
        # gnome-weather gnome-calendar gnome-clocks
    )

    echo "[+] Installing APT packages..."
    sudo apt update
    sudo apt install -y "${apt_packages[@]}"
    echo "[+] APT packages installed."

    # ---[ Step 2: Refresh and Install Snap Packages ]---
    echo "[+] Refreshing Snap packages..."
    sudo snap refresh

    local snap_packages=(
        "xmind --classic"
        "obsidian --classic"
        "lsd"
    )

    echo "[+] Installing Snap packages..."
    for snap_pkg in "${snap_packages[@]}"; do
        echo "[*] Installing $snap_pkg..."
        sudo snap install $snap_pkg
    done
    echo "[+] Snap packages installed."

    # ---[ Step 3: Install Mullvad VPN if not already installed ]---
    echo "[+] Checking Mullvad VPN installation..."
    if dpkg -s mullvad-vpn > /dev/null 2>&1; then
        echo "[=] Mullvad VPN is already installed. Skipping installation."
    else
        echo "[+] Installing Mullvad VPN..."
        install_deb_from_url "https://mullvad.net/download/app/deb/latest"
    fi

    echo "-----------------------------"
    echo "[*] Basic application installation completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Install Nerd Fonts
# ----------------------------------------------
install_nerd_fonts() {
    : '
    Install Nerd Fonts if the font directory exists.

    Description:
        - Check if the Nerd Fonts directory is available locally.
        - Copy all .ttf fonts from the source directory to the user fonts directory.
        - Refresh font cache if fonts were installed.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Nerd Fonts installation."
    echo "-----------------------------"

    local font_dir="assets/fonts/NerdFonts/"
    local target_dir="$HOME/.local/share/fonts/"

    # ---[ Step 1: Check if the Nerd Fonts directory exists ]---
    if [ ! -d "$font_dir" ]; then
        echo "[!] Nerd Fonts directory not found at $font_dir. Skipping installation."
        echo "-----------------------------"
        return
    fi
    echo "[+] Nerd Fonts directory found: $font_dir"

    # ---[ Step 2: Ensure target fonts directory exists ]---
    mkdir -p "$target_dir"

    # ---[ Step 3: Copy fonts and track installation success ]---
    local font_installed=false
    for font in "$font_dir"*.ttf; do
        if [ -f "$font" ]; then
            echo "[+] Installing font: $(basename "$font")"
            if cp "$font" "$target_dir"; then
                font_installed=true
            else
                echo "[!] Failed to install $(basename "$font")."
            fi
        fi
    done

    # ---[ Step 4: Update font cache if fonts were installed ]---
    if [ "$font_installed" = true ]; then
        echo "[+] Updating font cache..."
        fc-cache -f "$target_dir"
        echo "[=] Nerd Fonts installed and cache updated."
    else
        echo "[!] No .ttf fonts found in $font_dir. Nothing was installed."
    fi

    echo "-----------------------------"
}


# ----------------------------------------------
# Main Function - Post-Installation Script
# ----------------------------------------------
main() {
    : '
    Main function that orchestrates the entire post-installation process.

    Description:
        - Display banner and initialize the post-installation process.
        - Execute all configuration and installation steps in a defined order.
        - Provide feedback for each step and handle errors gracefully.

    Args:
        None

    Returns:
        None (Script exits with code 0 when completed)
    '

    clear
    show_banner
    echo

    echo ">>> Starting post-installation script <<<"

    # ---[ Step 1: Define ordered steps to execute ]---
    local steps=(
        "perform_system_update"
        "configure_ufw"
        "configure_system_settings"
        "configure_hardening"
        "install_basic_apps"
        "manage_firefox_profiles"
        "install_spacevim"
        "install_nerd_fonts"
        "install_ohmyzsh"
        "custom_zsh"
        "update_zsh_plugins"
        "update_zsh_aliases"
        "copy_p10k_config"
    )

    # ---[ Step 2: Execute each step and handle errors ]---
    for step in "${steps[@]}"; do
        echo -e "\n[*] Running: $step..."
        if ! $step; then
            echo "[!] Error during $step. Check logs."
            # Optional: Uncomment the next line if you want to stop on error
            # exit 1
        fi
    done

    # ---[ Step 3: Completion message ]---
    echo -e "\n>>> Post-installation script completed. <<<"
    exit 0
}

# ---[ Require root privileges before starting ]---
require_admin_rights
main

