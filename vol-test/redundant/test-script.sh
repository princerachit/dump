#!bin/bash

source ../util.sh
# TODO: Copy csp status test from ashutosh's code

reincarnate()
{
    echo Scaling down target replica to 0
    kubectl scale deploy -l openebs.io/persistent-volume-claim=openebs-pvc --replicas=0 -n openebs
    if [ "$?" != "0" ]; then
        exit $?
    fi
    sleep 15

    try=1
    aliveTargets=
    until [ "$aliveTargets" == "0" ] || [ $try == 10 ]; do
        aliveTargets=`kubectl get po -l openebs.io/persistent-volume-claim=openebs-pvc -n openebs -o jsonpath='{.items[?(@.status.phase=="Running")].status.phase}' | wc -l`
        try=`expr $try + 1`
        sleep 5
    done

    if [ $try == 10 ]; then
        echo target could not be killed in given duration
        cleanUp
        exit 1
    fi

    echo Scaling up target count back to 1
    kubectl scale deploy -l openebs.io/persistent-volume-claim=openebs-pvc --replicas=1 -n openebs
    if [ "$?" != "0" ]; then
        exit $?
    fi
    sleep 10
}
cleanUp()
{
    kubectlDelete app.yaml
    kubectlDelete pvc.yaml
    sleep 5
    kubectlDelete sc.yaml
}
# Apply storage class
echo Applying sc
kubectlApply sc.yaml

# Apply the pvc.yaml and then application.yaml

echo Applying pvc
kubectlApply pvc.yaml

echo Applying app
kubectlApply app.yaml

# sleep as image pulling takes time
sleep 10
appStatus=
try=1
until [ "$appStatus" == "Running"  ] || [ $try == 30 ]; do
    echo Checking status of application try $try:
    appStatus=$(kubectl get po -l name=nginx -o jsonpath='{.items[0].status.phase}')
    try=`expr $try + 1`
    sleep 5
done

if [ "$appStatus" == "Running" ]; then
    echo application is in running state
    reincarnate
else
    echo application did not come up.
    cleanUp
    exit 1
fi


try=1
writeStatus=

export appName=`kubectl get po -l name=nginx -o jsonpath='{.items[0].metadata.name}'`
until [ "$writeStatus" == "0"  ] || [ $try == 20 ]; do
    echo trying to write file to openebs vol in the app
    bash sanity-script.sh &
    pid=$!
    sleep 8
    kill $pid
    writeStatus=`cat write-status.txt`
    try=`expr $try + 1`
done

echo last writeStatus $writeStatus
if [ "$writeStatus" == "0" ]; then
    echo file creation was successful in openebs vol
    cleanUp
    exit 0
fi

echo file creation failed in openebs vol
cleanUp
exit 1
