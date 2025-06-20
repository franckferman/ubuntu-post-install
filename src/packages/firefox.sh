
# ----------------------------------------------
# Manage Firefox Profiles
# ----------------------------------------------
manage_firefox_profiles() {
    : '
    Manage Firefox profiles for a fresh and secured setup.

    Description:
        - Locate and delete existing Firefox profiles.
        - Create a new "root" profile for clean usage.
        - Launch Firefox with the new profile to initialize it.
        - Download and apply a custom user.js configuration file from a remote source (Pastebin RAW).

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Firefox profile management."
    echo "-----------------------------"

    # ---[ Step 1: Locate profile directory ]---
    local profiles_ini
    profiles_ini=$(find ~ -name 'profiles.ini' -print 2>/dev/null | head -n 1)

    if [[ -z "$profiles_ini" ]]; then
        echo "[!] No profiles.ini file found. Firefox might not be installed yet."
        echo "-----------------------------"
        return
    fi

    local profile_dir
    profile_dir=$(dirname "$profiles_ini")
    echo "[+] Profile directory found: $profile_dir"

    # ---[ Step 2: Delete old profiles ]---
    echo "[+] Deleting old profiles..."
    find "$profile_dir" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
    echo "[=] Old profiles removed."

    # ---[ Step 3: Create new 'root' profile ]---
    echo "[+] Creating 'root' profile..."
    if firefox -CreateProfile "root $profile_dir/root" >/dev/null 2>&1; then
        echo "[=] 'root' profile created."
    else
        echo "[!] Failed to create 'root' profile."
    fi

    # ---[ Step 4: Initialize profile by launching Firefox ]---
    echo "[+] Launching Firefox with 'root' profile to initialize it..."
    firefox -P "root" & disown
    sleep 5

    # ---[ Step 5: Close Firefox gracefully ]---
    echo "[+] Closing Firefox..."
    pkill -f "firefox -P root"

    # ---[ Step 6: Download and apply custom user.js ]---
    local user_js_url="https://pastebin.com/raw/ZX70EYvN"
    local user_js_dest="$profile_dir/root/user.js"

    echo "[+] Downloading user.js from $user_js_url..."
    if curl -fsSL "$user_js_url" -o "$user_js_dest"; then
        echo "[=] user.js downloaded and applied to root profile."
    else
        echo "[!] Failed to download user.js. Skipping custom configuration."
    fi

    echo "-----------------------------"
    echo "[*] Firefox profile management completed."
    echo "-----------------------------"
}

