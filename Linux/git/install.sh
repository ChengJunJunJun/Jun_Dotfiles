#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
GITCONFIG_TARGET="$SCRIPT_DIR/.gitconfig"
GITCONFIG_LINK="$HOME/.gitconfig"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

SKIP_PACKAGES=0
SKIP_LFS_INSTALL=0

usage() {
  printf 'Usage: %s [--skip-packages] [--skip-lfs-install]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-packages)
      SKIP_PACKAGES=1
      ;;
    --skip-lfs-install)
      SKIP_LFS_INSTALL=1
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
  local packages=(git git-lfs)
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

install_lfs_hooks() {
  if [ "$SKIP_LFS_INSTALL" -eq 1 ]; then
    return
  fi

  if ! command -v git-lfs >/dev/null 2>&1; then
    printf 'git-lfs is not available. Run without --skip-packages to install it.\n' >&2
    exit 1
  fi

  git lfs install
}

main() {
  if [ "$SKIP_PACKAGES" -eq 0 ]; then
    install_packages
  fi

  ensure_link "$GITCONFIG_TARGET" "$GITCONFIG_LINK"
  install_lfs_hooks

  printf 'Git config installation complete.\n'
  printf 'Global gitconfig: %s -> %s\n' "$GITCONFIG_LINK" "$GITCONFIG_TARGET"
}

main "$@"
