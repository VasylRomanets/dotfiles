#!/bin/bash

# macOS only — security(1) and launchctl(1) are Apple-specific
[[ "$(uname)" == "Darwin" ]] || exit 0

# reads a secret from the macOS Keychain and injects it into the launchd user
# session; this makes the variable available to all processes launched after login,
# including GUI apps that never open a shell (e.g. Unity Package Manager).
#
# Add a secret to the Keychain before using this script:
#   security add-generic-password -a "$(whoami)" -s "your-service-name" -w "your-secret-value"
load_secret() {
    local env_var="$1" service="$2"
    local secret
    secret=$(security find-generic-password -a "$(whoami)" -s "$service" -w 2>/dev/null)
    [[ -n "$secret" ]] && launchctl setenv "$env_var" "$secret"
}

# UPM reads .upmconfig.toml as a static file - token = "$UPM_GITHUB_PAT" is not expanded;
# I preserved this in a separate branch for future reference.
# load_secret UPM_GITHUB_PAT "upm-github-pat" # Unity Package Manager
