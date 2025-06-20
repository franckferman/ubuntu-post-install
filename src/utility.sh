: '
Utility module for the Ubuntu post installation scripts.
These are general functions for things like escalating privilege and such.

Author          : Fabian POSCH
Original author : Franck FERMAN
Date            : 20/06/2025
Version         : 1.0.0
'


# ----------------------------------------------
# Root Privilege Verification
# ----------------------------------------------
require_admin_rights() {
    : '
    Ensure that the user has administrative (root) privileges for the entire script execution.

    Description:
        - Prompt for sudo password if not already active.
        - Exit immediately if sudo rights are unavailable.
        - Keep the sudo session alive during the whole script execution using a background process.

    Args:
        None

    Returns:
        Exits the script with code 1 if sudo privileges are unavailable.
        No explicit return value (implicit 0) if sudo access is granted and background refresh process starts successfully.
    '

    # ---[ Step 1: Initial sudo access check ]---
    # Prompt for sudo access. Exit if user cannot elevate privileges.
    if ! sudo -v; then
        echo "❌ This script requires administrative privileges. Please run it as a user with sudo rights."
        exit 1
    fi

    # ---[ Step 2: Keep sudo session alive in background ]---
    # Launch a background loop to refresh sudo timestamp every 60 seconds.
    # This prevents sudo from timing out during long script execution.
    # The loop will terminate when the main script process ends.
    while true; do
        sudo -n true      # Refresh sudo timestamp without prompting for password
        sleep 60          # Wait before refreshing again
        kill -0 "$$" || exit  # If main script is no longer running, exit this loop
    done 2>/dev/null &   # Run loop silently in background
}


# ----------------------------------------------
# Initial Banner Display
# ----------------------------------------------
show_banner() {
    : '
    Display a banner for the post-installation script.

    Description:
        Prints an ASCII art header to introduce the script when executed.
        Used for aesthetic and informational purposes at the start of execution.

    Args:
        None

    Returns:
        None
    '

    # ---[ Display ASCII art banner ]---
    # Decorative header to indicate script start.
    cat << "EOF"
     ,-O
    O(_)) Ubuntu post-install script
     `-O
EOF
}


# ----------------------------------------------
# Internet Connectivity Check
# ----------------------------------------------
check_internet_connectivity() {
    : '
    Check internet connectivity by pinging a specified host (default: 1.1.1.1).

    Description:
        Pings a given IP address or domain name to verify that the system
        has an active internet connection.
        By default, it uses Cloudflare DNS (1.1.1.1) if no host is provided.

    Args:
        $1 (string, optional): IP address or domain to ping. Defaults to 1.1.1.1.

    Returns:
        0 if the host is reachable (successful ping).
        1 if the host is unreachable (ping failed).
    '

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

