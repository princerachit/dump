#!bin/bash

source ../util.sh
# TODO: Copy csp status test from ashutosh's code

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
    appStatus=$(kubectl get po -l name=percona -o jsonpath='{.items[0].status.phase}')
    try=`expr $try + 1`
    sleep 5
done

if [ "$appStatus" == "Running" ]; then
    echo test successful
fi

exit 1
