# Contributing

Thanks for taking a look. This is a small tool and should stay that way, so
the bar for new features is "does this make `wifi` easier for someone on a
headless box" — not "would it be neat."

## Reporting a bug

Open an issue with:

- distro and version (`cat /etc/os-release`)
- whether NetworkManager or systemd-networkd manages the interface
  (`networkctl list` / `nmcli device`)
- the adapter (`lsusb` or `lspci | grep -i net`) and driver (`lsmod`)
- the full output of `sudo wifi status` and the failing command
- `journalctl -u wpa_supplicant@<iface> -n 50` if the connection didn't come up

## Sending a change

1. Keep it POSIX-ish bash 4+. No Python, no compiled bits, no new runtime deps.
2. `make check` must pass. It runs `bash -n` and `shellcheck` if installed —
   CI runs shellcheck regardless, so install it locally or expect CI to complain.
3. If you touch `bin/wifi`, update `man/wifi.8` and `docs/INTERNALS.md` to match.
4. One change per PR. Add a line under **Unreleased** in `CHANGELOG.md`.

## Releasing (maintainers)

1. Bump the version in `debian/control`, `packaging/wifi-cli.spec`
   (`Version:` + `%changelog`), `packaging/PKGBUILD`, `man/wifi.8`, and
   `VERSION=` in `bin/wifi`. Move **Unreleased** to a dated heading.
2. `make deb rpm dist`, tag `vX.Y.Z`, push the tag.
3. CI attaches the `.deb`, `.rpm` and tarball to the GitHub Release.
4. Fill in `sha256sums` in `PKGBUILD` and push to the AUR.

## Scope: what this tool won't do

- Enterprise / 802.1X (EAP) networks. `wpa_supplicant` can do it; a
  `[CUSTOM]` option that drops you into writing the block yourself is the
  most this tool should offer.
- Access-point / hotspot mode.
- Replacing NetworkManager where it's already in charge. We call `nmcli`; we
  don't try to out-manage it.
