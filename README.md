# My Arch Linux install (Encrypted BTRFS partition & swap + Snapper grub rollback)
![2024-07-26_22-30](https://github.com/user-attachments/assets/12190232-4a77-4007-b745-73b301a460dc)
## Making, initialising the swapfile
```bash
sudo -s
btrfs subvolume create /var/swap
truncate -s 0 /var/swap/swapfile
chattr +C /var/swap/swapfile
btrfs property set /var/swap compression none
chmod 600 /var/swap/swapfile
dd if=/dev/zero of=/var/swap/swapfile bs=1G count=16 status=progress # Change count=16 to required swap size in GB
mkswap /var/swap/swapfile
swapon /var/swap/swapfile
echo "# Swap file" >> /etc/fstab
echo "/var/swap/swapfile none swap sw 0 0" >> /etc/fstab
```
## Setting up snapper, btrfs-grub
```bash
sudo -s
cd /
pacman -S snapper grub-btrfs inotify-tools
umount /.snapshots
rm -r /.snapshots/
snapper -c root create-config /
# snapper creates /.snapshots subvolume which needs to be deleted because we already have either a @snapshots or @.snapshots subvolume
btrfs subvolume list /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
lsblk # Check if the directory mounted
btrfs subvolume list / # Check the id of the @ / root subvolume, most of the time its 256
btrfs subvolume set-default 256 / # Change the default subvolume to root / @
btrfs subvolume get-default / # Check if the changes were applied
vim /etc/snapper/configs/root # Change snapper config https://wiki.archlinux.org/title/Snapper
chown -R :wheel /.snapshots
sudo systemctl enable --now grub-btrfsd
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl enable --now snapper-cleanup.timer
grub-mkconfig -o /boot/grub/grub.cfg
```
## Software i use, gtk fix
```bash
# Pavucontrol uses gtk4 instead of gtk3 so to get theming I symlink gtk-3.0 to gtk-4.0
sudo ln -s /home/clemens/.config/gtk-3.0 /home/clemens/.config/gtk-4.0
# Software I use
sudo pacman -S flameshot gvim ufw tlp tlp-rdw picom dunst feh mate-polkit network-manager-applet lxappearance pavucontrol pcmanfm
# Fonts used in my dwm setup
sudo pacman -S ttf-space-mono-nerd ttf-jetbrains-mono-nerd
```
