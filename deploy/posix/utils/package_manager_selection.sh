# Return package manager priority for the current platform.
get_package_manager_priority() {
    case "${DEPLOY_PLATFORM:-}" in
        macos) printf '%s\n' "brew" ;;
        ubuntu) printf '%s\n' "apt" "dnf" "pacman" "brew" ;;
        termux) printf '%s\n' "pkg" ;;
        *)
            if [ -n "${PACKAGE_MANAGER:-}" ]; then
                printf '%s\n' "$PACKAGE_MANAGER"
            fi
            ;;
    esac
}

# Check whether a package manager is available on this machine.
check_package_manager_available() {
    local manager="$1"

    case "$manager" in
        brew | apt | dnf | pacman | pkg | flatpak)
            command -v "$manager" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}
