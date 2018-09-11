#!bin/bash
try=1
appName=`kubectl get po -l name=nginx -o jsonpath='{.items[0].metadata.name}'`
writeStatus=

until [ "$writeStatus" == "0"  ] || [ $try == 30 ]; do
    echo trying to write file to openebs vol in the app
    /usr/bin/timeout 5 kubectl exec -it $appName -- touch /var/lib/openebsvol/text.file
    writeStatus="$?"
    echo writeStatus is $writeStatus
    sleep 5
    try=`expr $try + 1`
done
