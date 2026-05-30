# PS5 Linux Package Repository

APT package repository for PS5 Linux kernel packages.

PS5 Linux users can add this repository once, then receive `linux-ps5` updates with:

```bash
sudo apt update
sudo apt upgrade
```

## What It Provides

- `linux-ps5` Debian packages
- apt metadata for `sudo apt update`
- public archive key for package verification
- install script for apt-based PS5 Linux systems

## Project Structure

```text
public/
  index.html              # GitHub Pages entrypoint
  install.sh              # User install command target
  assets/
    css/                  # Split by tokens, base, layout, components, pages
    js/                   # Small ES modules for UI behavior
  deb/                    # Published apt repository metadata and .deb files
  keys/                   # Public archive key
packages/
  deb/                    # Source .deb packages before publishing
scripts/
  build-deb-repo.sh       # Generates apt metadata
```

## Install

Run this inside an apt-based PS5 Linux install:

```bash
curl -fsSL https://ps5linux.bugbounty.zip/install.sh | sudo bash
sudo apt update
sudo apt install --reinstall linux-ps5
```

The install script exits without changing apt sources until signed metadata and the public archive key are published.

## Links

- Website: https://ps5linux.bugbounty.zip/
- Packages: https://ps5linux.bugbounty.zip/deb/
- Public key: https://ps5linux.bugbounty.zip/keys/ps5-linux-archive-key.asc
