#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

SKIP_PACKAGES=0
SKIP_GIT=0
SKIP_ZSH=0
SKIP_TMUX=0
SKIP_NVIM=0
SKIP_CHSH=0
SKIP_ZINIT=0
SKIP_TPM=0
SKIP_NEOVIM=0
SKIP_LAZYGIT=0
SKIP_LFS_INSTALL=0

usage() {
  cat <<EOF
Usage: $0 [options]

Deploy Linux dotfiles for Ubuntu/Debian systems.

Options:
  --skip-packages       Skip apt package installation in all modules
  --skip-git            Skip Git config installation
  --skip-zsh            Skip Zsh config installation
  --skip-tmux           Skip tmux config installation
  --skip-nvim           Skip Neovim config installation
  --skip-chsh           Do not change the default shell to zsh
  --skip-zinit          Do not install zinit
  --skip-tpm            Do not install tmux plugin manager/plugins
  --skip-neovim         Do not install latest Neovim
  --skip-lazygit        Do not install or check lazygit
  --skip-lfs-install    Do not run git lfs install
  -h, --help            Show this help message

Examples:
  $0
  $0 --skip-chsh
  $0 --skip-packages --skip-zinit --skip-tpm --skip-neovim --skip-lazygit --skip-lfs-install --skip-chsh
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-packages)
      SKIP_PACKAGES=1
      ;;
    --skip-git)
      SKIP_GIT=1
      ;;
    --skip-zsh)
      SKIP_ZSH=1
      ;;
    --skip-tmux)
      SKIP_TMUX=1
      ;;
    --skip-nvim)
      SKIP_NVIM=1
      ;;
    --skip-chsh)
      SKIP_CHSH=1
      ;;
    --skip-zinit)
      SKIP_ZINIT=1
      ;;
    --skip-tpm)
      SKIP_TPM=1
      ;;
    --skip-neovim)
      SKIP_NEOVIM=1
      ;;
    --skip-lazygit)
      SKIP_LAZYGIT=1
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

detected_arch() {
  printf '%s' "${DOTFILES_TEST_ARCH:-$(uname -m)}"
}

preflight() {
  local machine

  if ! command -v apt-get >/dev/null 2>&1; then
    printf 'apt-get not found. This installer targets Ubuntu/Debian systems.\n' >&2
    exit 1
  fi

  if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}:${ID_LIKE:-}" in
      *ubuntu*|*debian*)
        ;;
      *)
        printf 'Unsupported Linux distribution: %s %s\n' "${NAME:-unknown}" "${VERSION_ID:-}" >&2
        printf 'This installer targets Ubuntu/Debian systems.\n' >&2
        exit 1
        ;;
    esac
  fi

  machine="$(detected_arch)"
  case "$machine" in
    x86_64|amd64|aarch64|arm64)
      ;;
    *)
      printf 'Unsupported architecture: %s\n' "$machine" >&2
      printf 'Supported architectures: x86_64, amd64, aarch64, arm64\n' >&2
      exit 1
      ;;
  esac

  printf 'Preflight OK: %s on %s\n' "${PRETTY_NAME:-Ubuntu/Debian}" "$machine"
}

section() {
  printf '\n==> %s\n' "$1"
}

run_module() {
  local name="$1"
  shift

  section "$name"
  if "$@"; then
    printf 'Completed: %s\n' "$name"
  else
    local status=$?
    printf 'Failed: %s (exit %s)\n' "$name" "$status" >&2
    exit "$status"
  fi
}

append_common_args() {
  local -n args_ref="$1"

  if [ "$SKIP_PACKAGES" -eq 1 ]; then
    args_ref+=(--skip-packages)
  fi
}

install_git() {
  local args=()
  append_common_args args

  if [ "$SKIP_LFS_INSTALL" -eq 1 ]; then
    args+=(--skip-lfs-install)
  fi

  "$SCRIPT_DIR/git/install.sh" "${args[@]}"
}

install_zsh() {
  local args=()
  append_common_args args

  if [ "$SKIP_ZINIT" -eq 1 ]; then
    args+=(--skip-zinit)
  fi
  if [ "$SKIP_CHSH" -eq 1 ]; then
    args+=(--skip-chsh)
  fi

  "$SCRIPT_DIR/zsh/install.sh" "${args[@]}"
}

install_tmux() {
  local args=()
  append_common_args args

  if [ "$SKIP_TPM" -eq 1 ]; then
    args+=(--skip-tpm)
  fi

  "$SCRIPT_DIR/tmux/install.sh" "${args[@]}"
}

install_nvim() {
  local args=()
  append_common_args args

  if [ "$SKIP_NEOVIM" -eq 1 ]; then
    args+=(--skip-neovim)
  fi
  if [ "$SKIP_LAZYGIT" -eq 1 ]; then
    args+=(--skip-lazygit)
  fi

  "$SCRIPT_DIR/nvim/install.sh" "${args[@]}"
}

print_next_steps() {
  cat <<EOF

Linux dotfiles deployment complete.

Next steps:
  1. Open a new login shell so zsh, chsh, and PATH changes take effect.
  2. Verify tools:
       git --version
       tmux -V
       nvim --version
  3. Start Neovim once and let lazy.nvim install plugins:
       nvim
EOF
}

main() {
  preflight

  if [ "$SKIP_GIT" -eq 0 ]; then
    run_module "Git" install_git
  else
    printf '\nSkipping Git module.\n'
  fi

  if [ "$SKIP_ZSH" -eq 0 ]; then
    run_module "Zsh" install_zsh
  else
    printf '\nSkipping Zsh module.\n'
  fi

  if [ "$SKIP_TMUX" -eq 0 ]; then
    run_module "tmux" install_tmux
  else
    printf '\nSkipping tmux module.\n'
  fi

  if [ "$SKIP_NVIM" -eq 0 ]; then
    run_module "Neovim" install_nvim
  else
    printf '\nSkipping Neovim module.\n'
  fi

  print_next_steps
}

main "$@"
