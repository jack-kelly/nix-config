hostname := `hostname`

# Show available recipes
default:
    @just --list

# Build the current host configuration
build:
    nh os build . --hostname {{hostname}}

# Build and switch to the current host configuration
switch:
    nh os switch . --hostname {{hostname}}

# Build and test (activate without adding boot entry)
test:
    nh os test . --hostname {{hostname}}

# Update flake inputs and switch
update-switch:
    nix flake update
    nh os switch . --hostname {{hostname}}

# Update flake inputs
update:
    nix flake update

# Garbage collect old generations (preserves direnv gcroots)
clean:
    nh clean all --keep 3 --no-gcroots

# Garbage collect everything, including direnv gcroots
clean-all:
    nh clean all --keep 3

# Format nix files
fmt:
    treefmt .

# Run flake checks
check:
    nix flake check

# Show flake inputs
inputs:
    nix flake metadata

# List available hosts
hosts:
    @ls -1 host/*/configuration.nix | sed 's|host/||;s|/configuration.nix||'

# Wipe TARGET and install HOST onto it over SSH (target booted into any NixOS installer)
install host target:
    #!/usr/bin/env bash
    set -euo pipefail
    [ -f "host/{{host}}/disko.nix" ] || { echo "host/{{host}}/disko.nix not found: nixos-anywhere needs a disko layout" >&2; exit 1; }
    echo "This ERASES the disk on {{target}} and installs {{host}}."
    read -rp "Type the hostname to continue: " confirm
    [ "$confirm" = "{{host}}" ] || { echo "aborted" >&2; exit 1; }
    read -rsp "LUKS passphrase: " pass; echo
    read -rsp "Again: " pass2; echo
    [ -n "$pass" ] && [ "$pass" = "$pass2" ] || { echo "passphrases empty or don't match" >&2; exit 1; }
    # /tmp/luks-password is the passwordFile every host's disko.nix reads.
    # printf, not echo: a trailing newline would become part of the key.
    nix run --inputs-from . nixpkgs#nixos-anywhere -- \
        --flake ".#{{host}}" \
        --disk-encryption-keys /tmp/luks-password <(printf %s "$pass") \
        "root@{{target}}"

# Show current NixOS generation
generation:
    nixos-rebuild list-generations | head -5
