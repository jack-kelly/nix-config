#!/usr/bin/env bash
# One-stop updater: run every package's own update.sh under ./pkgs.
#
# Discovers pkgs/*/update.sh and runs each in turn. A failure in one package
# is reported but doesn't stop the others; the overall exit status is non-zero
# if any updater failed.
set -uo pipefail

cd "$(dirname "$0")"

rc=0
for script in */update.sh; do
  [ -e "$script" ] || continue  # no matches -> literal glob, skip
  pkg=$(dirname "$script")
  echo "=== updating $pkg ==="
  if bash "$script"; then
    echo
  else
    echo "!!! $pkg update failed (exit $?)" >&2
    echo
    rc=1
  fi
done

exit $rc
