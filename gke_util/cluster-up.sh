#!bin/bash

clusterName=$1
poolName=$2
prefix=$3
count=$4

usage()
{
    echo "bash cluster-up.sh <cluster_name> <prefix> <count>"
    echo
}

usage

if [ "$clusterName" == "" ]; then
    clusterName="prince-cluster"
    echo clusterName not supplied, using $clusterName as default
fi

if [ "$prefix" == "" ]; then
    prefix="prince"
    echo prefix not supplied, using $prefix as default
fi

if [ "$count" == "" ]; then
    count=3
    echo count not supplied, using $count as default
fi

if [ "$poolName" == "" ]; then
    poolName="default-pool"
    echo pool name not supplied, using $poolName as default
fi

echo "gcloud container clusters resize $clusterName --node-pool=$poolName --size=$count --quiet"
gcloud container clusters resize $clusterName --node-pool=$poolName --size=$count --quiet

nodes=`kubectl get node -o jsonpath='{.items[*].metadata.name}'`

echo nodes found: $nodes

bash create-disks.sh $prefix $count
sleep 5

iter=0

for n in $nodes; do
    echo "gcloud compute instances attach-disk $n --disk=$prefix-$iter --device-name=$prefix-$iter --quiet"
    gcloud compute instances attach-disk $n --disk=$prefix-$iter --device-name=$prefix-$iter --quiet
    iter=`expr $iter + 1`
done
