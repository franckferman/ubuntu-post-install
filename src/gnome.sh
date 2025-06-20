# ----------------------------------------------
# GSettings Update Utility
# ----------------------------------------------
set_gsetting() {
    : '
    Update a gsettings key with a new value if different from the current value.

    Description:
        - Retrieves the current value of the specified gsettings key.
        - If the value differs from the provided value, update it.
        - Supports both string and numeric values.

    Args:
        key (str): The gsettings key to set.
        value (str): The value to assign to the key.

    Returns:
        None
    '

    local key=$1
    local value=$2
    local current_value

    echo -e "\n[*] Processing gsetting for key: $key"

    # ---[ Step 1: Get the current value of the gsettings key ]---
    current_value=$(gsettings get $key 2> /dev/null)

    # ---[ Step 2: Check if the key exists ]---
    if [ $? -ne 0 ]; then
        echo "[!] The key $key does not exist."
        return
    fi

    # ---[ Step 3: Update the key if necessary ]---
    if [ "$current_value" != "$value" ]; then
        echo "[+] Setting $key to $value."

        # Handle numeric values without quotes, otherwise quote strings
        if [[ "$value" =~ ^[0-9]+$ ]]; then
            gsettings set $key $value
        else
            gsettings set $key "$value"
        fi
    else
        echo "[=] $key is already set to $value."
    fi
}


# ----------------------------------------------
# GNOME Theme Configuration
# ----------------------------------------------
configure_theme() {
    : '
    Configure the GNOME desktop environment theme and background.

    Description:
        - Apply a dark color scheme preference.
        - Search for available GTK themes and apply a preferred theme ("Yaru-red-dark"),
          with a fallback to "Adwaita-dark" if available.
        - Set the desktop background color to solid black, adjusting primary and secondary
          colors if writable.
        - Clear background images to ensure a plain black desktop if supported.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting GNOME theme configuration."
    echo "-----------------------------"

    # ---[ Step 1: Apply dark color scheme preference ]---
    echo "[+] Applying dark color scheme..."
    set_gsetting "org.gnome.desktop.interface color-scheme" "'prefer-dark'"

    # ---[ Step 2: Search and apply available GTK themes ]---
    echo "[*] Searching for available GTK themes..."
    themes=$(ls -d /usr/share/themes/* 2>/dev/null | xargs -L 1 basename)

    if [ -z "$themes" ]; then
        echo "[!] No additional themes found. Skipping theme setup."
    else
        if echo "$themes" | grep -q "Yaru-red-dark"; then
            echo "[+] 'Yaru-red-dark' theme found. Applying it."
            set_gsetting "org.gnome.desktop.interface gtk-theme" "'Yaru-red-dark'"
        elif echo "$themes" | grep -q "Adwaita-dark"; then
            echo "[+] 'Yaru-red-dark' not found. Applying fallback 'Adwaita-dark' theme."
            set_gsetting "org.gnome.desktop.interface gtk-theme" "'Adwaita-dark'"
        else
            echo "[!] No suitable dark theme found. Theme remains unchanged."
        fi
    fi

    # ---[ Step 3: Set solid black as desktop background ]---
    echo "[*] Setting solid black as desktop background..."

    # Set primary and secondary colors to black if writable
    for key in primary-color secondary-color; do
        if gsettings writable org.gnome.desktop.background "$key" > /dev/null 2>&1; then
            echo "[+] Setting $key to black."
            set_gsetting "org.gnome.desktop.background.$key" "#000000"
        else
            echo "[!] Cannot write to $key. Skipping."
        fi
    done

    # Clear picture-uri and picture-uri-dark to ensure no background image
    for key in picture-uri picture-uri-dark; do
        if gsettings writable org.gnome.desktop.background "$key" > /dev/null 2>&1; then
            echo "[+] Clearing $key (no background image)."
            set_gsetting "org.gnome.desktop.background.$key" "''"
        else
            echo "[!] Cannot write to $key. Skipping."
        fi
    done

    echo "[*] GNOME theme configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# GNOME Ubuntu Desktop Configuration
# ----------------------------------------------
configure_ubuntu_desktop() {
    : '
    Configure the Ubuntu GNOME desktop environment (Dock, icons placement, etc.).

    Description:
        - Set new icons to appear in the top-left corner.
        - Adjust Dash to Dock settings: disable panel mode and set icon size.
        - Provides a consistent desktop appearance optimized for usability.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Ubuntu desktop configuration."
    echo "-----------------------------"

    # ---[ Step 1: Set new icons placement ]---
    echo "[+] Setting new icons to appear at the top-left corner."
    set_gsetting "org.gnome.shell.extensions.ding start-corner" "'top-left'"

    # ---[ Step 2: Disable panel mode (Dash to Dock) ]---
    echo "[+] Disabling panel mode (Dash to Dock)."
    set_gsetting "org.gnome.shell.extensions.dash-to-dock extend-height" false

    # ---[ Step 3: Set Dash to Dock icon size ]---
    echo "[+] Setting Dash to Dock icon size to 42."
    set_gsetting "org.gnome.shell.extensions.dash-to-dock dash-max-icon-size" 42

    echo "[*] Ubuntu desktop configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Privacy Settings Configuration
# ----------------------------------------------
configure_privacy_settings() {
    : '
    Configure privacy and security-related settings for GNOME on Ubuntu.

    Description:
        - Disable unnecessary connectivity checks and location services.
        - Configure screen lock and session timeout for security.
        - Set privacy-related preferences for files, trash, and temporary files.
        - Disable technical reporting, identity exposure, and usage statistics.
        - Disable remote desktop services (RDP, VNC).
        - Prevent storing of application usage data.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting privacy configuration."
    echo "-----------------------------"

    # ---[ Step 1: Disable connectivity checking ]---
    echo "[+] Disabling connectivity checking."
    busctl --system set-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager ConnectivityCheckEnabled "b" 0

    # ---[ Step 2: Configure screen lock and session idle settings ]---
    echo "[+] Configuring screen lock settings."
    set_gsetting "org.gnome.desktop.screensaver lock-enabled" true
    set_gsetting "org.gnome.desktop.screensaver lock-delay" "uint32 0"
    set_gsetting "org.gnome.desktop.screensaver idle-activation-enabled" true
    set_gsetting "org.gnome.desktop.session idle-delay" "uint32 300"

    # ---[ Step 3: Disable location services ]---
    echo "[+] Disabling location services."
    set_gsetting "org.gnome.system.location enabled" false

    # ---[ Step 4: Configure file history and recent files settings ]---
    echo "[+] Configuring file history settings."
    set_gsetting "org.gnome.desktop.privacy remember-recent-files" true
    set_gsetting "org.gnome.desktop.privacy recent-files-max-age" 1
    set_gsetting "org.gnome.desktop.privacy remember-recent-files" false  # Final state: disabled, minimal retention set before

    # ---[ Step 5: Enable automatic cleanup of old files ]---
    echo "[+] Enabling automatic removal of old trash and temporary files."
    set_gsetting "org.gnome.desktop.privacy remove-old-trash-files" true
    set_gsetting "org.gnome.desktop.privacy remove-old-temp-files" true

    echo "[+] Setting old files age to 0 (immediate cleanup)."
    set_gsetting "org.gnome.desktop.privacy old-files-age" "uint32 0"

    # ---[ Step 6: Disable technical reports and usage stats ]---
    echo "[+] Disabling technical problem reports."
    set_gsetting "org.gnome.desktop.privacy report-technical-problems" false

    echo "[+] Disabling software usage statistics."
    set_gsetting "org.gnome.desktop.privacy send-software-usage-stats" false

    # ---[ Step 7: Hide user identity ]---
    echo "[+] Hiding user identity."
    set_gsetting "org.gnome.desktop.privacy hide-identity" true

    # ---[ Step 8: Disable remote desktop services ]---
    echo "[+] Disabling remote desktop services (RDP and VNC)."
    set_gsetting "org.gnome.desktop.remote-desktop.rdp enable" false
    set_gsetting "org.gnome.desktop.remote-desktop.vnc enable" false

    # ---[ Step 9: Prevent remembering app usage ]---
    echo "[+] Disabling remembering app usage."
    set_gsetting "org.gnome.desktop.privacy remember-app-usage" false

    echo "[*] Privacy configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Sound Settings Configuration
# ----------------------------------------------
configure_sound_settings() {
    : '
    Mute system output and disable microphone input for privacy.

    Description:
        - Mutes the Master audio output to ensure no sound is played.
        - Disables microphone input (Capture) to avoid unintended recording.
        - Applies system-wide audio privacy settings using amixer.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting sound configuration."
    echo "-----------------------------"

    # ---[ Step 1: Mute system output ]---
    echo "[+] Muting system output (Master)."
    amixer set Master mute

    # ---[ Step 2: Disable microphone input ]---
    echo "[+] Disabling microphone input (Capture)."
    amixer set Capture nocap

    echo "[*] Sound configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Power & Performance Settings Configuration
# ----------------------------------------------
configure_power_perfs_settings() {
    : '
    Configure power and performance settings, including timeouts and profiles.

    Description:
        - Set GNOME power profile to "performance" mode.
        - Enable screen dimming and power saver on low battery.
        - Adjust suspend and inactivity timeouts for both AC and battery.
        - Temporarily set suspend modes to configure timeouts properly,
          then restore them to "nothing" to disable automatic suspend.
        - Set logout delay for inactive sessions.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting power and performance configuration."
    echo "-----------------------------"

    # ---[ Step 1: Set performance power profile ]---
    echo "[+] Setting power profile to performance."
    set_gsetting "org.gnome.shell last-selected-power-profile" "'performance'"

    # ---[ Step 2: Enable screen dimming and battery saver ]---
    echo "[+] Enabling screen dimming."
    set_gsetting "org.gnome.settings-daemon.plugins.power idle-dim" true

    echo "[+] Enabling automatic power saver on low battery."
    set_gsetting "org.gnome.settings-daemon.plugins.power power-saver-profile-on-low-battery" true

    # ---[ Step 3: Temporarily set suspend mode to adjust timeouts ]---
    echo "[+] Temporarily enabling suspend to adjust timeout settings."
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type" "'suspend'"
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type" "'suspend'"

    # ---[ Step 4: Set logout delay and sleep timeouts ]---
    echo "[+] Setting logout delay to 2 hours."
    set_gsetting "org.gnome.desktop.screensaver logout-delay" "uint32 7200"

    echo "[+] Setting sleep inactive timeout to 2 hours (AC and battery)."
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout" 7200
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout" 7200

    # ---[ Step 5: Disable suspend after timeout configuration ]---
    echo "[+] Disabling suspend after timeout configuration."
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type" "'nothing'"
    set_gsetting "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type" "'nothing'"

    echo "[*] Power and performance configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Display & Interface Settings Configuration
# ----------------------------------------------
configure_display_settings() {
    : '
    Configure display and interface settings, including battery percentage and Night Light mode.

    Description:
        - Enable battery percentage display in the system tray.
        - Activate Night Light mode to reduce blue light automatically from sunset to sunrise.
        - Set Night Light color temperature for eye comfort.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting display and interface configuration."
    echo "-----------------------------"

    # ---[ Step 1: Enable battery percentage display ]---
    echo "[+] Enabling battery percentage display."
    set_gsetting "org.gnome.desktop.interface show-battery-percentage" true

    # ---[ Step 2: Enable and configure Night Light ]---
    echo "[+] Enabling Night Light (automatic from sunset to sunrise)."
    set_gsetting "org.gnome.settings-daemon.plugins.color night-light-enabled" true
    set_gsetting "org.gnome.settings-daemon.plugins.color night-light-schedule-automatic" true

    echo "[+] Setting Night Light temperature to 2700K."
    set_gsetting "org.gnome.settings-daemon.plugins.color night-light-temperature" "uint32 2700"

    echo "[*] Display and interface configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Keyboard Layout Settings Configuration
# ----------------------------------------------
configure_keyboard_settings() {
    : '
    Configure keyboard layout: Add French (AZERTY) if not already present.

    Description:
        - Check if the French (AZERTY) keyboard layout is already configured.
        - If not present, add French (AZERTY) and US layouts to the system input sources.
        - Ensures the user can switch between US and FR (AZERTY) layouts.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting keyboard layout configuration."
    echo "-----------------------------"

    # ---[ Step 1: Retrieve current input sources ]---
    local current_sources
    current_sources=$(gsettings get org.gnome.desktop.input-sources sources)

    # ---[ Step 2: Check if French (AZERTY) layout is already present ]---
    if echo "$current_sources" | grep -q "('xkb', 'fr+azerty')"; then
        echo "[=] French (AZERTY) keyboard layout is already present."
    else
        # ---[ Step 3: Add French (AZERTY) and US layouts ]---
        echo "[+] Adding French (AZERTY) and US keyboard layouts."
        set_gsetting "org.gnome.desktop.input-sources mru-sources" "[('xkb', 'fr+azerty'), ('xkb', 'us')]"
        set_gsetting "org.gnome.desktop.input-sources sources" "[('xkb', 'us'), ('xkb', 'fr+azerty')]"
    fi

    echo "[*] Keyboard layout configuration completed."
    echo "-----------------------------"
}

