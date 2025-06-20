
# ----------------------------------------------
# System Update
# ----------------------------------------------
perform_system_update() {
    : '
    Perform a full system update if internet connectivity is available.

    Description:
        - Verifies internet connectivity using check_internet_connectivity().
        - If connected, updates package lists, upgrades packages, and removes unnecessary packages.
        - If no internet is detected, skips the update process gracefully.

    Args:
        None

    Returns:
        None (continues script execution regardless of update outcome).
    '

    echo "-----------------------------"
    echo "[*] System update process initiated."
    echo "-----------------------------"

    # ---[ Step 1: Check internet connectivity before updating ]---
    if check_internet_connectivity; then
        echo -e "\n[+] Internet connectivity confirmed. Proceeding with system updates..."

        # ---[ Step 2: Update package lists ]---
        echo -e "\n[+] Updating package lists (apt update)..."
        sudo apt update

        # ---[ Step 3: Upgrade all packages ]---
        echo -e "\n[+] Upgrading all packages (apt full-upgrade)..."
        sudo apt full-upgrade -y

        # ---[ Step 4: Clean up partial and unnecessary files ]---
        echo -e "\n[+] Cleaning up package cache (apt autoclean)..."
        sudo apt autoclean -y  # Remove retrieved package files no longer needed

        # ---[ Step 5: Remove unused packages and dependencies ]---
        echo -e "\n[+] Removing unused packages (apt autoremove)..."
        sudo apt autoremove -y  # Remove packages installed as dependencies but no longer needed

        echo -e "\n✅ System update process completed successfully."
    else
        echo -e "\n⚠️ Skipping system update: No internet connection detected."
    fi

    echo "-----------------------------"
}


# ----------------------------------------------
# Disable a Specific systemd Service
# ----------------------------------------------
disable_service() {
    : '
    Disable a specified systemd service if currently enabled.

    Description:
        - Checks if the given systemd service is enabled.
        - If enabled, disables it to prevent automatic startup.
        - If already disabled, takes no action.

    Args:
        $1 (string): Name of the systemd service to disable (e.g., "bluetooth.service").

    Returns:
        None
    '

    local service="$1"

    echo "[+] Ensuring $service is disabled..."

    # ---[ Step 1: Check if service is enabled ]---
    if sudo systemctl is-enabled "$service" &>/dev/null; then
        # ---[ Step 2: Disable the service if needed ]---
        echo "[+] Disabling $service..."
        sudo systemctl disable "$service"
    else
        echo "[=] $service is already disabled."
    fi
}


# ----------------------------------------------
# Remove a Specified Package Using apt
# ----------------------------------------------
remove_package() {
    : '
    Remove a specified package using apt if installed.

    Description:
        - Check if the given package is installed on the system.
        - If installed, remove it completely using apt with --purge to delete configuration files.
        - If not installed, do nothing.

    Args:
        $1 (string): Name of the package to remove (e.g., "vim", "bluetooth").

    Returns:
        None
    '

    local package="$1"

    echo "[+] Ensuring $package is not installed..."

    # ---[ Step 1: Check if package is installed ]---
    if dpkg -s "$package" &>/dev/null; then
        # ---[ Step 2: Remove the package if present ]---
        echo "[+] Removing $package..."
        sudo apt remove --purge -y "$package"
    else
        echo "[=] $package is already not installed."
    fi
}


# ----------------------------------------------
# System Hardening Configuration
# ----------------------------------------------
configure_hardening() {
    : '
    Perform system hardening by disabling unnecessary services,
    removing dangerous packages, and applying essential security measures.

    Description:
        - Disable the root account to prevent direct login.
        - Install USBGuard if internet connection is available.
        - Disable dangerous and unnecessary system services.
        - Remove unused and risky packages that may expose vulnerabilities.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting system hardening configuration."
    echo "-----------------------------"

    # ---[ Step 1: Disable root account ]---
    echo "[+] Disabling root account..."
    sudo passwd -l root  # To re-enable: sudo passwd -u root

    # ---[ Step 2: Install security tools if connected to the Internet ]---
    if check_internet_connectivity; then
        echo "[+] Internet connectivity confirmed. Installing security tools..."
        echo "[+] Installing usbguard..."
        sudo apt install usbguard -y
    else
        echo "[!] Skipping security tools installation (no internet connection)."
    fi

    # ---[ Step 3: Disable unnecessary and dangerous services ]---
    echo "[*] Disabling unnecessary services..."
    local services=(
        slapd nfs-server rpcbind bind9 vsftpd apache2 dovecot exim
        cyrus-imap smbd squid snmpd postfix sendmail rsync nis
    )
    for service in "${services[@]}"; do
        disable_service "$service"
    done

    # ---[ Step 4: Remove unnecessary and risky packages ]---
    echo "[*] Removing dangerous or useless packages..."
    local packages=(
        nis rsh-client rsh-redone-client talk telnet ldap-utils
    )
    for package in "${packages[@]}"; do
        remove_package "$package"
    done

    echo "[*] System hardening completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Install a .deb Package from URL
# ----------------------------------------------
install_deb_from_url() {
    : '
    Download and install a .deb package from a provided URL.

    Description:
        - Check for internet connectivity before attempting download.
        - Download the specified .deb package using curl.
        - Install the package using dpkg and attempt to fix broken dependencies if needed.
        - Clean up the downloaded .deb file after installation.

    Args:
        url (string): URL to the .deb file to be downloaded and installed.

    Returns:
        0 if installation succeeds, 1 if failed or no internet.
    '

    local url="$1"
    local deb_name

    echo "-----------------------------"
    echo "[*] Attempting to install .deb package from URL: $url"
    echo "-----------------------------"

    # ---[ Step 1: Check Internet Connectivity ]---
    if ! check_internet_connectivity; then
        echo "[!] No internet connectivity. Skipping installation from $url."
        echo "-----------------------------"
        return 1
    fi

    echo "[+] Internet connectivity confirmed. Downloading package..."

    # ---[ Step 2: Download the .deb Package ]---
    if curl -LO "$url"; then
        deb_name=$(basename "$url")
        echo "[+] Downloaded $deb_name."

        # ---[ Step 3: Install the .deb Package ]---
        echo "[+] Installing $deb_name..."
        if sudo dpkg -i "$deb_name"; then
            echo "[+] $deb_name installed successfully."
        else
            echo "[!] Installation failed. Attempting to fix dependencies..."
            sudo apt install -f -y
        fi

        # ---[ Step 4: Cleanup Downloaded File ]---
        echo "[+] Cleaning up temporary file..."
        rm -f "$deb_name"
        echo "[=] Temporary file $deb_name removed."
    else
        echo "[!] Failed to download $url. Skipping."
    fi

    echo "-----------------------------"
}


