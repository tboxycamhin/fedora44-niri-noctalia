#!/usr/bin/env bash

set -euo pipefail

USERNAME=$(whoami)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINDINGS_FILE="${SCRIPT_DIR}/configs/noctalia-bindings.kdl"
NIRI_CONFIG_DIR="${HOME}/.config/niri"
NIRI_CONFIG_FILE="${NIRI_CONFIG_DIR}/config.kdl"
NIRI_DEFAULT_CONFIG="/usr/share/niri/config.kdl"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
NIRI_BACKUP_FILE="${NIRI_CONFIG_FILE}.bak.${TIMESTAMP}"

FONT_NAME="JetBrains Mono"
FONTCONFIG_DIR="${HOME}/.config/fontconfig"
FONTCONFIG_FILE="${FONTCONFIG_DIR}/fonts.conf"

restore_backup_if_available() {
    if [[ -f "${NIRI_BACKUP_FILE}" ]]; then
        cp -a "${NIRI_BACKUP_FILE}" "${NIRI_CONFIG_FILE}"
        echo "Restored previous Niri config from: ${NIRI_BACKUP_FILE}" >&2
    fi
}

fail() {
    echo ""
    echo "ERROR: $1" >&2
    exit 1
}

inject_noctalia_bindings() {
    python3 - "${NIRI_CONFIG_FILE}" "${BINDINGS_FILE}" <<'PY'
from pathlib import Path
import sys

config_path = Path(sys.argv[1])
bindings_path = Path(sys.argv[2])

text = config_path.read_text()
bindings = bindings_path.read_text()

if "// BEGIN NOCTALIA KEYBINDS" in text and "// END NOCTALIA KEYBINDS" in text:
    print("Noctalia keybind block already present.")
    raise SystemExit(0)

lines = text.splitlines(keepends=True)
insert_index = None

for i, line in enumerate(lines):
    stripped = line.strip()
    if stripped.startswith("binds") and "{" in stripped:
        insert_index = i + 1
        break

if insert_index is None:
    raise SystemExit("Could not find binds {} in the copied default Niri config.")

lines.insert(insert_index, bindings)
config_path.write_text("".join(lines))

print("Injected Noctalia bindings into existing binds {} block.")
PY
}

validate_niri_config() {
    echo "Validating Niri config before enabling greetd..."
    if niri --config "${NIRI_CONFIG_FILE}" validate; then
        echo "Niri config validation passed."
    else
        echo "Niri config validation failed." >&2
        restore_backup_if_available
        fail "greetd was not enabled because Niri config validation failed."
    fi
}

configure_fonts() {
    echo "Configuring Nerd Font and default font settings..."

    mkdir -p "${FONTCONFIG_DIR}"

    cat > "${FONTCONFIG_FILE}" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>${FONT_NAME}</family>
    </prefer>
  </alias>

  <alias>
    <family>serif</family>
    <prefer>
      <family>${FONT_NAME}</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>${FONT_NAME}</family>
    </prefer>
  </alias>

</fontconfig>
EOF

    mkdir -p "${HOME}/.config/kitty"
    cat > "${HOME}/.config/kitty/kitty.conf" <<EOF
font_family ${FONT_NAME}
font_size 11.0
EOF

    mkdir -p "${HOME}/.config/alacritty"
    cat > "${HOME}/.config/alacritty/alacritty.toml" <<EOF
[font]
size = 11.0

[font.normal]
family = "${FONT_NAME}"
style = "Regular"

[font.bold]
family = "${FONT_NAME}"
style = "Bold"

[font.italic]
family = "${FONT_NAME}"
style = "Italic"

[font.bold_italic]
family = "${FONT_NAME}"
style = "Bold Italic"
EOF

    mkdir -p "${HOME}/.config/foot"
    cat > "${HOME}/.config/foot/foot.ini" <<EOF
[main]
font=${FONT_NAME}:size=11
EOF

    fc-cache -fv >/dev/null

    echo "Font configuration complete."
    echo "Default monospace font is now:"
    fc-match monospace
}

echo "================================"
echo "Fedora 44 + Niri + Noctalia"
echo "================================"

if [[ $EUID -eq 0 ]]; then
    echo "Run as a normal user with sudo privileges."
    exit 1
fi

if [[ ! -f "${BINDINGS_FILE}" ]]; then
    fail "Missing bindings file: ${BINDINGS_FILE}"
fi

echo "[1/12] Updating system..."
sudo dnf upgrade --refresh -y

echo "[2/12] Installing RPM Fusion..."
sudo dnf install -y \
https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf upgrade --refresh -y

echo "[3/12] Installing core packages..."
sudo dnf install -y \
dnf-plugins-core \
greetd \
seatd \
wayland \
pipewire \
wireplumber \
mesa-dri-drivers \
mesa-vulkan-drivers \
NetworkManager-wifi \
fontconfig

echo "[4/12] Enabling services..."
sudo systemctl enable --now seatd
sudo systemctl enable --now NetworkManager

echo "[5/12] Installing Niri..."
sudo dnf copr enable yalter/niri -y

sudo dnf install -y \
niri \
alacritty \
kitty \
foot \
fuzzel \
waybar \
swaylock \
swayidle \
mako \
firefox \
thunar \
pavucontrol \
wl-clipboard \
btop \
fastfetch \
wev \
xdg-desktop-portal-gtk \
xdg-desktop-portal-gnome \
xwayland-satellite \
steam

echo "[6/12] Installing Nerd Fonts and setting default font..."
sudo dnf copr enable che/nerd-fonts -y

sudo dnf install -y \
nerd-fonts \
jetbrains-mono-fonts

configure_fonts

echo "[7/12] Installing Noctalia..."
sudo dnf install -y noctalia

echo "[8/12] Backing up existing Niri configuration..."
mkdir -p "${NIRI_CONFIG_DIR}"
if [[ -f "${NIRI_CONFIG_FILE}" ]]; then
    cp -a "${NIRI_CONFIG_FILE}" "${NIRI_BACKUP_FILE}"
    echo "Backed up existing config to: ${NIRI_BACKUP_FILE}"
else
    echo "No existing user config found."
fi

echo "[9/12] Copying default Niri configuration..."
if [[ ! -f "${NIRI_DEFAULT_CONFIG}" ]]; then
    restore_backup_if_available
    fail "Default Niri config not found at ${NIRI_DEFAULT_CONFIG}."
fi

cp -a "${NIRI_DEFAULT_CONFIG}" "${NIRI_CONFIG_FILE}"

echo "[10/12] Injecting Noctalia startup and keybinds..."
if ! grep -q 'spawn-at-startup "noctalia" "--daemon"' "${NIRI_CONFIG_FILE}"; then
    cat >> "${NIRI_CONFIG_FILE}" <<'KDL'

// Noctalia shell daemon startup.
spawn-at-startup "noctalia" "--daemon"
KDL
fi

inject_noctalia_bindings
validate_niri_config

echo "[11/12] Configuring greetd..."
sudo mkdir -p /etc/greetd

sudo tee /etc/greetd/config.toml > /dev/null <<EOF
[default_session]
command = "niri-session"
user = "$USERNAME"
EOF

sudo systemctl enable greetd
sudo systemctl set-default graphical.target

echo "[12/12] Finalising..."
sudo loginctl enable-linger "$USERNAME"

echo ""
echo "Installation complete."
echo ""
echo "Reboot using:"
echo "sudo reboot"
