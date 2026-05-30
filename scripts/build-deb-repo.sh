#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_DIR="${PKG_DIR:-$ROOT_DIR/packages/deb}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/public/deb}"
KEY_DIR="${KEY_DIR:-$ROOT_DIR/public/keys}"
KEY_FPR="${APT_SIGNING_KEY_FPR:-}"
KEY_PASSPHRASE="${APT_SIGNING_KEY_PASSPHRASE:-}"

if [ -z "$KEY_FPR" ]; then
  KEY_FPR="$(gpg --batch --with-colons --list-secret-keys 2>/dev/null | awk -F: '$1 == "fpr" { print $10; exit }')"
fi

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need dpkg-scanpackages
need apt-ftparchive
need gzip
need gpg

mkdir -p "$OUT_DIR"

echo "Syncing .deb packages..."
find "$OUT_DIR" -maxdepth 1 -type f -name '*.deb' -delete
if compgen -G "$PKG_DIR/*.deb" >/dev/null; then
  cp -f "$PKG_DIR"/*.deb "$OUT_DIR"/
else
  echo "No .deb packages found in $PKG_DIR" >&2
fi

cd "$OUT_DIR"

rm -f InRelease Release Release.gpg

echo "Building Packages index..."
dpkg-scanpackages --multiversion . /dev/null > Packages
perl -0pi -e 's/\n+\z/\n/' Packages
gzip -kf Packages

echo "Building Release metadata..."
tmp_release="$(mktemp)"
apt-ftparchive release . > "$tmp_release"
mv "$tmp_release" Release

if [ -n "$KEY_FPR" ]; then
  echo "Signing Release with key $KEY_FPR..."
  sign_args=(--batch --yes --default-key "$KEY_FPR")
  if [ -n "$KEY_PASSPHRASE" ]; then
    sign_args+=(--pinentry-mode loopback --passphrase "$KEY_PASSPHRASE")
  fi
  gpg "${sign_args[@]}" --clearsign --output InRelease Release
  gpg "${sign_args[@]}" -abs --output Release.gpg Release

  echo "Exporting public archive key..."
  mkdir -p "$KEY_DIR"
  gpg --batch --yes --armor --export "$KEY_FPR" > "$KEY_DIR/ps5-linux-archive-key.asc"
else
  echo "Warning: APT_SIGNING_KEY_FPR is not set; Release is unsigned." >&2
  echo "Apt clients will reject this repo unless InRelease/Release.gpg are generated." >&2
fi

echo "Done: $OUT_DIR"
