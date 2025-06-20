
# ----------------------------------------------
# Calendar & Clock Settings Configuration
# ----------------------------------------------
configure_calendar_clock_settings() {
    : '
    Configure GNOME calendar and clock settings.

    Description:
        - Show weekday and date in the top bar clock.
        - Enable week numbers display in the GNOME calendar.
        - Improve time and date visibility for better usability.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting calendar and clock settings configuration."
    echo "-----------------------------"

    # ---[ Step 1: Enable weekday and date display in clock ]---
    echo "[+] Enabling weekday display in clock..."
    set_gsetting "org.gnome.desktop.interface clock-show-weekday" true

    echo "[+] Enabling date display in clock..."
    set_gsetting "org.gnome.desktop.interface clock-show-date" true

    # ---[ Step 2: Enable week numbers in calendar ]---
    echo "[+] Enabling week numbers in calendar..."
    set_gsetting "org.gnome.desktop.calendar show-weekdate" true

    echo "[*] Calendar and clock settings configuration completed."
    echo "-----------------------------"
}

