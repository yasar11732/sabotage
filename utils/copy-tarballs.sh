#!/bin/sh
# run this script on a second install, i.e. after you have run backup-tarballs.sh
# it will put the tarballs into the build destination.

if [[ ! $1 ]] ; then
	echo "enter the pathname containing your backup tarballs as arg1"
	exit 1
fi

if [[ ! $S || ! $R ]] ; then
	echo "some required env variables not set. run . ./config before executing this"
	exit 1
fi

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "WARNING: you have to run this before AND after stage0 otherwise stage1 will redownload"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

mkdir -p $S
mkdir -p $R
mkdir -p $R/src

cp $1/src/*.bz2 $1/src/*.gz $1/src/*.xz $S/
cp $1/root/src/*.bz2 $1/root/src/*.gz $1/root/src/*.xz $R/src/

echo "done."
