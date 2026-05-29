#!/usr/bin/env bash
# Bump claude-code to the latest version published on npm and refresh
# the per-platform sha256 hashes by prefetching directly from Anthropic's CDN.
#
# Run from anywhere; edits ./default.nix in this script's directory.
set -euo pipefail

cd "$(dirname "$0")"

NPM_URL="https://registry.npmjs.org/@anthropic-ai/claude-code/latest"
BASE_URL="https://downloads.claude.ai/claude-code-releases"
PLATFORMS=(darwin-arm64 darwin-x64 linux-x64 linux-arm64)

latest=$(curl -sf --max-time 10 "$NPM_URL" | sed -n 's/.*"version":"\([^"]*\)".*/\1/p')
[ -n "$latest" ] || { echo "failed to fetch latest version from npm" >&2; exit 1; }

current=$(sed -n 's/.*version = "\([^"]*\)".*/\1/p' default.nix | head -1)
echo "current: $current"
echo "latest:  $latest"
[ "$current" = "$latest" ] && { echo "already up to date"; exit 0; }

sed -i.bak "s/version = \"$current\"/version = \"$latest\"/" default.nix

for p in "${PLATFORMS[@]}"; do
  echo "prefetching $p..."
  hash=$(nix-prefetch-url "$BASE_URL/$latest/$p/claude" 2>/dev/null | tail -1)
  [ -n "$hash" ] || { echo "failed to fetch hash for $p" >&2; mv default.nix.bak default.nix; exit 1; }
  awk -v p="$p" -v h="$hash" '
    /nativeHashes = \{/ { in_block=1 }
    in_block && $0 ~ "\"" p "\"" { sub(/= "[^"]*"/, "= \"" h "\"") }
    in_block && /\};/ { in_block=0 }
    { print }
  ' default.nix > default.nix.tmp && mv default.nix.tmp default.nix
done

rm -f default.nix.bak
echo "updated $current -> $latest"
