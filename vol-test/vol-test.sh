#!bin/bash

# this script sets up openebs and then calls different test scripts
# source util file
source util.sh

usage()
{
    echo bash vol-test.sh -o operator.yaml -o pool.yaml
}

runTest()
{
    for testCase in test_4; do
        echo "-----------------------------------------------------"
        echo -e ${YELLOW}running $testCase${NC}
        echo "-----------------------------------------------------"
        cd $testCase
        bash test-script.sh
        exitValue=$?
        echo "-----------------------------------------------------"
        echo exit value: $exitValue
        if [ "$exitValue" == "0" ]; then
            echo -e ${GREEN}Success: $testCase${NC}
        else
            echo -e ${RED}Fail: $testCase${NC}
        fi
        echo "deleting residual pods if any"
        kubectl delete po -n openebs -l "openebs.io/persistent-volume-claim=openebs-pvc" --force --grace-period=0
        cd ..
    done
}
# Setup operator
setupOperator()
{
    opYaml="$1"
    echo using operator file $opYaml
    kubectl apply -f $opYaml
}

# Setup pool
setupPool()
{
    poolYaml="$1"
    echo using pool file $poolYaml
    kubectl apply -f $poolYaml
}

# get operator yaml and pool yaml
while getopts "o:p:" opt; do
    case "${opt}" in
        o)
            OP_FILE="${OPTARG}"
            ;;
        p)
            POOL_FILE="${OPTARG}"
            ;;
        :)
            echo option -$OPTARG requires argument
            exit 1
            ;;
    esac
done

if [ "$OP_FILE" == "" ] || [ "$POOL_FILE" == "" ]; then
    usage
    exit 1
fi

echo using operator yaml $OP_FILE and pool yaml $POOL_FILE

setupOperator $OP_FILE

# check if the maya api server is in running state yet. If m-api server is not in running state then
# retry. This is being done to ensure that the installer installs all the resources before we proceed
# further
sleep 10
try=1
appStatus=
echo looping
until [ "$appStatus" == "Running"  ] || [ $try == 30 ]; do
    echo Checking status of maya api server, try $try:
    appStatus=$(kubectl get po -l name=maya-apiserver -n openebs -o jsonpath='{.items[0].status.phase}')
    try=`expr $try + 1`
    sleep 5
done

if [ "$appStatus" != "Running" ]; then
    echo Maya api server pod not up yet. Exiting...
    sleep 10
    exit 0
fi

echo Maya-apiserver is running

setupPool $POOL_FILE

# Call test cases
# go inside each test case directory. execute the test script and then cd back
runTest

bash ./delete.sh
