#!/usr/bin/env bash
set -u

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

cat >"$tmp_file"

notify_tmux() {
  if [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1; then
    tmux display-message "$1" 2>/dev/null || true
  fi
}

try_copy() {
  local name="$1"
  shift

  if "$@" <"$tmp_file"; then
    notify_tmux "Copied to system clipboard with $name"
    exit 0
  fi
}

if command -v wl-copy >/dev/null 2>&1 && [ -n "${WAYLAND_DISPLAY:-}" ]; then
  try_copy "wl-copy" wl-copy
fi

if command -v xclip >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  try_copy "xclip" xclip -selection clipboard
fi

if command -v xsel >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
  try_copy "xsel" xsel --clipboard --input
fi

notify_tmux "System clipboard unavailable; copied to tmux buffer only"
exit 1
