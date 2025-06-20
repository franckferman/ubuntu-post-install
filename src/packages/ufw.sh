
# ----------------------------------------------
# UFW Configuration
# ----------------------------------------------
configure_ufw() {
    : '
    Configure Uncomplicated Firewall (UFW) settings.

    Description:
        - Enables UFW if it is not already active.
        - Sets default firewall rules: deny all incoming traffic, allow all outgoing traffic.
        - Ensures a basic secure firewall setup.

    Args:
        None

    Returns:
        None (exits with script continuation).
    '

    echo "-----------------------------"
    echo "[*] UFW configuration process initiated."
    echo "-----------------------------"

    # ---[ Step 1: Ensure UFW is active ]---
    if ! sudo ufw status | grep -q "^Status: active"; then
        echo "[+] UFW is inactive. Enabling..."
        sudo ufw --force enable  # --force prevents confirmation prompt
    else
        echo "[=] UFW is already active."
    fi

    # ---[ Step 2: Apply default firewall policies ]---
    echo "[+] Setting up default UFW rules..."

    sudo ufw default deny incoming  # Block all incoming traffic by default
    sudo ufw default allow outgoing  # Allow outgoing traffic by default

    # ---[ Step 3: Display UFW status summary ]---
    echo "[*] UFW configuration completed successfully."
    echo "[=] Current UFW status:"
    sudo ufw status verbose  # Show active rules and status

    echo "-----------------------------"
}

