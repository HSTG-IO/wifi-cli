# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[SemVer](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-10-16

### Added
- Interactive scan → select → connect flow (`wifi`).
- Non-interactive `wifi <ssid> <password>` for first-boot scripts; `NONE` for open networks.
- `status`, `disable`, `forget` subcommands; `-i` to pick an interface.
- systemd-networkd backend with a shipped `80-wifi-cli.network` (DHCP, route metric 600).
- Automatic `nmcli` fallback when NetworkManager manages the interface.
- Interface autodetection via `iw dev`, with `/sys/class/net` fallback for legacy drivers.
- Generated supplicant config stores the PSK hash only, mode 0600.
- Debian (`.deb`), RPM, and Arch (`PKGBUILD`) packaging; `make install` for everything else.
- Man page `wifi(8)`.
