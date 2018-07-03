#!bin/sh
curl -k -H "Content-Type: application/yaml" -X POST -d"$(cat cas-volume.yaml)" http://"$(kubectl get svc maya-apiserver-service --template={{.spec.clusterIP}})":5656/latest/volumes/
