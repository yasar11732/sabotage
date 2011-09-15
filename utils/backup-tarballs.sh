#!/bin/sh

if [[ ! $1 ]] ; then
	echo "enter a backup pathname as arg1"
	exit 1
fi

if [[ ! $S || ! $R ]] ; then
	echo "some required env variables not set. run . ./config before executing this"
	exit 1
fi

mkdir -p $1
mkdir -p $1/src
mkdir -p $1/root
mkdir -p $1/root/src

cp $S/*.bz2 $S/*.gz $2/*.xz $1/src
cp $R/src/*.bz2 $R/src/*.gz $R/src/*.xz $1/root/src


