#!bin/sh
kubectl delete svc -l  "openebs.io/controller-service=cstor-controller-svc"
kubectl delete CStorVolume --all
kubectl delete CStorVolumeReplica --all
kubectl delete deploy -l "openebs.io/controller=cstor-controller"
