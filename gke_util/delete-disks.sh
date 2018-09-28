#!bin/bash

usage()
{
    echo usage: "bash delete-disks.sh <disk_prefix> <count>"
    echo
}

usage

prefix="$1"

count="$2"

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
echo

sleep 5

iter=0

echo $count $iter
until [ "$iter" == "$count" ]; do
    echo "gcloud compute disks delete $prefix-$iter --quiet"
    gcloud compute disks delete $prefix-$iter --quiet
    iter=`expr $iter + 1`
    sleep 2
done
