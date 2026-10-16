Name:           wifi-cli
Version:        0.1.0
Release:        1%{?dist}
Summary:        Scan, pick and connect to Wi-Fi from a headless shell
License:        MIT
URL:            https://github.com/HSTG-IO/wifi-cli
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  make
Requires:       bash >= 4.3
Requires:       iw
Requires:       wpa_supplicant
Requires:       systemd
Requires:       iproute

%description
Provides a single `wifi` command: run it, it scans for networks, shows a
numbered list, asks for a password and connects. Persists across reboots via
wpa_supplicant@<iface> and systemd-networkd. Falls back to nmcli when
NetworkManager owns the interface. Plain bash; no daemon.

%prep
%autosetup -n %{name}

%build
# nothing to compile

%install
%make_install PREFIX=%{_prefix} SBINDIR=%{_sbindir}
# rpm handles docs/license itself
rm -rf %{buildroot}%{_docdir}/%{name}

%post
if command -v networkctl >/dev/null 2>&1 && systemctl is-active --quiet systemd-networkd; then
    networkctl reload 2>/dev/null || :
fi

%files
%license LICENSE
%doc README.md docs/INTERNALS.md
%{_mandir}/man8/wifi.8*
%{_sbindir}/wifi
%{_prefix}/lib/systemd/network/80-wifi-cli.network

%changelog
* Fri Oct 16 2026 Elliott <elliott@hstg.io> - 0.1.0-1
- Initial package
