
# ----------------------------------------------
# Zsh Customization (Powerlevel10k + Plugins)
# ----------------------------------------------
custom_zsh() {
    : '
    Customize Zsh with Powerlevel10k theme and various Zsh plugins.

    Description:
        - Ensure Zsh is installed and set as the default shell.
        - Install Powerlevel10k theme if not already present.
        - Install key Zsh plugins (autosuggestions, syntax highlighting, completions).
        - Configure the .zshrc file to use the theme and plugins.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Zsh customization."
    echo "-----------------------------"

    # ---[ Step 1: Save current shell ]---
    local original_shell="$SHELL"

    # ---[ Step 2: Ensure Zsh is installed ]---
    if ! command -v zsh &> /dev/null; then
        echo "[!] Zsh is not installed. Please install Zsh first."
        echo "-----------------------------"
        return
    fi

    # ---[ Step 3: Check Internet connectivity ]---
    if ! check_internet_connectivity; then
        echo "[!] Internet connectivity is required. Skipping Zsh customization."
        echo "-----------------------------"
        return
    fi

    # ---[ Step 4: Change default shell to Zsh if needed ]---
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "[+] Changing default shell to Zsh..."
        if sudo chsh -s "$(which zsh)" "$USER"; then
            echo "[=] Default shell changed to Zsh."
        else
            echo "[!] Failed to change default shell to Zsh."
        fi
    else
        echo "[=] Zsh is already the default shell."
    fi

    # ---[ Step 5: Install Powerlevel10k Theme ]---
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ ! -d "$p10k_dir" ]; then
        echo "[+] Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" || echo "[!] Failed to clone Powerlevel10k."
    else
        echo "[=] Powerlevel10k is already installed."
    fi

    # ---[ Step 6: Set Powerlevel10k as Zsh Theme ]---
    if grep -q '^ZSH_THEME=' ~/.zshrc; then
        echo "[+] Setting Powerlevel10k as Zsh theme..."
        sed -i 's/^ZSH_THEME="[^"]*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> ~/.zshrc
    fi

    # ---[ Step 7: Install Zsh Plugins ]---
    echo "[+] Installing Zsh plugins..."
    local plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    declare -A plugins=(
        ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
        ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
        ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
    )

    for plugin in "${!plugins[@]}"; do
        local plugin_path="$plugins_dir/$plugin"
        if [ ! -d "$plugin_path" ]; then
            echo "[+] Installing $plugin..."
            git clone --depth=1 "${plugins[$plugin]}" "$plugin_path" || echo "[!] Failed to clone $plugin."
        else
            echo "[=] $plugin already installed."
        fi
    done

    # ---[ Step 8: Add Plugins to .zshrc ]---
    if grep -q '^plugins=' ~/.zshrc; then
        echo "[+] Updating plugins list in .zshrc..."
        sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc
    else
        echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)" >> ~/.zshrc
    fi

    echo "[*] Zsh customization completed."
    echo "-----------------------------"
}


# ----------------------------------------------
# Update Zsh Plugins
# ----------------------------------------------
update_zsh_plugins() {
    : '
    Update the Zsh configuration (.zshrc) with a predefined set of plugins.

    Description:
        - Add a large set of useful Zsh plugins for productivity and development.
        - Preserve essential plugins (zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
          if already present in the current configuration.
        - Ensure there are no duplicates in the final plugin list.
        - Backup the existing .zshrc before applying changes.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Zsh plugins update."
    echo "-----------------------------"

    local zshrc="$HOME/.zshrc"

    # ---[ Step 1: Verify .zshrc exists ]---
    if [ ! -f "$zshrc" ]; then
        echo "[!] No .zshrc file found. Skipping plugin update."
        echo "-----------------------------"
        return
    fi

    # ---[ Step 2: Define list of desired plugins ]---
    local plugins_to_add=(
        git aliases autopep8 aws colored-man-pages colorize command-not-found
        common-aliases compleat copybuffer copyfile copypath cp docker
        docker-compose emoji emoji-clock emotty encode64 extract fancy-ctrl-z
        fbterm genpass git-commit git-escape-magic gitignore git-prompt golang
        history hitokoto httpie jsontools kubectl kubectx lol man nmap pip
        qrcode python rust sublime sudo systemadmin systemd taskwarrior terraform
        themes timer tmux tmuxinator torrent transfer ubuntu ufw urltools
        vagrant vscode web-search
    )

    # ---[ Step 3: Preserve essential plugins if present ]---
    for essential_plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
        if grep -q "$essential_plugin" "$zshrc"; then
            plugins_to_add+=("$essential_plugin")
        fi
    done

    # ---[ Step 4: Remove duplicates ]---
    mapfile -t plugins_to_add < <(printf "%s\n" "${plugins_to_add[@]}" | sort -u)

    # ---[ Step 5: Backup existing .zshrc ]---
    cp "$zshrc" "$zshrc.bak"
    echo "[=] Backup of .zshrc created at $zshrc.bak"

    # ---[ Step 6: Build plugins line ]---
    local formatted_plugins
    formatted_plugins="plugins=(${plugins_to_add[*]})"

    # ---[ Step 7: Update or add plugins list in .zshrc ]---
    if grep -q "^plugins=" "$zshrc"; then
        echo "[+] Updating existing plugins list..."
        sed -i "s/^plugins=(.*)/$formatted_plugins/" "$zshrc"
    else
        echo "[+] Adding plugins list to .zshrc..."
        echo -e "\n$formatted_plugins" >> "$zshrc"
    fi

    echo "[*] Zsh plugins updated successfully."
    echo "-----------------------------"
}


# ----------------------------------------------
# Update Zsh Aliases
# ----------------------------------------------
update_zsh_aliases() {
    : '
    Update the Zsh configuration (.zshrc) with a new set of custom aliases.

    Description:
        - Safely remove any existing block of custom aliases marked between # >>> and # <<<.
        - Add an updated set of useful custom aliases for productivity and system management.
        - Backup the existing .zshrc file before making any changes.

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting Zsh aliases update."
    echo "-----------------------------"

    local zshrc="$HOME/.zshrc"

    # ---[ Step 1: Check if .zshrc exists ]---
    if [ ! -f "$zshrc" ]; then
        echo "[!] No .zshrc file found. Skipping aliases update."
        echo "-----------------------------"
        return
    fi

    # ---[ Step 2: Backup existing .zshrc ]---
    cp "$zshrc" "$zshrc.bak"
    echo "[=] Backup of .zshrc created at $zshrc.bak"

    # ---[ Step 3: Remove existing alias block ]---
    sed -i '/# >>> CUSTOM ALIASES >>>/,/# <<< CUSTOM ALIASES <<</d' "$zshrc"

    # ---[ Step 4: Define new alias block ]---
    local new_aliases=$(cat << 'EOF'
# >>> CUSTOM ALIASES >>>
# Custom Aliases
alias calc='bc -l'
alias getrand='openssl rand -base64 42'
alias untar='tar -zxvf'
alias ..='cd ..'
alias cd..='cd ..'
alias la='lsd -A'
alias ls='lsd'
alias l='lsd'
alias ldir='lsd -l | grep -E '\''^d'\'' --color=never'
alias less='less -R'
alias lf='lsd -l | grep -E -v '\''^d'\'''
alias lk='lsd -lSrh'
alias ll='lsd -alFh'
alias lm='lsd -alh | more'
alias lr='lsd -lRh'
alias lt='lsd -ltrh'
alias lx='lsd -lXh'
alias mem='free -m -l -t'
alias ports='sudo netstat -tulanp'
alias psmem='ps auxf | sort -nr -k 4'
alias shpubip='curl http://ipecho.net/plain; echo'
alias checkmv='curl https://am.i.mullvad.net/connected'
alias city='curl https://am.i.mullvad.net/city'
alias country='curl https://am.i.mullvad.net/country'
alias df='df -h'
alias du='du -h'
alias dmesg='dmesg --human'
alias zulu="zuluCrypt-gui"
alias zulucli="zuluCrypt-cli"
alias biggest='du -h --max-depth=1 | sort -h'
alias countfiles='bash -c "for t in files links directories; do echo \$(find . -type \${t:0:1} | wc -l) \$t; done 2> /dev/null"'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias diskspace='du -S | sort -n -r |more'
alias folders='du -h --max-depth=1'
alias follow='tail -f -n +1'
alias ipview='netstat -anpl | grep :80 | awk {'\''print $5'\''} | cut -d":" -f1 | sort | uniq -c | sort -n | sed -e '\''s/^ *//'\'' -e '\''s/ *$//'\'''
alias iso='cat /etc/dev-rel | awk -F '\''='\'' '\''/ISO/ {print }'\'''
alias j='jobs'
alias jctl='journalctl -p 3 -xb'
alias logs='sudo find /var/log -type f -exec file {} \; | grep '\''text'\'' | cut -d'\'' '\'' -f1 | sed -e'\''s/:$//g'\'' | grep -v '\''[0-9]$'\'' | xargs tail -f'
alias mkdir='mkdir -p'
alias mountedinfo='df -hT'
alias open='xdg-open'
alias openports='netstat -nape --inet'
# <<< CUSTOM ALIASES <<<
EOF
)

    # ---[ Step 5: Append new aliases to .zshrc ]---
    echo "$new_aliases" >> "$zshrc"
    echo "[+] Custom aliases successfully added to .zshrc."

    echo "-----------------------------"
}


# ----------------------------------------------
# Copy Powerlevel10k Configuration from URL
# ----------------------------------------------
copy_p10k_config() {
    : '
    Downloads and applies the Powerlevel10k (.p10k.zsh) configuration file
    from a remote URL (Pastebin RAW link).

    Description:
        - Check for internet connectivity before attempting download.
        - Backup existing .p10k.zsh if already present.
        - Download and apply new .p10k.zsh from specified URL.

    Args:
        None

    Returns:
        0 if download succeeds, 1 if failed (e.g., no internet or URL error).
    '

    echo "-----------------------------"
    echo "[*] Starting Powerlevel10k configuration setup."
    echo "-----------------------------"

    local p10k_url="https://pastebin.com/raw/U3g4iaPw"
    local target="$HOME/.p10k.zsh"

    # ---[ Step 1: Check for Internet connection ]---
    if ! check_internet_connectivity; then
        echo "[!] No internet connection. Cannot download Powerlevel10k configuration."
        echo "-----------------------------"
        return 1
    fi

    # ---[ Step 2: Backup existing .p10k.zsh if found ]---
    if [ -f "$target" ]; then
        echo "[=] Existing .p10k.zsh found. Backing up to ${target}.bak"
        cp "$target" "${target}.bak"
    fi

    # ---[ Step 3: Download new .p10k.zsh from URL ]---
    echo "[+] Downloading .p10k.zsh from $p10k_url..."
    if curl -fsSL "$p10k_url" -o "$target"; then
        echo "[=] .p10k.zsh successfully downloaded and applied to $HOME/."
    else
        echo "[!] Failed to download .p10k.zsh. Check URL or connectivity."
        echo "-----------------------------"
        return 1
    fi

    echo "-----------------------------"
}

