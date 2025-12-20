#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 

# Install VSCode
tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/vscode.repo
dnf -y install --enablerepo=code code

# Cockpit - Web-based system management
COCKPIT_PACKAGES=(
    # Core Cockpit modules
    cockpit-ws              # Provides cockpit.socket
    cockpit-bridge          # Core service - REQUIRED
    cockpit-system          # System info and management
    cockpit-ostree        # OSTree deployment management
    cockpit-podman        # Container management
    cockpit-storaged      # Disk and storage management
    cockpit-networkmanager # Network configuration
    cockpit-selinux       # SELinux policy management
    
    
    # Cockpit dependencies
    dbus-x11                # Required for Cockpit
    udica                 # SELinux policy generator for containers
    
    # Podman tools (work standalone or with cockpit-podman)
    # podman-compose        # Docker Compose compatibility
    # podman-machine        # Podman VM management
    # podman-tui            # Podman terminal UI
    
    # VM stack (only needed for cockpit-machines)
    # cockpit-machines      # VM management (requires VM stack below)
    # edk2-ovmf             # UEFI firmware for VMs
    # libvirt               # Virtualization API
    # libvirt-nss           # Name resolution for libvirt
    # qemu                  # Hypervisor
    # qemu-char-spice
    # qemu-device-display-virtio-gpu
    # qemu-device-display-virtio-vga
    # qemu-device-usb-redirect
    # qemu-img              # Disk image utility
    # qemu-system-x86-core  # x86 emulation
    # qemu-user-binfmt
    # qemu-user-static
    # virt-manager          # VM manager GUI
    # virt-v2v              # VM conversion
    # virt-viewer           # VM console viewer
)

echo "Installing ${#COCKPIT_PACKAGES[@]} Cockpit packages..."
dnf5 -y install "${COCKPIT_PACKAGES[@]}"

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
