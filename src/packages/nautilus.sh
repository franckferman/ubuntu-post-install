
# ----------------------------------------------
# File Manager (Nautilus) Settings Configuration
# ----------------------------------------------
configure_file_manager_settings() {
    : '
    Configure GNOME Nautilus and FileChooser preferences.

    Description:
        - Sort directories first in file chooser dialogs.
        - Enable tree view in Nautilus list mode.
        - Show "Create Link" and "Delete Permanently" in context menus.
        - Enable recursive search, image thumbnails, and item counts.
        - Configure grid view captions (type, size, permissions).
        - Display hidden files everywhere (Nautilus and file chooser).

    Args:
        None

    Returns:
        None
    '

    echo "-----------------------------"
    echo "[*] Starting file manager preferences configuration."
    echo "-----------------------------"

    # ---[ Step 1: Sorting and FileChooser preferences ]---
    echo "[+] Sorting directories first in file chooser..."
    set_gsetting "org.gtk.Settings.FileChooser sort-directories-first" true
    set_gsetting "org.gtk.gtk4.Settings.FileChooser sort-directories-first" true

    # ---[ Step 2: Nautilus list view options ]---
    echo "[+] Enabling tree view in list mode..."
    set_gsetting "org.gnome.nautilus.list-view use-tree-view" true

    # ---[ Step 3: Context menu options ]---
    echo "[+] Enabling 'Create Link' in context menu..."
    set_gsetting "org.gnome.nautilus.preferences show-create-link" true

    echo "[+] Enabling 'Delete Permanently' in context menu..."
    set_gsetting "org.gnome.nautilus.preferences show-delete-permanently" true

    # ---[ Step 4: Search, thumbnails, and directory item counts ]---
    echo "[+] Enabling recursive search, image thumbnails, and directory item counts..."
    set_gsetting "org.gnome.nautilus.preferences recursive-search" "'always'"
    set_gsetting "org.gnome.nautilus.preferences show-image-thumbnails" "'always'"
    set_gsetting "org.gnome.nautilus.preferences show-directory-item-counts" "'always'"

    # ---[ Step 5: Icon view captions ]---
    echo "[+] Configuring grid view captions (type, size, permissions)..."
    set_gsetting "org.gnome.nautilus.icon-view captions" "['detailed_type', 'size', 'permissions']"

    # ---[ Step 6: Show hidden files everywhere ]---
    echo "[+] Enabling display of hidden files everywhere..."
    set_gsetting "org.gtk.Settings.FileChooser show-hidden" true
    set_gsetting "org.gtk.gtk4.Settings.FileChooser show-hidden" true
    set_gsetting "org.gnome.nautilus.preferences show-hidden-files" true

    echo "[*] File manager preferences configuration completed."
    echo "-----------------------------"
}

