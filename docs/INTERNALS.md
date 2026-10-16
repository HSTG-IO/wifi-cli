# Internals

Design notes for `wifi-cli`: what it does under the hood, why it's built this
way, and where it stops. The front-page [README](../README.md) covers install
and everyday use.

## Commands

| Command | What it does |
|---|---|
| `wifi` | Interactive scan → select → password → connect |
| `wifi <ssid> <password>` | Non-interactive connect (scriptable; `NONE` = open network) |
| `wifi status` | Link, state and address for the wireless interface |
| `wifi disable` | Stop and disable the supplicant unit; config is kept |
| `wifi forget` | Disable **and** delete the saved network config |
| `wifi -i wlp3s0 ...` | Target a specific interface instead of the first one found |

Exit codes: `0` connected, `1` bad input / missing hardware, `2` supplicant
started but no route within 20 s.

## How it works

Two back ends, picked automatically:

**systemd-networkd (default, headless servers / mining rigs / appliances)**

1. `iw dev <iface> scan` builds the SSID list.
2. `wpa_passphrase` writes `/etc/wpa_supplicant/wpa_supplicant-<iface>.conf`
   (PSK hash only — the plaintext passphrase line is stripped, mode 600).
3. Enables and restarts the stock `wpa_supplicant@<iface>` unit, which reads
   that file by name.
4. The shipped `/usr/lib/systemd/network/80-wifi-cli.network` matches
   `Type=wlan` and runs DHCP with `RouteMetric=600`, so a wired link still
   takes the default route when both are up.
5. Polls `networkctl status` until the interface is `routable`.

**NetworkManager (desktops, anything where NM already owns the interface)**

If `NetworkManager` is active and the interface isn't marked unmanaged, the
tool uses `nmcli device wifi connect` instead, so it never fights NM.

## Install

### From the .deb

```sh
sudo apt install ./wifi-cli_0.1.0_all.deb
```

Dependencies (`iw`, `wpasupplicant`) are pulled in by apt. The script will
also `apt-get install` them on first run if they're somehow absent.

### From source

```sh
sudo make install        # → /usr/sbin/wifi + .network file
sudo make uninstall
```

### Other distros (Fedora/RHEL/Arch/anything with systemd)

The script is plain bash over `iw` + `wpa_supplicant` + `systemd-networkd`;
nothing in it is Debian-specific. Install those two packages, then
`sudo make install`.

### Build packages

```sh
make deb                 # → build/wifi-cli_0.1.0_all.deb   (needs dpkg-deb only, no debhelper)
make rpm                 # → build/rpm/RPMS/noarch/wifi-cli-0.1.0-1.*.noarch.rpm  (needs rpmbuild)
make dist                # → build/wifi-cli-0.1.0.tar.gz  source tarball for anything else
```

Version is read from `debian/control`; keep `packaging/wifi-cli.spec` in step
when you bump it.

## Baking into an image

Drop the `.deb` into your image build and `apt install ./wifi-cli_*.deb`. On
first boot an operator can plug in a USB adapter, SSH or console in, type
`wifi`, and the node is on the network — no `nmtui`, no hand-written
`wpa_supplicant.conf`, no netplan YAML. For fully unattended provisioning, call
`wifi "$SSID" "$PASS"` from your first-boot script.

## Notes

- Runs as root. `sudo wifi` is fine; it checks and refuses otherwise.
- Legacy drivers that don't speak nl80211 (old Ralink `ra0`) are found via
  `/sys/class/net/*/wireless` but `iw scan` won't work on them — use
  `wifi <ssid> <pass>` or `[CUSTOM SSID]`.
- WPA3/SAE-only networks need `key_mgmt=SAE`; the tool currently generates
  WPA2-PSK config. Mixed-mode APs work fine.
- `wifi forget` on a NetworkManager system deletes every NM connection bound to
  that interface.

## License

MIT. See `LICENSE`.
