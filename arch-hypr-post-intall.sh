#!/bin/bash

# Arch Linux Post-Install Script
# Run with sudo or as root

set -e  # Exit on error

echo "========================================="
echo "  Arch Linux Post-Install Script"
echo "========================================="
echo ""

# Setup fastest mirrors with reflector
echo "Setting up fastest mirrors with reflector..."

# Install reflector if not already installed
pacman -S --needed --noconfirm reflector

# Backup existing mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# Update mirrorlist with Indian mirrors
reflector -c IN -p https -n 10 --sort rate --download-timeout 2500 --save /etc/pacman.d/mirrorlist

# Configure pacman.conf
echo "Configuring pacman.conf..."

# Uncomment Color
sed -i 's/^#Color/Color/' /etc/pacman.conf

# Add ILoveCandy for pac-man style progress bar
sed -i '/^Color/a ILoveCandy' /etc/pacman.conf

echo "========================================="
echo "  Pacman Configured & Mirrorlist Updated!"
echo "========================================="
echo ""

# Full system update
echo "Performing full system update..."
pacman -Syyu --noconfirm

echo "========================================="
echo "  System Update Complete!"
echo "========================================="

# Install paru (AUR helper)
echo ""
echo "Installing paru AUR helper..."

# Install base-devel and git if not already installed
pacman -S --needed --noconfirm base-devel git

# Clone paru repository
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru

# Build and install paru
makepkg -si --noconfirm

# Clean up
cd /tmp
rm -rf paru

echo "========================================="
echo "  Paru Installed Successfully!"
echo "========================================="

# Setup Chaotic-AUR
echo ""
echo "Setting up Chaotic-AUR repository..."

# Receive and sign the primary key
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

# Install chaotic-keyring and chaotic-mirrorlist
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add Chaotic-AUR to pacman.conf
echo "" >> /etc/pacman.conf
echo "[chaotic-aur]" >> /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

# Update package database
pacman -Sy

echo "========================================="
echo "  Chaotic-AUR Setup Complete!"
echo "========================================="

# Enable multilib repository
echo ""
echo "Enabling multilib repository..."

# Uncomment multilib in pacman.conf
sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf

# Update package database
pacman -Sy

echo "========================================="
echo "  Multilib Repository Enabled!"
echo "========================================="

# Install fonts
echo ""
echo "Installing fonts..."

pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-meslo-nerd noto-fonts-emoji

echo "========================================="
echo "  Fonts Installed Successfully!"
echo "========================================="

# Install Flatpak
echo ""
echo "Installing Flatpak support..."

pacman -S --needed --noconfirm flatpak

echo "========================================="
echo "  Flatpak Installed Successfully!"
echo "========================================="

# Install software and tools
echo ""
echo "Installing software and tools..."

pacman -S --needed --noconfirm \
    kitty \
    thunar \
    lsd \
    network-manager-applet \
    neovim \
    pavucontrol \
    viewnior \
    vim \
    tumbler \
    ffmpegthumbnailer \
    libheif \
    gvfs \
    ideviceinstaller \
    libplist \
    ifuse \
    libimobiledevice \
    libreoffice-fresh \
    thunar-archive-plugin \
    xarchiver \
    gocryptfs \
    unzip \
    ntfs-3g \
    mpv \
    qbittorrent \
    xdg-user-dirs-gtk \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal \
    discord \
    xdg-utils \
    hyprpolkitagent \
    imagemagick \
    usbmuxd \
    adw-gtk3 \
    git \
    papirus-icon-theme \
    waybar \
    wlogout \
    rofi \
    hyprlock \
    brightnessctl \
    jq \
    lshw \
    libnotify \
    dunst \
    cliphist \
    wl-clipboard \
    udiskie

echo "========================================="
echo "  Software Installed Successfully!"
echo "========================================="

# Install Flatpak applications
echo ""
echo "Installing Flatpak applications..."

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub com.protonvpn.www
flatpak install -y flathub io.ente.auth
flatpak install -y flathub io.ente.photos

echo "========================================="
echo "  Flatpak Apps Installed Successfully!"
echo "========================================="

# Install build tools and dependencies
echo ""
echo "Installing build tools and dependencies..."

pacman -S --needed --noconfirm \
    gcc \
    curl \
    fzf \
    ripgrep \
    wget \
    fd \
    bat \
    pkg-config \
    gnupg \
    make \
    autoconf \
    automake \
    libtool \
    tldr \
    rsync \
    cmake \
    sassc

echo "========================================="
echo "  Build Tools Installed Successfully!"
echo "========================================="

# Install programming languages and package managers
echo ""
echo "Installing programming languages..."

pacman -S --needed --noconfirm \
    nodejs \
    npm \
    python \
    python-pip \
    python-pipx \
    go

echo "========================================="
echo "  Programming Languages Installed Successfully!"
echo "========================================="

# Setup Bluetooth
echo ""
echo "Setting up Bluetooth..."

pacman -S --needed --noconfirm bluez bluez-utils blueman

# Enable Bluetooth service
systemctl enable bluetooth.service

echo "========================================="
echo "  Bluetooth Setup Complete!"
echo "========================================="

# Enable USB device support service
echo ""
echo "Enabling usbmuxd service..."

systemctl enable usbmuxd.service

echo "========================================="
echo "  usbmuxd Service Enabled!"
echo "========================================="

# Install Floorp browser from AUR
echo ""
echo "Installing Floorp browser..."

pacman -S --needed --noconfirm floorp

echo "========================================="
echo "  Floorp Browser Installed Successfully!"
echo "========================================="

# Install matugen for material you theming
echo ""
echo "Installing matugen..."

paru -S --needed --noconfirm matugen-bin

echo "========================================="
echo "  Matugen Installed Successfully!"
echo "========================================="

# Install gaming and NVIDIA utilities
echo ""
echo "Installing gaming and NVIDIA utilities..."

pacman -S --needed --noconfirm \
    steam \
    nvidia-utils \
    libva \
    libva-utils \
    vulkan-tools \
    vulkan-validation-layers \
    vulkan-headers \
    vulkan-icd-loader \
    mesa-demos \
    egl-wayland \
    nvtop \
    nvidia-prime \
    nvidia-settings \
    nwg-displays \
    nwg-look

echo "========================================="
echo "  Gaming & NVIDIA Stuff Installed Successfully!"
echo "========================================="

# Setup power management
echo ""
echo "Setting up power management..."

pacman -S --needed --noconfirm power-profiles-daemon

# Enable power-profiles-daemon service
systemctl enable power-profiles-daemon.service

echo "========================================="
echo "  Power Management Configured!"
echo "========================================="

# Install Flatpak applications (additional)
echo ""
echo "Installing additional Flatpak applications..."

flatpak install -y flathub io.github.Faugus.faugus-launcher
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub net.davidotek.pupgui2

echo "========================================="
echo "  Additional Flatpaks Installed Successfully!"
echo "========================================="

# Clone and setup dotfiles
echo ""
echo "Setting up dotfiles..."

# Clone dotfiles repository
git clone https://github.com/aka-Kush/hypr-dots.git /tmp/hypr-dots

# Copy dotfiles to ~/.config
cp -r /tmp/hypr-dots/* ~/.config/

# Clean up
rm -rf /tmp/hypr-dots

echo "========================================="
echo "  Dotfiles Installed Successfully!"
echo "========================================="

# Install and setup Fish shell
echo ""
echo "Installing and setting up Fish shell..."

pacman -S --needed --noconfirm fish

# Change default shell to fish
chsh -s /usr/bin/fish

echo "========================================="
echo "  Fish Shell Installed & Set as Default!"
echo "========================================="

echo ""
echo "========================================="
echo "  POST-INSTALL SCRIPT COMPLETE!"
echo "========================================="
echo ""
echo "Please reboot your system to apply all changes."
echo ""
