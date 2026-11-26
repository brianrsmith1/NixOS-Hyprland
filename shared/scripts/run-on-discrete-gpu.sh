#!/usr/bin/env bash
# Launch one application on the non-default Mesa GPU (RX 6500M on this Z16).
# Keep the desktop/iGPU as the default to preserve battery life.
set -euo pipefail
if [[ $# -eq 0 ]]; then
  echo "Usage: run-on-discrete-gpu <command> [args...]"
  exit 2
fi
exec env DRI_PRIME=1 "$@"
