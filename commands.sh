#!/bin/sh

username=$(id -u -n 1000)
builddir=$(pwd)

xbps-install -Suy
cd $builddir
mkdir -p /home/$username/Screenshots/temp
mkdir -p /home/$username/.config
chown -R $username:$username /home/$username
rm /home/$username/.bashrc
rm /home/$username/.bash_profile
ln -s /home/$username/dotfiles/bashrc /home/$username/.bashrc
ln -s /home/$username/dotfiles/river /home/$username/.config/
ln -s /home/$username/dotfiles/waybar /home/$username/.config/
ln -s /home/$username/dotfiles/foot /home/$username/.config/
ln -s /home/$username/dotfiles/mako /home/$username/.config/
ln -s /home/$username/dotfiles/tofi /home/$username/.config/
ln -s /home/$username/dotfiles/gtklock /home/$username/.config/
ln -s /home/$username/dotfiles/nvim /home/$username/.config/
ln -s /home/$username/dotfiles/kanshi /home/$username/.config/
ln -s /home/$username/dotfiles/thinkfan.conf /etc/
ln -s /home/$username/dotfiles/fastfetch /home/$username/.config/


# Fix pavucontrol theming
mkdir -p /home/$username/.config/gtk-3.0
ln -s /home/$username/dotfiles/gtk-3.0 /home/$username/.config/
ln -s /home/$username/.config/gtk-3.0 /home/$username/.config/gtk-4.0
chown -R $username:$username /home/$username/.config/gtk-4.0
chown -R $username:$username /home/$username/.config/gtk-3.0

# Install base system
xbps-install -Sy clang-tools-extra river Waybar tofi fzf mako libevdev wayland wayland-protocols wlroots libxkbcommon-devel dbus elogind polkit pixman mesa-dri vulkan-loader mesa-vulkan-radeon mesa-vaapi mesa-vdpau xf86-video-amdgpu curl mpd flatpak pipewire wireplumber libspa-bluetooth neovim arc-theme pavucontrol network-manager-applet wl-clipboard ffmpeg  yt-dlp wget nerd-fonts font-awesome6 lxappearance gvfs nemo setxkbmap kanshi ImageMagick ufw mate-polkit gtklock swww xorg-fonts fonts-roboto-ttf foot grim chromium base-devel bluez xdg-desktop-portal-gtk lm_sensors neofetch btop xbacklight libnotify thinkfan vscode fastfetch slurp swappy celluloid

ln -s /etc/sv/polkitd /var/service/
ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/bluetoothd /var/service/

# Downloading anki and picard, adding them to binaries
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub net.ankiweb.Anki app.drey.EarTag com.github.tchx84.Flatseal md.obsidian.Obsidian
ln -s /var/lib/flatpak/exports/bin/net.ankiweb.Anki /usr/bin/anki
ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/bin/flatseal
ln -s /var/lib/flatpak/exports/bin/app.drey.EarTag /usr/bin/eartag
ln -s /var/lib/flatpak/exports/bin/md.obsidian.Obsidian /usr/bin/obsidian

# Install custom fonts
mv /home/$username/.config/fonts/*.ttf /usr/share/fonts/TTF/

# Force wayland on all apps
sed -i 's|exec /usr/bin/flatpak run|exec /usr/bin/flatpak run --socket=wayland|g' /var/lib/flatpak/exports/bin/*


# Disabling bitmaps
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig

# Backlight fix
echo "%video ALL=(ALL) NOPASSWD: /usr/bin/xbacklight" >> /etc/sudoers

# Pipewire configuration
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

# --------------- Security -----------------

# Setting up firewall
ufw limit 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming
ufw default allow outgoing
ufw enable
ln -s /etc/sv/ufw /var/service/

# Deny all incoming ssh connections.
touch /etc/hosts.deny
echo "sshd: ALL" >> /etc/hosts.deny

# Install tlp
xbps-install -Sy tlp tlp-rdw smartmontools ethtool
rm /etc/tlp.conf
ln -s /home/$username/dotfiles/tlp.conf /etc/
tlp start
ln -s /etc/sv/tlp /var/service/

# Create the swapfile
btrfs subvolume create /var/swap
truncate -s 0 /var/swap/swapfile
chattr +C /var/swap/swapfile
btrfs property set /var/swap compression none
chmod 600 /var/swap/swapfile
dd if=/dev/zero of=/var/swap/swapfile bs=1G count=20 status=progress
mkswap /var/swap/swapfile
swapon /var/swap/swapfile
echo "/var/swap/swapfile none swap sw 0 0" >> /etc/fstab

# Setting up hibernation
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/luks*)
resume_offset=$(btrfs inspect-internal map-swapfile -r /var/swap/swapfile)
sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ resume=UUID=$ROOT_UUID resume_offset=$resume_offset\"/" /etc/default/grub
update-grub

# Setting up snapper
cd /
xbps-install -Sy snapper grub-btrfs inotify-tools
umount /.snapshots
rm -r /.snapshots/
snapper -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
btrfs subvolume list / 
btrfs subvolume set-default 256 / 
vim /etc/snapper/configs/root 
chown -R :wheel /.snapshots
ln -s /etc/sv/snapperd /var/service/
snapper -c root create --description 'Post install'
update-grub

# Amd optimizations
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/s/"$/ radeon.dpm=1 amd_pstate=disable"/' /etc/default/grub
update-grub

# Setting up thinkfan 
touch /etc/modprobe.d/thinkpad_acpi.conf
echo "options thinkpad_acpi fan_control=1" > /etc/modprobe.d/thinkpad_acpi.conf
xbps-reconfigure -f linux6.6
ln -s /etc/sv/thinkfan /var/service/

# Setting up autologin
SERVICE_NAME="agetty-tty1"
AUTOLOGIN_SERVICE_NAME="agetty-autologin-tty1"
CONF_FILE="/etc/sv/${AUTOLOGIN_SERVICE_NAME}/conf"

cp -R /etc/sv/${SERVICE_NAME} /etc/sv/${AUTOLOGIN_SERVICE_NAME}

mkdir -p $(dirname $CONF_FILE)

cat <<EOF > "$CONF_FILE"
if [ -x /sbin/agetty -o -x /bin/agetty ]; then
        # util-linux specific settings
        if [ "\${tty}" = "tty1" ]; then
                GETTY_ARGS="--autologin $username --noclear"
        fi
fi

BAUD_RATE=38400
TERM_NAME=linux
EOF

rm -f /var/service/${SERVICE_NAME}
ln -s /etc/sv/${AUTOLOGIN_SERVICE_NAME} /var/service/

ln -s /home/$username/dotfiles/bash_profile /home/$username/.bash_profile
reboot
