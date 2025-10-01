#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${GITHUB_WORKSPACE:-}${VSCODE_WORKSPACE_FOLDER:-}"
# Fallbacks: VS Code typically mounts workspace at /workspaces/<name> in container
if [ -z "$REPO_DIR" ]; then
  if [ -d "/workspaces" ]; then
    # pick first workspace subdir (common for multi-root)
    REPO_DIR="/workspaces/$(basename $(pwd))"
  else
    REPO_DIR="$(pwd)"
  fi
fi

echo "Workspace dir: $REPO_DIR"
cd "$REPO_DIR"

# Ensure git is available. If not, try to install via sudo/apt-get.
if ! command -v git >/dev/null 2>&1; then
  echo "git not found in image, attempting to install via sudo apt-get..."
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y --no-install-recommends git ca-certificates curl || true
  else
    echo "sudo not found; cannot install git automatically. Please install git in the container or modify the image."
  fi
fi

if [ ! -d "BOSL2" ]; then
  echo "Cloning BOSL2 into $REPO_DIR/BOSL2..."
  git clone https://github.com/revarbat/BOSL2 BOSL2 || echo "git clone failed"
else
  echo "BOSL2 already present, skipping clone."
fi

# Ensure OPENSCADPATH includes this BOSL2 folder so OpenSCAD finds libraries
PROFILE="$HOME/.bashrc"
# Use a parameter expansion fallback so script works if OPENSCADPATH is unset
EXPORT_LINE="export OPENSCADPATH=\"$REPO_DIR/BOSL2:${OPENSCADPATH:-}\""

if ! grep -F "OPENSCADPATH" "$PROFILE" >/dev/null 2>&1; then
  echo "Adding OPENSCADPATH to $PROFILE"
  echo "# Added by devcontainer post-create: include BOSL2 for OpenSCAD" >> "$PROFILE"
  echo "$EXPORT_LINE" >> "$PROFILE"
else
  echo "OPENSCADPATH already configured in $PROFILE"
fi

echo "post-create finished"
