#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG_DIR="$HOME/.config"
TMUX_CONFIG_LINK="$CONFIG_DIR/tmux"
TMUX_CONF_LINK="$HOME/.tmux.conf"
TMUX_CONF_TARGET="$TMUX_CONFIG_LINK/tmux.conf"
TMUX_PLUGINS_DIR="$TMUX_CONFIG_LINK/plugins"
TPM_DIR="$TMUX_PLUGINS_DIR/tpm"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

SKIP_PACKAGES=0
SKIP_TPM=0

usage() {
  printf 'Usage: %s [--skip-packages] [--skip-tpm]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-packages)
      SKIP_PACKAGES=1
      ;;
    --skip-tpm)
      SKIP_TPM=1
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
  local packages=(tmux git wl-clipboard xclip xsel)
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

install_tpm() {
  mkdir -p "$TMUX_PLUGINS_DIR"

  if [ -d "$TPM_DIR/.git" ]; then
    printf 'TPM already installed: %s\n' "$TPM_DIR"
    return
  fi

  if [ -e "$TPM_DIR" ]; then
    printf 'TPM path exists but is not a git repository: %s\n' "$TPM_DIR" >&2
    exit 1
  fi

  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
}

install_tmux_plugin() {
  local repo="$1"
  local plugin_name="${repo##*/}"
  local plugin_dir="$TMUX_PLUGINS_DIR/$plugin_name"
  local repo_url="https://github.com/${repo}.git"

  if [ -d "$plugin_dir/.git" ]; then
    printf 'Plugin already installed: %s\n' "$plugin_name"
    return
  fi

  if [ -e "$plugin_dir" ]; then
    printf 'Plugin path exists but is not a git repository: %s\n' "$plugin_dir" >&2
    exit 1
  fi

  git clone "$repo_url" "$plugin_dir"
}

install_tmux_plugins() {
  local plugin

  mkdir -p "$TMUX_PLUGINS_DIR"

  while IFS= read -r plugin; do
    install_tmux_plugin "$plugin"
  done < <(tmux_plugin_repos)
}

tmux_plugin_repos() {
  awk '
    /^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+@plugin[[:space:]]+/ {
      line = $0
      sub(/^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+@plugin[[:space:]]+/, "", line)
      sub(/[[:space:]]*#.*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      gsub(/^["'\'']|["'\'']$/, "", line)
      if (line != "tmux-plugins/tpm") {
        print line
      }
    }
  ' "$SCRIPT_DIR/tmux.conf"
}

print_next_steps() {
  printf '\nNext steps:\n'
  printf '  1. Reload tmux with: tmux source-file ~/.tmux.conf\n'
  printf '  2. Or restart the tmux server for a completely fresh load.\n'
  printf '  3. After reload, the left status bar should show TMUX plus the session list.\n'
}

main() {
  if [ "$SKIP_PACKAGES" -eq 0 ]; then
    install_packages
  fi

  mkdir -p "$CONFIG_DIR"
  ensure_link "$SCRIPT_DIR" "$TMUX_CONFIG_LINK"
  ensure_link "$TMUX_CONF_TARGET" "$TMUX_CONF_LINK"

  if [ "$SKIP_TPM" -eq 0 ]; then
    install_tpm
    install_tmux_plugins
  fi

  printf 'tmux config installation complete.\n'
  print_next_steps
}

main "$@"
