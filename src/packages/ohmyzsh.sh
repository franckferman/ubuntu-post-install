
# ----------------------------------------------
# Install Oh My Zsh
# ----------------------------------------------
install_ohmyzsh() {
    : '
    Install Oh My Zsh, a community-driven framework for managing Zsh configuration.

    Description:
        - Check for internet connectivity and presence of Zsh.
        - Install Oh My Zsh unattended if not already installed.
        - Clear bash history for security.
        - Set Zsh as the default shell if not already set.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Oh My Zsh installation."
    echo "-----------------------------"

    # ---[ Step 1: Check for Internet Connectivity ]---
    if ! check_internet_connectivity; then
        echo "[!] Skipping Oh My Zsh installation: No internet connection."
        echo "-----------------------------"
        return
    fi
    echo "[+] Internet connectivity confirmed. Proceeding with Oh My Zsh installation."

    # ---[ Step 2: Check if Zsh is Installed ]---
    if ! command -v zsh &> /dev/null; then
        echo "[!] Zsh is not installed. Please install it first. Aborting."
        echo "-----------------------------"
        return
    fi

    # ---[ Step 3: Check and Install Oh My Zsh if Needed ]---
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "[=] Oh My Zsh is already installed. Skipping installation."
    else
        echo "[+] Installing Oh My Zsh..."

        if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
            echo "[+] Oh My Zsh installed successfully."
        else
            echo "[!] Oh My Zsh installation failed."
            echo "-----------------------------"
            return
        fi
    fi

    # ---[ Step 4: Clear Bash History for Security ]---
    echo "[+] Clearing bash history..."
    history -c
    rm -f ~/.bash_history

    # ---[ Step 5: Change Default Shell to Zsh if Needed ]---
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "[+] Changing default shell to Zsh..."
        if sudo chsh -s "$(which zsh)" "$USER"; then
            echo "[=] Default shell changed to Zsh."
        else
            echo "[!] Failed to change default shell to Zsh. You may need to do it manually."
        fi
    else
        echo "[=] Zsh is already the default shell."
    fi

    echo "[*] Oh My Zsh installation and configuration completed."
    echo "-----------------------------"
}

