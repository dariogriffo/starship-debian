![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/starship-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/starship-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/starship-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/starship-debian?display_date=published_at)

# starship for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [starship](https://github.com/starship/starship) hosted at [deb.griffo.io](https://deb.griffo.io)

<p align="center">
⭐⭐⭐ Love using starship on Debian? Show your support by starring this repo or [subscribing](https://buy.stripe.com/aFa28q8hr0lRdlm4a2enS01) — access to this repository requires a yearly subscription. ⭐⭐⭐
</p>

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

**Upstream architectures:** amd64, arm64, armhf, i386 and riscv64. No ppc64el, s390x or armel.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the starship source code, see
[starship](https://github.com/starship/starship).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-starship-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-starship-in-ubuntu.html)

### The Debian way

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y starship
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/starship-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <starship_version> <build_version> <architecture>
# Example: ./build.sh 1.2.3 1 arm64
```

### Build for all architectures
```sh
./build.sh <starship_version> <build_version> all
# Example: ./build.sh 1.2.3 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64, armhf, i386, riscv64)

## Disclaimer

- This repo is not open for issues related to starship. This repo is only for _unofficial_ Debian packaging.
