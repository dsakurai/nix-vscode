#!/usr/bin/env bash
set -e

# Pass all arguments to nix develop
nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update