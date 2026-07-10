# Fedora 44 Server + Niri + Noctalia v5

Automated installer for a clean Fedora 44 Server install.

## Install from GitHub

```bash
sudo dnf install -y git

git clone https://github.com/YOURUSERNAME/fedora44-niri-noctalia-v2.git

cd fedora44-niri-noctalia

chmod +x install.sh

./install.sh

sudo reboot
```

## What the script does

The `install.sh` script performs the full automated install:

1. Updates Fedora.
2. Installs RPM Fusion.
3. Installs core Wayland packages.
4. Enables `seatd` and `NetworkManager`.
5. Enables the Niri COPR repository.
6. Installs Niri and supporting desktop packages.
7. Installs Noctalia.
8. Backs up any existing Niri user config.
9. Copies `/usr/share/niri/config.kdl` to `~/.config/niri/config.kdl`.
10. Injects only the Noctalia daemon startup entry and Noctalia keybinds.
11. Validates Niri config before enabling greetd.
12. Enables greetd and graphical boot only after validation succeeds.
13. Enables linger for the current user.

## Files

```text
fedora44-niri-noctalia-v2/
├── README.md
├── install.sh
├── LICENSE
└── configs/
    └── noctalia-bindings.kdl
```

## Key configuration locations

```text
~/.config/niri/config.kdl
~/.config/noctalia/
/etc/greetd/config.toml
```
