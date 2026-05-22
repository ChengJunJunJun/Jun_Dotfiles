#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"
ZSHRC_TARGET="$SCRIPT_DIR/.zshrc"
ZSHRC_LINK="$HOME/.zshrc"
STARSHIP_TARGET="$DOTFILES_ROOT/Linux/config/starship.toml"
STARSHIP_LINK="$HOME/.config/starship.toml"
ZINIT_HOME="$HOME/.local/share/zinit"
ZINIT_REPO="$ZINIT_HOME/zinit.git"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

SKIP_PACKAGES=0
SKIP_ZINIT=0
SKIP_CHSH=0

usage() {
  printf 'Usage: %s [--skip-packages] [--skip-zinit] [--skip-chsh]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-packages)
      SKIP_PACKAGES=1
      ;;
    --skip-zinit)
      SKIP_ZINIT=1
      ;;
    --skip-chsh)
      SKIP_CHSH=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    printf 'sudo is required to install packages. Please install sudo or run as root.\n' >&2
    exit 1
  fi
}

install_packages() {
  local packages=(zsh git curl ca-certificates)
  local missing=()
  local package

  if ! command -v apt-get >/dev/null 2>&1; then
    printf 'apt-get not found. This installer targets Ubuntu/Debian systems.\n' >&2
    exit 1
  fi

  for package in "${packages[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
      missing+=("$package")
    fi
  done

  if [ "${#missing[@]}" -eq 0 ]; then
    printf 'All required packages are already installed.\n'
    return
  fi

  printf 'Installing packages: %s\n' "${missing[*]}"
  run_as_root apt-get update
  run_as_root apt-get install -y "${missing[@]}"
}

resolved_path() {
  realpath -m "$1"
}

link_points_to() {
  local link_path="$1"
  local target_path="$2"
  local current_target
  local current_resolved

  [ -L "$link_path" ] || return 1
  current_target="$(readlink "$link_path")"

  case "$current_target" in
    /*)
      current_resolved="$(resolved_path "$current_target")"
      ;;
    *)
      current_resolved="$(resolved_path "$(dirname "$link_path")/$current_target")"
      ;;
  esac

  [ "$current_resolved" = "$(resolved_path "$target_path")" ]
}

backup_path() {
  local path="$1"
  local backup="${path}.backup.${TIMESTAMP}"
  local index=1

  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="${path}.backup.${TIMESTAMP}.${index}"
    index=$((index + 1))
  done

  mv "$path" "$backup"
  printf 'Backed up %s -> %s\n' "$path" "$backup"
}

ensure_link() {
  local target_path="$1"
  local link_path="$2"
  local link_parent

  link_parent="$(dirname "$link_path")"
  mkdir -p "$link_parent"

  if link_points_to "$link_path" "$target_path"; then
    ln -sfn "$target_path" "$link_path"
    printf 'Link already exists: %s -> %s\n' "$link_path" "$target_path"
    return
  fi

  if [ -e "$link_path" ] || [ -L "$link_path" ]; then
    backup_path "$link_path"
  fi

  ln -s "$target_path" "$link_path"
  printf 'Created link: %s -> %s\n' "$link_path" "$target_path"
}

install_zinit() {
  mkdir -p "$ZINIT_HOME"

  if [ -d "$ZINIT_REPO/.git" ]; then
    printf 'Zinit already installed: %s\n' "$ZINIT_REPO"
  elif [ -e "$ZINIT_REPO" ]; then
    printf 'Zinit path exists but is not a git repository: %s\n' "$ZINIT_REPO" >&2
    exit 1
  else
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_REPO"
  fi

  if [ -L "$ZINIT_HOME/zinit.zsh" ]; then
    rm "$ZINIT_HOME/zinit.zsh"
    printf 'Removed legacy zinit entry symlink: %s\n' "$ZINIT_HOME/zinit.zsh"
  fi
}

change_default_shell() {
  local zsh_path
  local current_shell

  if [ "$SKIP_CHSH" -eq 1 ]; then
    return
  fi

  zsh_path="$(command -v zsh || true)"
  if [ -z "$zsh_path" ]; then
    printf 'zsh command not found. Run without --skip-packages to install it.\n' >&2
    return
  fi

  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [ "$current_shell" = "$zsh_path" ]; then
    printf 'Default shell already set to: %s\n' "$zsh_path"
    return
  fi

  if chsh -s "$zsh_path" "$USER"; then
    printf 'Default shell changed to: %s\n' "$zsh_path"
  else
    printf 'Unable to change default shell automatically. Run manually: chsh -s %s %s\n' "$zsh_path" "$USER" >&2
  fi
}

main() {
  if [ "$SKIP_PACKAGES" -eq 0 ]; then
    install_packages
  fi

  ensure_link "$ZSHRC_TARGET" "$ZSHRC_LINK"
  ensure_link "$STARSHIP_TARGET" "$STARSHIP_LINK"

  if [ "$SKIP_ZINIT" -eq 0 ]; then
    install_zinit
  fi

  change_default_shell

  printf 'Zsh config installation complete.\n'
  printf 'Open a new login session for default shell changes to take effect.\n'
}

main "$@"
