#!/bin/bash
#
# part disk, then create volume group

fdisk /dev/sda
mkfs.vfat -F 32 /dev/sda1
cryptsetup luksFormat /dev/sda2
cryptsetup open /dev/sda2 gentoocrypt
pvcreate /dev/mapper/gentoocrypt
vgcreate vg0 /dev/mapper/gentoocrypt
lvcreate -L 8G vg0 -n swap
lvcreate -l 100%FREE vg0 -n root
mkfs.ext4 /dev/vg0/root
mkswap /dev/vg0/swap
swapon /dev/vg0/swap
mkdir --parents /mnt/gentoo
mount /dev/mapper/root /mnt/gentoo

# the next line is so I don't abuse the mirror, the line using wget is the actual command.
cp stage3-*.tar.xz /mnt/gentoo
cd /mnt/gentoo
# wget https://gentoo.osuosl.org/releases/amd64/autobuilds/20230101T164658Z/stage3-amd64-desktop-openrc-20230101T164658Z.tar.xz
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
echo "MAKE_OPTS=\"-j2\" " >> /mnt/gentoo/etc/portage/make.conf
echo "ACCEPT_LICENSE=\"@FREE @BINARY-REDISTRIBUTABLE\" " >> /mnt/gentoo/etc/portage/make.conf
echo "VIDEO_CARDS=\"intel\" " >> /mnt/gentoo/etc/portage/make.conf
echo "GRUB_PLATFORMS=\"efi-64\" " >> /mnt/gentoo/etc/portage/make.conf
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# mount 

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

# chroot 

chroot /mnt/gentoo /bin/bash
