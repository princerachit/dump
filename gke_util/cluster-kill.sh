#!bin/bash

# expecting cluster name and pool name from cmd
clusterName=$1
poolName=$2

usage()
{
    echo "bash cluster-kill.sh <cluster_name> <pool_name>"
}

usage

if [ "$clusterName" == "" ]; then
    clusterName="prince-cluster"
    echo clusterName not supplied, using $clusterName as default
fi

if [ "$poolName" == "" ]; then
    poolName="default-pool"
    echo pool name not supplied, using $poolName as default
fi

#resize using gcloud command
gcloud container clusters resize $clusterName --node-pool=$poolName --size=0 --quiet

#get all the nodes
nodes=`kubectl get node -o jsonpath='{.items[*].metadata.name}'`

# wait until all nodes are killed
echo "waiting for node size to go 0..."
until [ "$nodes" == "" ]; do
    printf .
    sleep 5
    nodes=`kubectl get node -o jsonpath='{.items[*].metadata.name}'`
done

#now delete the disks
bash delete-disks.sh
