#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${PS5_LINUX_REPO_URL:-https://ps5linux.bugbounty.zip}"
KEYRING="/etc/apt/keyrings/ps5-linux-archive-keyring.gpg"
SOURCE_LIST="/etc/apt/sources.list.d/ps5-linux.list"
KEY_URL="$REPO_URL/keys/ps5-linux-archive-key.asc"
INRELEASE_URL="$REPO_URL/deb/InRelease"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: curl -fsSL $REPO_URL/install.sh | sudo bash" >&2
  exit 1
fi

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need curl
need gpg
need mktemp

install -d -m 0755 /etc/apt/keyrings

echo "Checking PS5 Linux apt repository..."
if ! curl -fsSL "$INRELEASE_URL" >/dev/null; then
  echo "Signed apt metadata is not published yet: $INRELEASE_URL" >&2
  exit 1
fi

echo "Installing PS5 Linux apt signing key..."
tmp_key="$(mktemp)"
trap 'rm -f "$tmp_key"' EXIT
curl -fsSL "$KEY_URL" -o "$tmp_key"
gpg --dearmor --yes -o "$KEYRING" "$tmp_key"
chmod 0644 "$KEYRING"

echo "Installing PS5 Linux apt source..."
cat > "$SOURCE_LIST" <<EOF
deb [arch=amd64 signed-by=$KEYRING] $REPO_URL/deb ./
EOF

echo "Repository installed:"
cat "$SOURCE_LIST"
echo
echo "Next:"
echo "  sudo apt update"
echo "  sudo apt install --reinstall linux-ps5"
