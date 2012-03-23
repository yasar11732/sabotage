#!/bin/bash
usage() {
    echo 'Use: buildimage.sh <img file> <directory or tarball of content> [img size]'
    exit 1
}

die() {
    echo "$1"
    exit 1
}

FILE="$1"
shift
if [ ! "$FILE" ]
then
    usage
    exit 1
fi

CONT="$1"
shift
if [ ! "$CONT" ]
then
    usage
    exit 1
fi

SIZE="$1"
shift >& /dev/null
if [ ! "$SIZE" ]
then
    SIZE="10G"
fi

MBR=
for mbr in mbr.bin /usr/lib/syslinux/mbr.bin
do
    if [ -f "$mbr" ]
    then
        MBR="$mbr"
        break
    fi
done
if [ ! "$MBR" ]
then
    die 'Could not find mbr.bin'
fi

# 1) make the image file
dd if=/dev/zero of="$FILE" bs=1 count=1 seek="$SIZE" || die 'Failed to create '"$FILE"

# 2) fdisk
echo 'n
p
1
2048
+100M
n
p
2


a
1
w' | /sbin/fdisk "$FILE"

# 3) copy mbr
dd conv=notrunc if="$MBR" of="$FILE" || die 'Failed to set up MBR'

# 4) /boot
LOOP=`losetup -f`
MNT="/tmp/mnt.$$"
losetup -o $(( 512 * 2048 )) --sizelimit $(( 100 * 1024 * 1024 )) "$LOOP" "$FILE" || die 'Failed to losetup for /boot'
mkdir -p "$MNT" || die 'Failed to make '"$MNT"
mkfs.ext3 "$LOOP" || die 'Failed to mkfs.ext3 loop for /boot'
mount "$LOOP" "$MNT" || die 'Failed to mount loop for /boot'
if [ -d "$CONT" ]
then
    cp -a "$CONT"/boot/* "$MNT"/ || die 'Failed to copy boot'
else
    tar -C "$MNT" -xf "$CONT" boot || die 'Failed to extract boot'
    mv "$MNT"/boot/* "$MNT"/ || die 'Failed to move /boot content to root of boot partition'
    rmdir "$MNT"/boot
fi
perl -pe 's/sda1/sda2/g' -i "$MNT"/extlinux.conf || die 'Failed to reconfigure extlinux.conf'
extlinux -i "$MNT"/ || die 'Failed to install extlinux'
umount "$MNT" || die 'Failed to unmount /boot'
sync
losetup -d "$LOOP"

# 5) /
LOOP=`losetup -f`
losetup -o $(( (512 * 2048) + (100 * 1024 * 1024) )) "$LOOP" "$FILE" || die 'Failed to losetup for /'
mkfs.ext3 "$LOOP" || die 'Failed to mkfs.ext3 loop for /'
mount "$LOOP" "$MNT" || die 'Failed to mount loop for /'
if [ -d "$CONT" ]
then
    cp -a "$CONT"/* "$MNT"/ || die 'Failed to copy /'
else
    tar -C "$MNT" -zxf "$CONT" || die 'Failed to extract /'
fi
rm -f "$MNT"/boot/*
echo '/dev/sda1 /boot ext3 defaults 0 0' >> "$MNT"/etc/fstab || die 'Failed to extend fstab'
umount "$MNT" || die 'Failed to unmount /'
sync
losetup -d "$LOOP"

# cleanup
rmdir "$MNT" || die 'Failed to remove '"$MNT"

echo 'Done.'

