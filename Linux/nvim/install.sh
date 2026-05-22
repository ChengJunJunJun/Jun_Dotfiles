#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd -P)"
NVIM_CONFIG_TARGET="$DOTFILES_ROOT/Linux/config/nvim"
NVIM_CONFIG_LINK="$HOME/.config/nvim"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

SKIP_PACKAGES=0
SKIP_NEOVIM=0
SKIP_LAZYGIT=0

usage() {
  printf 'Usage: %s [--skip-packages] [--skip-neovim] [--skip-lazygit]\n' "$0"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-packages)
      SKIP_PACKAGES=1
      ;;
    --skip-neovim)
      SKIP_NEOVIM=1
      ;;
    --skip-lazygit)
      SKIP_LAZYGIT=1
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
    printf 'sudo is required for this step. Please install sudo or run as root.\n' >&2
    exit 1
  fi
}

install_packages() {
  local packages=(
    git
    curl
    ca-certificates
    tar
    gzip
    unzip
    build-essential
    ripgrep
    fd-find
    nodejs
    python3-venv
    python3-pip
    wl-clipboard
    xclip
    xsel
  )
  local missing=()
  local package

  if ! command -v apt-get >/dev/null 2>&1; then
    printf 'apt-get not found. This installer targets Ubuntu/Debian systems.\n' >&2
    exit 1
  fi

  if ! command -v npm >/dev/null 2>&1; then
    packages+=(npm)
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

detect_nvim_asset_arch() {
  local machine
  machine="$(uname -m)"

  case "$machine" in
    x86_64|amd64)
      printf 'x86_64'
      ;;
    aarch64|arm64)
      printf 'arm64'
      ;;
    *)
      printf 'Unsupported architecture for official Neovim tarball: %s\n' "$machine" >&2
      exit 1
      ;;
  esac
}

install_neovim() {
  local asset_arch="$1"
  local install_dir="/opt/nvim-linux-${asset_arch}"
  local archive_name="nvim-linux-${asset_arch}.tar.gz"
  local download_url="https://github.com/neovim/neovim/releases/latest/download/${archive_name}"
  local tmpdir
  local archive
  local extracted_dir
  local status=0

  tmpdir="$(mktemp -d)"
  archive="$tmpdir/$archive_name"
  extracted_dir="$tmpdir/nvim-linux-${asset_arch}"

  printf 'Downloading latest Neovim: %s\n' "$download_url"
  curl -fL "$download_url" -o "$archive" || status=$?

  if [ "$status" -eq 0 ]; then
    tar -xzf "$archive" -C "$tmpdir" || status=$?
  fi

  if [ "$status" -eq 0 ] && [ ! -x "$extracted_dir/bin/nvim" ]; then
    printf 'Downloaded Neovim archive did not contain an executable nvim binary.\n' >&2
    status=1
  fi

  if [ "$status" -eq 0 ]; then
    run_as_root rm -rf "${install_dir}.tmp" || status=$?
  fi
  if [ "$status" -eq 0 ]; then
    run_as_root mkdir -p "$(dirname "$install_dir")" || status=$?
  fi
  if [ "$status" -eq 0 ]; then
    run_as_root cp -a "$extracted_dir" "${install_dir}.tmp" || status=$?
  fi
  if [ "$status" -eq 0 ]; then
    run_as_root rm -rf "$install_dir" || status=$?
  fi
  if [ "$status" -eq 0 ]; then
    run_as_root mv "${install_dir}.tmp" "$install_dir" || status=$?
  fi

  rm -rf "$tmpdir"

  if [ "$status" -ne 0 ]; then
    return "$status"
  fi

  printf 'Installed Neovim: %s\n' "$install_dir"
  "$install_dir/bin/nvim" --version | sed -n '1p'
}

ensure_fd_command() {
  local fdfind_path

  if command -v fd >/dev/null 2>&1; then
    printf 'fd command already available: %s\n' "$(command -v fd)"
    return
  fi

  if ! command -v fdfind >/dev/null 2>&1; then
    printf 'fd-find package is installed but fdfind command was not found.\n' >&2
    return
  fi

  fdfind_path="$(command -v fdfind)"
  ensure_link "$fdfind_path" "$HOME/.local/bin/fd"
}

install_lazygit() {
  if [ "$SKIP_LAZYGIT" -eq 1 ]; then
    return
  fi

  if command -v lazygit >/dev/null 2>&1; then
    printf 'lazygit already available: %s\n' "$(command -v lazygit)"
    return
  fi

  if command -v apt-cache >/dev/null 2>&1 && apt-cache show lazygit >/dev/null 2>&1; then
    printf 'Installing lazygit from apt sources.\n'
    run_as_root apt-get install -y lazygit
    return
  fi

  printf 'lazygit is not available from current apt sources.\n' >&2
  printf 'Install lazygit manually to enable the <leader>gg Neovim shortcut.\n' >&2
}

print_next_steps() {
  local asset_arch="$1"
  local nvim_bin_dir="/opt/nvim-linux-${asset_arch}/bin"

  printf '\nNext steps:\n'
  printf '  1. Open a new shell so zsh reloads PATH from Linux/zsh/config/environment.zsh.\n'
  printf '  2. Or update this shell now with: export PATH="%s:$PATH"\n' "$nvim_bin_dir"
  printf '  3. Start Neovim and let lazy.nvim install plugins: nvim\n'
}

main() {
  local asset_arch

  if [ ! -d "$NVIM_CONFIG_TARGET" ]; then
    printf 'Neovim config directory not found: %s\n' "$NVIM_CONFIG_TARGET" >&2
    exit 1
  fi

  asset_arch="$(detect_nvim_asset_arch)"

  if [ "$SKIP_PACKAGES" -eq 0 ]; then
    install_packages
  fi

  if [ "$SKIP_NEOVIM" -eq 0 ]; then
    install_neovim "$asset_arch"
  fi

  ensure_fd_command
  install_lazygit
  ensure_link "$NVIM_CONFIG_TARGET" "$NVIM_CONFIG_LINK"

  printf 'Neovim config installation complete.\n'
  printf 'Neovim config: %s -> %s\n' "$NVIM_CONFIG_LINK" "$NVIM_CONFIG_TARGET"
  print_next_steps "$asset_arch"
}

main "$@"
