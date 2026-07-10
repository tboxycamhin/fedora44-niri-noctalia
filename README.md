# Fedora 44 Server + Niri + Noctalia v5

Automated installer for a clean Fedora 44 Server installation using Niri, Noctalia v5, and Greetd.

---

# Installation

## Install Git

```bash
sudo dnf install -y git
```

## Clone Repository

```bash
git clone https://github.com/tboxycamhin/fedora44-niri-noctalia.git
```

## Enter Repository

```bash
cd fedora44-niri-noctalia
```

## Make Installer Executable

```bash
chmod +x install.sh
```

## Run Installer

```bash
./install.sh
```

## Reboot

```bash
sudo reboot
```

---

# What the Installer Does

The `install.sh` script performs the following actions:

1. Updates Fedora packages.
2. Installs RPM Fusion repositories.
3. Installs core Wayland packages.
4. Enables `seatd` and `NetworkManager`.
5. Enables the Niri COPR repository.
6. Installs Niri and supporting desktop packages.
7. Installs Noctalia.
8. Backs up any existing Niri user configuration.
9. Copies `/usr/share/niri/config.kdl` to `~/.config/niri/config.kdl`.
10. Injects only the Noctalia daemon startup entry and Noctalia keybinds.
11. Validates the Niri configuration before enabling Greetd.
12. Enables Greetd and graphical boot only after successful validation.
13. Enables user linger for improved user service reliability.

---

# Included Applications

| Application | Purpose |
|------------|----------|
| Niri | Wayland compositor |
| Noctalia | Desktop shell |
| Greetd | Login manager |
| Kitty | Terminal emulator |
| Fuzzel | Application launcher |
| Waybar | Status bar |
| Mako | Notifications |
| Firefox | Web browser |
| Thunar | File manager |
| Steam | Gaming |
| Pavucontrol | Audio control |
| wl-clipboard | Clipboard utilities |
| btop | System monitor |
| Fastfetch | System information |
| wev | Wayland event viewer |

---

# Keybind Reference

**Mod** = Super / Windows key

## Core UI

| Shortcut | Action |
|-----------|----------|
| ⊞ + Space | Application Launcher |
| ⊞ + C | Control Centre |
| ⊞ + ⇧ + C | Clipboard History |
| ⊞ + W | Wallpaper Manager |
| ⊞ + Esc | Session Menu |
| ⊞ + , | Settings |

---

## Window Management

| Shortcut | Action |
|-----------|----------|
| Alt + ⇥ | Window Switcher |

---

## Bar, Dock & Widgets

| Shortcut | Action |
|-----------|----------|
| ⊞ + B | Toggle Bar |
| ⊞ + ⇧ + D | Toggle Dock |
| ⊞ + ⇧ + W | Toggle Desktop Widgets |
| ⊞ + Ctrl + W | Widget Edit Mode |

---

## Screenshots

| Shortcut | Action |
|-----------|----------|
| Print | Region Screenshot |
| ⇧ + Print | Full Screen Screenshot |

---

## Audio Controls

| Shortcut | Action |
|-----------|----------|
| 🔊 Volume Up | Increase Volume |
| 🔉 Volume Down | Decrease Volume |
| 🔇 Mute | Toggle Speaker Mute |
| 🎤 Mute | Toggle Microphone Mute |

---

## Brightness Controls

| Shortcut | Action |
|-----------|----------|
| ☀ Brightness Up | Increase Brightness |
| ☀ Brightness Down | Decrease Brightness |

---

## Media Controls

| Shortcut | Action |
|-----------|----------|
| ⏯ Play/Pause | Media Play/Pause |
| ⏭ Next | Next Track |
| ⏮ Previous | Previous Track |

---

## Session Controls

| Shortcut | Action |
|-----------|----------|
| ⊞ + Alt + L | Lock Screen |
| ⊞ + ⇧ + S | Suspend |
| ⊞ + Ctrl + Alt + L | Lock & Suspend |
| ⊞ + Ctrl + Delete | Reboot |
| ⊞ + Ctrl + End | Shutdown |

---

## Productivity & System Toggles

| Shortcut | Action |
|-----------|----------|
| ⊞ + N | Toggle Night Light |
| ⊞ + ⇧ + N | Force Night Light |
| ⊞ + F8 | Toggle Wi-Fi |
| ⊞ + F9 | Toggle Bluetooth |
| ⊞ + F10 | Toggle Caffeine Mode |
| ⊞ + ⇧ + R | Reload Noctalia Configuration |

---

# Default Niri Shortcuts

| Shortcut | Action |
|-----------|----------|
| ⊞ + T | Open Terminal |
| ⊞ + D | Open Application Launcher |
| ⊞ + ⇧ + E | Exit Niri Session |

---

# Recommended Daily Workflow

| Task | Shortcut |
|--------|---------|
| Launch Applications | ⊞ + Space |
| Open Control Centre | ⊞ + C |
| Open Settings | ⊞ + , |
| Open Clipboard History | ⊞ + ⇧ + C |
| Change Wallpaper | ⊞ + W |
| Switch Windows | Alt + ⇥ |
| Take Screenshot | Print |
| Lock Screen | ⊞ + Alt + L |
| Toggle Night Light | ⊞ + N |
| Toggle Wi-Fi | ⊞ + F8 |
| Toggle Bluetooth | ⊞ + F9 |
| Toggle Caffeine Mode | ⊞ + F10 |
| Suspend System | ⊞ + ⇧ + S |

---

# Configuration Locations

```text
~/.config/niri/config.kdl
~/.config/noctalia/
/etc/greetd/config.toml
```

---

# Validation & Troubleshooting

Validate the Niri configuration:

```bash
niri validate
```

Reload the Niri configuration:

```bash
niri msg action reload-config
```

Check Noctalia status:

```bash
noctalia msg status
```

Check Wayland session:

```bash
echo $XDG_SESSION_TYPE
```

Expected output:

```text
wayland
```
