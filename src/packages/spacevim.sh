
# ----------------------------------------------
# Install SpaceVim
# ----------------------------------------------
install_spacevim() {
    : '
    Installs SpaceVim, a community-driven modular Vim distribution.

    Description:
        - Check for internet connectivity and curl presence before proceeding.
        - Download and execute the official SpaceVim installation script.
        - Provide feedback on success or failure.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting SpaceVim installation."
    echo "-----------------------------"

    # ---[ Step 1: Check for Internet Connectivity ]---
    if ! check_internet_connectivity; then
        echo "[!] No internet connection. Skipping SpaceVim installation."
        echo "-----------------------------"
        return
    fi
    echo "[+] Internet connection confirmed."

    # ---[ Step 2: Check if curl is installed ]---
    if ! command -v curl &>/dev/null; then
        echo "[!] curl is required but not installed. Skipping SpaceVim installation."
        echo "-----------------------------"
        return
    fi

    # ---[ Step 3: Download and Run SpaceVim Installer ]---
    echo "[+] Downloading and running the SpaceVim installer..."
    if curl -sLf https://spacevim.org/install.sh | bash; then
        echo "[=] SpaceVim installed successfully."
    else
        echo "[!] SpaceVim installation failed. Please check your connection or the installer URL."
    fi

    echo "-----------------------------"
}

