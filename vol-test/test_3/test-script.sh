#!bin/bash

source ../util.sh
# TODO: Copy csp status test from ashutosh's code

cleanUp()
{
    kubectlDelete pvc.yaml
    sleep 5
    kubectlDelete sc.yaml
    kubectlDelete svc.yaml
}

# This is failure case therefore creating service
echo Applying svc
kubectlApply svc.yaml

# Apply storage class
echo Applying sc
kubectlApply sc.yaml

# Apply the pvc.yaml and then application.yaml

echo Applying pvc
kubectlApply pvc.yaml

# sleep as image pulling takes time
sleep 10
pvStatus=
try=1
until [ "$pvStatus" == "Pending"  ] || [ $try == 10 ]; do
    echo Checking status of pvc,try $try:
    pvStatus=$(kubectl get pvc openebs-pvc -o jsonpath='{.status.phase}')
    try=`expr $try + 1`
    sleep 5
done

if [ "$pvStatus" == "Pending" ]; then
   error=$(kubectl describe pvc openebs-pvc | grep "service already" | wc -l)
   if [ "$error" == "0" ]; then
       echo expected error not found
       cleanUp
       exit 1
   fi
fi
cleanUp
exit 0
