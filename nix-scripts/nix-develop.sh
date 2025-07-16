#!/usr/bin/env bash
set -e

# the directory of this script: https://stackoverflow.com/questions/39340169/dir-cd-dirname-bash-source0-pwd-how-does-that-work
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Pass all arguments to nix develop
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes "$SCRIPT_DIR" "$@"
