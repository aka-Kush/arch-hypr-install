#!/usr/bin/env bash

set -e  # Exit on error

echo "==================================="
echo "Arch Linux + Hyprland Install Script"
echo "==================================="

# Gather information
echo -e "\nPlease enter EFI partition (e.g., /dev/nvme0n1p1):"
read -r EFI
echo "Please enter Root(/) partition (e.g., /dev/nvme0n1p2):"
read -r ROOT  
echo "Please enter SWAP partition (e.g., /dev/nvme0n1p3):"
read -r SWAP
echo "Please enter your Username:"
read -r USER 
echo "Please enter your Full Name:"
read -r NAME 
echo "Please enter your Password:"
read -rs PASSWORD
echo ""

# Confirm partitions
echo -e "\n==================================="
echo "Please verify your selections:"
echo "EFI: ${EFI}"
echo "ROOT: ${ROOT}"
echo "SWAP: ${SWAP}"
echo "==================================="
echo "WARNING: This will FORMAT these partitions!"
read -p "Continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Make filesystems
echo -e "\n==================================="
echo "Creating Filesystems..."
echo "==================================="
mkfs.ext4 -F "${ROOT}"
mkfs.fat -F 32 "${EFI}"
mkswap "${SWAP}"

# Mount target
mount "${ROOT}" /mnt
mkdir -p /mnt/boot/efi
mount "${EFI}" /mnt/boot/efi
swapon "${SWAP}"

echo -e "\n==================================="
echo "Installing Base Arch Linux"
echo "==================================="
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

# Install base system
pacstrap /mnt base linux linux-firmware linux-headers base-devel \
    sof-firmware networkmanager vim amd-ucode git wget --noconfirm --needed

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Create configuration script for chroot
cat <<'REALEND' > /mnt/next.sh
#!/usr/bin/env bash

USER="$1"
NAME="$2"
PASSWORD="$3"

# Create user
useradd -m -G wheel,storage,power,audio,video,input "$USER"
usermod -c "${NAME}" "$USER"
echo "${USER}:${PASSWORD}" | chpasswd

# Configure sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Set root password (same as user for convenience)
echo "root:${PASSWORD}" | chpasswd

echo "==================================="
echo "Setting up locale and timezone"
echo "==================================="
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

echo "arch" > /etc/hostname

# Hosts file
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch.localdomain arch
EOF

echo "==================================="
echo "Installing Bootloader (GRUB)"
echo "==================================="
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

pacman -S grub efibootmgr ntfs-3g os-prober fuse3 --noconfirm --needed

# Detect boot disk from EFI partition
DISK=$(lsblk -no PKNAME /boot/efi | head -n 1)
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "==================================="
echo "Installing Video and Audio Drivers"
echo "==================================="
# NVIDIA drivers
pacman -S mesa nvidia nvidia-utils nvidia-settings opencl-nvidia --noconfirm --needed

# Audio (PipeWire)
pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack \
    wireplumber pavucontrol --noconfirm --needed

echo "==================================="
echo "Installing Hyprland and Dependencies"
echo "==================================="
# Hyprland and Wayland essentials
pacman -S hyprland xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland --noconfirm --needed

# Terminal
pacman -S alacritty --noconfirm --needed

# Display manager (SDDM is lightweight and works well with Hyprland)
pacman -S sddm --noconfirm --needed

# Bluetooth (optional but recommended)
pacman -S bluez bluez-utils --noconfirm --needed

# Enable services
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable sddm

echo "==================================="
echo "Installation Complete!"
echo "==================================="
echo "You can now reboot your system."
echo ""
echo "After reboot, login at SDDM and select Hyprland."
echo "Run your post-install script to configure Hyprland."
echo "==================================="

REALEND

chmod +x /mnt/next.sh

# Execute chroot script
arch-chroot /mnt /next.sh "$USER" "$NAME" "$PASSWORD"

# Cleanup
rm /mnt/next.sh

echo -e "\n==================================="
echo "Installation finished successfully!"
echo "==================================="
echo "You can now unmount and reboot:"
echo "  umount -R /mnt"
echo "  reboot"
echo "==================================="
