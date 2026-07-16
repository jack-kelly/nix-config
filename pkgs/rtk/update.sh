#!/usr/bin/env bash
# Bump rtk to the latest tagged release on GitHub and refresh both the source
# hash and the vendored-crates cargoHash.
#
# Run from anywhere; edits ./default.nix in this script's directory.
set -euo pipefail

cd "$(dirname "$0")"

REPO="rtk-ai/rtk"

latest=$(curl -sf --max-time 10 "https://api.github.com/repos/$REPO/releases/latest" \
  | sed -n 's/.*"tag_name":[[:space:]]*"v\{0,1\}\([^"]*\)".*/\1/p' | head -1)
[ -n "$latest" ] || { echo "failed to fetch latest release from GitHub" >&2; exit 1; }

current=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' default.nix | head -1)
[ -n "$current" ] || { echo "error: could not parse current version from default.nix" >&2; exit 1; }
echo "current: $current"
echo "latest:  $latest"
[ "$current" = "$latest" ] && { echo "already up to date"; exit 0; }

current_escaped="${current//./\\.}"
sed -i.bak "s/version = \"$current_escaped\"/version = \"$latest\"/" default.nix

# Source hash: NAR hash of the unpacked tag tarball (matches fetchFromGitHub).
echo "prefetching source..."
srchash=$(nix store prefetch-file --json --unpack \
  "https://github.com/$REPO/archive/refs/tags/v$latest.tar.gz" | sed -n 's/.*"hash":"\([^"]*\)".*/\1/p')
[ -n "$srchash" ] || { echo "failed to prefetch source" >&2; mv default.nix.bak default.nix; exit 1; }
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"$srchash\";|" default.nix

# cargoHash: force a mismatch, then read the correct hash out of the build error.
sed -i "s|cargoHash = \"sha256-[^\"]*\";|cargoHash = \"sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\";|" default.nix
echo "resolving cargoHash (this builds the vendor derivation)..."
got=$(nix build --no-link ".#rtk" 2>&1 | sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' | head -1)
[ -n "$got" ] || { echo "failed to resolve cargoHash" >&2; mv default.nix.bak default.nix; exit 1; }
sed -i "s|cargoHash = \"sha256-[^\"]*\";|cargoHash = \"$got\";|" default.nix

rm -f default.nix.bak
echo "updated $current -> $latest"

# rtk's `init -g` writes the hook/RTK.md/CLAUDE.md wiring that we hand-mirror
# in home/bundles/cli/claude.nix. If a new version changes what it expects,
# `--show` flags it here instead of silently drifting.
echo "checking hook compatibility against the new binary..."
out=$(nix build --no-link --print-out-paths ".#rtk")
if "$out/bin/rtk" init -g --show 2>&1 | grep -q '\[warn\]'; then
  echo
  echo "!!! rtk flags our existing hook wiring as outdated:" >&2
  "$out/bin/rtk" init -g --show 2>&1 | grep '\[warn\]' >&2
  echo "!!! update the hand-authored settings.json/RTK.md/CLAUDE.md in home/bundles/cli/claude.nix to match." >&2
fi
