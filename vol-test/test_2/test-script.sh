#!bin/bash

source ../util.sh
# TODO: Copy csp status test from ashutosh's code

cleanUp()
{
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

# sleep as image pulling takes time
sleep 10
pvStatus=
try=1
until [ "$pvStatus" == "Pending" ] || [ "$try" == "5" ] || [ "$pvStatus" == "Bound" ]; do
    echo Checking status of pvc,try $try:
    pvStatus=$(kubectl get pvc openebs-pvc -o jsonpath='{.status.phase}')
    try=`expr $try + 1`
    sleep 5
done

echo pvcStatus: $pvStatus
if [ "$pvStatus" == "Bound" ]; then
    echo Unexpected: pvc in running state
    exit 1
fi

if [ "$pvStatus" == "Pending" ]; then
   error=$(kubectl describe pvc openebs-pvc | grep "not enough pool" | wc -l)
   echo not enough pool grepping resulted int $error value
   if [ "$error" == "0" ]; then
       echo expected error not found
       cleanUp
       exit 1
   fi
fi
cleanUp
exit 0