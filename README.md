# wifi-cli

**Type `wifi`. Pick a network. Enter the password. You're online.**

Headless Wi-Fi setup for Linux servers, mining rigs, Pis, and appliances — no
`nmtui`, no hand-written `wpa_supplicant.conf`, no netplan YAML.

```
$ sudo wifi
Scanning networks... found 4
Select access point:
1) [RESCAN]            4) ShopFloor
2) [CUSTOM SSID]       5) ShopFloor-5G
3) [ANY OPEN NETWORK]  6) Site3-Mgmt
#? 6
Password (type NONE for an open network):
State: configuring routable

WiFi setup done. Connected.
```

The connection survives reboots. That's the whole tool.

## Install

**Debian / Ubuntu / Raspberry Pi OS**

```sh
sudo apt install ./wifi-cli_0.1.0_all.deb
```

**Fedora / RHEL / Rocky / Alma**

```sh
sudo dnf install ./wifi-cli-0.1.0-1.noarch.rpm
```

**Arch** — `packaging/PKGBUILD` is included; `makepkg -si` from that directory.

**Anything else with systemd**

```sh
tar xzf wifi-cli-0.1.0.tar.gz && cd wifi-cli
sudo make install            # needs: iw, wpa_supplicant
```

Packages are on the [Releases](../../releases) page.

## Usage

| Command | |
|---|---|
| `wifi` | Interactive: scan, pick, password, connect |
| `wifi "My SSID" 'passw0rd'` | Non-interactive, for first-boot scripts |
| `wifi "Open Cafe" NONE` | Open network |
| `wifi status` | Link state and address |
| `wifi disable` | Turn Wi-Fi off; keeps the saved network |
| `wifi forget` | Turn it off and delete the saved network |
| `wifi -i wlp3s0 ...` | Choose the interface (default: first wireless one found) |

`man wifi` has the rest.

## Why

Every headless distro makes Wi-Fi harder than it should be: a curses UI that
fights your wired config, a config file you have to write by hand, or YAML you
have to look up every time. Getting a box online from a serial console or a
first SSH session should be one word and a password.

`wifi` is plain bash on top of `iw`, `wpa_supplicant`, and `systemd-networkd`,
with an `nmcli` fallback when NetworkManager already owns the interface. No
daemon, no Python, nothing to keep running.

How it works, design decisions, and known limitations: [docs/INTERNALS.md](docs/INTERNALS.md).

## Contributing

Bug reports and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Run
`make check` before pushing; CI builds the `.deb` and `.rpm` on every commit.

## License

[MIT](LICENSE).
