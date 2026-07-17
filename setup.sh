#!/usr/bin/env bash
# One-command bootstrap: clone this repo, run this script, selected modules
# (ghostty, lazygit, nvim, tmux) land on a fresh machine ready to use.
# Works on macOS and Linux.
#
# Usage: ./setup.sh [--only mod1,mod2 | --except mod1,mod2 | --all]
# No flags + interactive terminal: choose modules from a menu.
# Modules: ghostty, lazygit, tmux, nvim
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALL_MODULES=(ghostty lazygit tmux nvim)

usage() {
  cat <<EOF
Usage: $0 [--only mod1,mod2 | --except mod1,mod2 | --all]

No flags + interactive terminal: choose modules from a menu.
No flags + non-interactive (piped/CI): runs all modules.

Modules: ${ALL_MODULES[*]}
EOF
}

contains() {
  local needle="$1"; shift
  local x
  for x in "$@"; do [ "$x" = "$needle" ] && return 0; done
  return 1
}

ONLY_ARG=""
EXCEPT_ARG=""
ALL_FLAG=0

while [ $# -gt 0 ]; do
  case "$1" in
    --only=*) ONLY_ARG="${1#--only=}" ;;
    --only) shift; ONLY_ARG="${1:-}" ;;
    --except=*) EXCEPT_ARG="${1#--except=}" ;;
    --except) shift; EXCEPT_ARG="${1:-}" ;;
    --all) ALL_FLAG=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown argument: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [ -n "$ONLY_ARG" ] && [ -n "$EXCEPT_ARG" ]; then
  echo "ERROR: --only and --except are mutually exclusive" >&2
  exit 1
fi
if [ "$ALL_FLAG" -eq 1 ] && { [ -n "$ONLY_ARG" ] || [ -n "$EXCEPT_ARG" ]; }; then
  echo "ERROR: --all cannot be combined with --only/--except" >&2
  exit 1
fi

validate_modules() {
  local mod
  IFS=',' read -ra _mods <<< "$1"
  for mod in "${_mods[@]}"; do
    if ! contains "$mod" "${ALL_MODULES[@]}"; then
      echo "ERROR: unknown module '$mod' (valid: ${ALL_MODULES[*]})" >&2
      exit 1
    fi
  done
}

pick_modules() {
  local marks=()
  local i
  for i in "${!ALL_MODULES[@]}"; do marks[i]=1; done

  while true; do
    echo
    echo "Select modules (toggle by number, ENTER to confirm):"
    for i in "${!ALL_MODULES[@]}"; do
      if [ "${marks[i]}" -eq 1 ]; then
        echo "  [x] $((i+1)). ${ALL_MODULES[i]}"
      else
        echo "  [ ] $((i+1)). ${ALL_MODULES[i]}"
      fi
    done
    read -r -p "> " input
    if [ -z "$input" ]; then
      break
    elif [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le "${#ALL_MODULES[@]}" ]; then
      idx=$((input-1))
      if [ "${marks[idx]}" -eq 1 ]; then marks[idx]=0; else marks[idx]=1; fi
    else
      echo "Invalid input: $input"
    fi
  done

  SELECTED_MODULES=()
  for i in "${!ALL_MODULES[@]}"; do
    [ "${marks[i]}" -eq 1 ] && SELECTED_MODULES+=("${ALL_MODULES[i]}")
  done
}

SELECTED_MODULES=()
if [ -n "$ONLY_ARG" ]; then
  validate_modules "$ONLY_ARG"
  IFS=',' read -ra SELECTED_MODULES <<< "$ONLY_ARG"
elif [ -n "$EXCEPT_ARG" ]; then
  validate_modules "$EXCEPT_ARG"
  IFS=',' read -ra _except <<< "$EXCEPT_ARG"
  for mod in "${ALL_MODULES[@]}"; do
    contains "$mod" "${_except[@]}" || SELECTED_MODULES+=("$mod")
  done
elif [ "$ALL_FLAG" -eq 1 ]; then
  SELECTED_MODULES=("${ALL_MODULES[@]}")
elif [ -t 0 ]; then
  pick_modules
else
  echo "No flags and no interactive terminal — running all modules."
  SELECTED_MODULES=("${ALL_MODULES[@]}")
fi

if [ "${#SELECTED_MODULES[@]}" -eq 0 ]; then
  echo "No modules selected, nothing to do."
  exit 0
fi

echo
echo "Modules: ${SELECTED_MODULES[*]}"

OS="$(uname -s)"
case "$OS" in
  Darwin) IS_MAC=1 ;;
  Linux)  IS_MAC=0 ;;
  *) echo "ERROR: unsupported OS: $OS (only macOS and Linux)" >&2; exit 1 ;;
esac

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR: Homebrew not found. Install it first: https://brew.sh" >&2
  exit 1
fi

# --- per-module brew deps ---
BREW_PKGS=()
add_pkgs() {
  local pkg
  for pkg in "$@"; do
    contains "$pkg" "${BREW_PKGS[@]:-}" || BREW_PKGS+=("$pkg")
  done
}
contains "lazygit" "${SELECTED_MODULES[@]}" && add_pkgs git-delta lazygit
contains "nvim" "${SELECTED_MODULES[@]}" && add_pkgs neovim tree-sitter-cli imagemagick lazygit
contains "tmux" "${SELECTED_MODULES[@]}" && add_pkgs tmux

if [ "${#BREW_PKGS[@]}" -gt 0 ]; then
  echo
  echo "==> Installing Homebrew dependencies"
  for pkg in "${BREW_PKGS[@]}"; do
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      echo "    OK       $pkg"
    else
      echo "    installing $pkg"
      brew install "$pkg"
    fi
  done
fi

# --- module functions ---

setup_ghostty() {
  echo
  echo "==> ghostty"
  if [ "$IS_MAC" -eq 1 ]; then
    GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
    GHOSTTY_FILE="$GHOSTTY_DIR/config.ghostty"
  else
    GHOSTTY_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
    GHOSTTY_FILE="$GHOSTTY_DIR/config"
  fi
  mkdir -p "$GHOSTTY_DIR"
  echo "    Manual: copy the config block from $REPO_DIR/ghostty/ghostty.md into $GHOSTTY_FILE"
  echo "    (macos-option-as-alt line is macOS-only, drop it on Linux)"
}

setup_lazygit() {
  echo
  echo "==> lazygit"
  "$REPO_DIR/lazygit/scripts/restore-lazygit.sh"
}

setup_tmux() {
  echo
  echo "==> tmux"
  "$REPO_DIR/tmux/scripts/restore-tmux.sh"
}

setup_nvim() {
  echo
  echo "==> nvim"
  if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    echo "    live nvim config missing, cloning kickstart.nvim base"
    BASE_COMMIT="$(cat "$REPO_DIR/nvim/kickstart-base-commit.txt")"
    git clone https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"
    git -C "$HOME/.config/nvim" checkout "$BASE_COMMIT"
  fi
  "$REPO_DIR/nvim/scripts/restore-nvim.sh"
}

# --- dispatch ---
for mod in "${SELECTED_MODULES[@]}"; do
  "setup_$mod"
done

echo
echo "==> Bootstrap complete. Remaining manual steps:"
contains "ghostty" "${SELECTED_MODULES[@]}" && echo "  - ghostty: paste config block per instructions above (no CLI install path)"
contains "nvim" "${SELECTED_MODULES[@]}" && echo "  - nvim: open nvim, run :Lazy restore, then :Mason and install tools in nvim/mason-tools.txt"
contains "nvim" "${SELECTED_MODULES[@]}" && echo "  - nvim: image.nvim needs a Kitty-graphics terminal (Ghostty/Kitty/WezTerm) and, inside tmux, 'allow-passthrough on' in tmux.conf"
if contains "ghostty" "${SELECTED_MODULES[@]}" || contains "lazygit" "${SELECTED_MODULES[@]}"; then
  echo "  - Restart ghostty/lazygit — configs are not hot-reloaded"
fi
