
# ----------------------------------------------
# GNOME Terminal Settings Configuration
# ----------------------------------------------
configure_gnome_terminal_settings() {
    : '
    Configure GNOME Terminal preferences.

    Description:
        - Rename the default GNOME Terminal profile to "root".
        - Disable system theme colors to apply custom colors.
        - Set custom foreground and background colors for better readability.
        - Enable transparency using the theme settings.
        - Set a custom color palette for consistent terminal appearance.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting GNOME Terminal preferences configuration."
    echo "-----------------------------"

    # ---[ Step 1: Retrieve default profile ID ]---
    echo "[*] Retrieving the ID of the default terminal profile..."
    default_profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
    default_profile=${default_profile:1:-1}  # Remove leading and trailing single quotes

    # ---[ Step 2: Rename profile and adjust color settings ]---
    echo "[+] Renaming the default profile to 'root'..."
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/visible-name "'root'"

    echo "[+] Disabling basic system theme (use-theme-colors)..."
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/use-theme-colors false

    echo "[+] Setting custom foreground and background colors..."
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/foreground-color "'rgb(208,207,204)'"
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/background-color "'rgb(23,20,33)'"

    # ---[ Step 3: Enable transparency ]---
    echo "[+] Enabling transparency (theme transparency)..."
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/use-theme-transparency true

    # ---[ Step 4: Set custom color palette ]---
    echo "[+] Setting up the color palette..."
    dconf write /org/gnome/terminal/legacy/profiles:/:$default_profile/palette "['rgb(23,20,33)', 'rgb(192,28,40)', 'rgb(38,162,105)', 'rgb(162,115,76)', 'rgb(18,72,139)', 'rgb(163,71,186)', 'rgb(42,161,179)', 'rgb(208,207,204)', 'rgb(94,92,100)', 'rgb(246,97,81)', 'rgb(51,209,122)', 'rgb(233,173,12)', 'rgb(42,123,222)', 'rgb(192,97,203)', 'rgb(51,199,222)', 'rgb(255,255,255)']"

    echo "[*] GNOME Terminal preferences configuration completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# GNOME Shell & Text Editor Settings Configuration
# ----------------------------------------------
configure_gnome_shell_text_editor_settings() {
    : '
    Configure GNOME Shell favorites and GNOME Text Editor settings.

    Description:
        - Set favorite applications in GNOME Shell (Dock).
        - Customize GNOME Text Editor appearance and usability:
          line numbers, right margin, dark theme, grid pattern, line highlight,
          disable spellcheck, and enable text wrapping.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting GNOME Shell favorites and Text Editor configuration."
    echo "-----------------------------"

    # ---[ Step 1: Configure GNOME Shell favorite applications ]---
    echo "[+] Setting favorite applications in GNOME Shell..."
    set_gsetting "org.gnome.shell favorite-apps" "['firefox_firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']"

    # ---[ Step 2: Configure GNOME Text Editor settings ]---
    echo "[+] Enabling line numbers in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor show-line-numbers" true

    echo "[+] Enabling right margin in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor show-right-margin" true

    echo "[+] Applying dark theme to GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor style-variant" "'dark'"
    set_gsetting "org.gnome.TextEditor style-scheme" "'classic-dark'"

    echo "[+] Enabling grid pattern and line highlight in Text Editor..."
    set_gsetting "org.gnome.TextEditor highlight-current-line" true
    set_gsetting "org.gnome.TextEditor show-grid" true

    echo "[+] Disabling spellcheck in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor spellcheck" false

    echo "[+] Enabling text wrapping in GNOME Text Editor..."
    set_gsetting "org.gnome.TextEditor wrap-text" true

    echo "[*] GNOME Shell favorites and Text Editor configuration completed."
    echo "-----------------------------"
}

