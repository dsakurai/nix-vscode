#!/usr/bin/env bash
set -e

if ! command -v nix >/dev/null 2>&1 ; then
  echo "Installing Nix..."
  # Standard command to install nix package manager
  curl -L https://nixos.org/nix/install | sh
  # Standard command to install nix package manager in the login script
  echo '. "$HOME/.nix-profile/etc/profile.d/nix.sh"' >> "$HOME/.bashrc"
fi

# Source nix for current shell
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

cd project # enter the project folder
../nix-scripts/nix-develop.sh # Install necessary packages from nix and set up environment variables
