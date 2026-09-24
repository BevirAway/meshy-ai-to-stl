#!/bin/sh
# Downloads the Meshy decoder files into chrome-extension/vendor.
# macOS / Linux counterpart of setup-vendor.ps1.
set -eu

BASE_URL="${MESHY_DECODER_BASE_URL:-https://www.meshy.ai/pt-BR/resource/decrypt}"

root=$(cd "$(dirname "$0")" && pwd)
vendor="$root/chrome-extension/vendor"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but was not found." >&2
  exit 1
fi

mkdir -p "$vendor"

for name in mesh_loader.js mesh_loader.wasm; do
  url="$BASE_URL/$name"
  out="$vendor/$name"
  tmp="$out.download"
  echo "Downloading $url"
  if ! curl -fsSL --retry 3 -o "$tmp" "$url"; then
    rm -f "$tmp"
    echo "Download failed: $url" >&2
    exit 1
  fi
  size=$(wc -c < "$tmp" | tr -d ' ')
  if [ "$size" -le 0 ]; then
    rm -f "$tmp"
    echo "Downloaded file is empty: $out" >&2
    exit 1
  fi
  mv -f "$tmp" "$out"
  echo "Saved $out ($size bytes)"
done

echo "Vendor files are ready."
