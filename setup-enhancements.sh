#!/usr/bin/env bash
set -euo pipefail

echo "setup-enhancements.sh is retained for v3 compatibility."
echo "v4 setup is handled by launch-novel.sh."
exec "$(dirname "$0")/launch-novel.sh" "$@"
