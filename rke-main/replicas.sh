#!/bin/bash

ns=`/usr/local/bin/kubectl get namespaces -o jsonpath={.items[*].metadata.name}`

exclusionlist=(default grafana kube-system karpenter kube-logging kube-monitor traefik velero)

for r in $ns
do
  if [ r != $exclusionlist ]
  then
    kubectl scale --replicas=0 deployment -n $r --all 
    echo $r
  fi  
done