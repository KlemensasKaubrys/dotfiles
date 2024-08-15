#!/bin/sh

username=$(id -u -n 1000)
builddir=$(pwd)

xbps-install -Suy
cd $builddir
mkdir -p /home/$username/.config
chown -R $username:$username /home/$username
rm /home/$username/.bashrc
rm /home/$username/.bash_profile
ln -s /home/$username/dotfiles/bashrc /home/$username/.bashrc
ln -s /home/$username/dotfiles/bash_profile /home/$username/.bash_profile
ln -s /home/$username/dotfiles/mpd /home/$username/.config/
ln -s /home/$username/dotfiles/fastfetch /home/$username/.config/
ln -s /home/$username/dotfiles/ncmpcpp /home/$username/.config/
ln -s /home/$username/dotfiles/river /home/$username/.config/
ln -s /home/$username/dotfiles/waybar /home/$username/.config/
ln -s /home/$username/dotfiles/foot /home/$username/.config/
ln -s /home/$username/dotfiles/mako /home/$username/.config/
ln -s /home/$username/dotfiles/tofi /home/$username/.config/
ln -s /home/$username/dotfiles/nvim /home/$username/.config/

# Change xbps mirror
mkdir -p /etc/xbps.d
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://repo-default.voidlinux.org|https://repo-de.voidlinux.org|g' /etc/xbps.d/*-repository-*.conf

# Fix pavucontrol theming
mkdir -p /home/$username/.config/gtk-3.0
ln -s /home/$username/.config/gtk-3.0 /home/$username/.config/gtk-4.0
chown -R $username:$username /home/$username/.config/gtk-4.0
chown -R $username:$username /home/$username/.config/gtk-3.0

# Install base system
xbps-install -Sy river Waybar tofi mako libevdev wayland wayland-protocols wlroots libxkbcommon-devel dbus elogind polkit pixman mesa-dri vulkan-loader mesa-vulkan-radeon mesa-vaapi mesa-vdpau xf86-video-amdgpu curl mpd ncmpcpp flatpak pipewire wireplumber libspa-bluetooth neovim arc-theme pavucontrol network-manager-applet flameshot wl-clipboard feh ffmpeg mpv yt-dlp wget nerd-fonts font-awesome6 lxappearance gvfs pcmanfm setxkbmap wlr-randr yazi ImageMagick ufw mate-polkit gtklock 

ln -s /etc/sv/dbus /var/service/
ln -s /etc/sv/bluetoothd /var/service/

# Downloading anki and picard, adding them to binaries
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub net.ankiweb.Anki app.drey.EarTag com.brave.Browser com.github.tchx84.Flatseal cc.arduino.IDE2
ln -s /var/lib/flatpak/exports/bin/net.ankiweb.Anki /usr/bin/anki
ln -s /var/lib/flatpak/exports/bin/com.brave.Browser  /usr/bin/brave
ln -s /var/lib/flatpak/exports/bin/com.github.tchx84.Flatseal /usr/bin/flatseal
ln -s /var/lib/flatpak/exports/bin/app.drey.EarTag /usr/bin/eartag
ln -s /var/lib/flatpak/exports/bin/cc.arduino.IDE2 /usr/bin/arduino

# Disabling bitmaps
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
xbps-reconfigure -f fontconfig

# Install filtile
cd /usr/bin
wget https://github.com/KlemensasKaubrys/filtile/releases/download/stable/filtile
chmod +x filtile
cd $builddir

# Pipewire configuration
mkdir -p /etc/pipewire/pipewire.conf.d
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/

# Setting up firewall
ufw limit 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw default deny incoming
ufw default allow outgoing
ufw enable
ln -s /etc/sv/ufw /var/service/

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

# Setting up autologin
SERVICE_NAME="agetty-tty1"
AUTOLOGIN_SERVICE_NAME="agetty-autologin-tty1"
CONF_FILE="/etc/sv/${AUTOLOGIN_SERVICE_NAME}/conf"

cp -R /etc/sv/${SERVICE_NAME} /etc/sv/${AUTOLOGIN_SERVICE_NAME}

mkdir -p $(dirname $CONF_FILE)

# I hate my life -> this script is so shit
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

ask_and_restart() {
    read -p "Do you want to restart now? (yes/no): " response
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    if [ "$response" == "yes" ]; then
        echo "Restarting..."
        reboot
    elif [ "$response" == "no" ]; then
        echo "Exiting..."
        exit 0
    else
        echo "Invalid response. Please enter 'yes' or 'no'."
        ask_and_restart
    fi
}

ask_and_restart
