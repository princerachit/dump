#!bin/bash

usage()
{
    echo usage: "bash create-disks.sh <disk_prefix> <count> <size>"
    echo
}

prefix="$1"

count="$2"

size="$3"

usage

if [ "$prefix" == "" ]; then
    echo "disk_prefix not supplied using default prefix 'prince'"
    echo
    prefix="prince"
fi

if [ "$count" == "" ]; then
    echo count not supplied using default count '3'
    echo
    count="3"
fi

if [ "$size" == "" ]; then
    echo size not supplied using default size '10G'
    echo
    size="10"
fi

echo

sleep 5

iter=0

echo $count $iter
until [ "$iter" == "$count" ]; do
    echo "gcloud compute disks create $prefix-$iter --size=$size --quiet"
    gcloud compute disks create $prefix-$iter --size=$size --quiet
    iter=`expr $iter + 1`
    sleep 2
done
