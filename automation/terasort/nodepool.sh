#!/bin/bash

read -r previous_nodepoolname < ./automation/previous-nodepool.txt

echo "Creating nodepool $1 of type $2";
find ./* -type f -exec sed -i "s/$previous_nodepoolname/$1/g" {} \;

#create new nodepool

az aks nodepool add --cluster-name cluster --name $1 -g k8s --node-osdisk-size 1000 --node-vm-size $2 --node-count 1 --labels allow-stat-test=True --no-wait

# Get nodepool status
nodepool_status=""
while [ "$nodepool_status" != "Succeeded" ];do
nodepool_status=$(az aks nodepool show --cluster-name cluster --name $1 -g k8s --query provisioningState -o tsv);
echo "Nodepool $1 Provisioning state: $nodepool_status...";
sleep 10;
done;

#create a new namespace
echo "Creating namespace $1"
kubectl create namespace $1

# apply manifests
echo "Creating HPCC Cluster"
kubectl apply -f . -n $1

#  Get ECLwatch External IP
external_ip=""
while [ -z $external_ip ]; do 
echo "Waiting for ECL Watch endpoint...";
external_ip=$(kubectl get svc eclwatch -n $1 --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}"); 
[ -z "$external_ip" ] && sleep 10;
done;
echo "ECL Watch IP -" && echo $external_ip;

eclwatch_status=""
while [ "$eclwatch_status" != "Running" ];do
eclwatch_status=$(kubectl get pods -l run=eclwatch -n $1 -o jsonpath="{.items[*].status.phase}");
echo "ECL Watch Provisioning state: $eclwatch_status...";
sleep 10;
done;


# #  Prep Job
# echo "Running prep job $external_ip:8010 "
# ecl run thor ./automation/terasortprep.ecl  -s "$external_ip:8010" -n terasortprep_$1 --wait=10
# sleep 20;
# wuid=$(ecl getwuid -n terasortprep_$1 -s $external_ip:8010 )
# echo "Monitor workunit $wuid here http://$external_ip:8010/#/stub/ECL-DL/Workunits-DL/Workunits"

# wuid_status=""
# while [ "$wuid_status" != "completed" ];do
# wuid_status=$(ecl status -wu $wuid -n terasortprep_$1 $external_ip:8010);
# echo "Workunit state: $wuid_status...";
# sleep 10;
# done;


# # ecl run thor ./automation/terasort.ecl  -s  $external_ip:8010 -n terasort_$1 --wait=1

# # Clean up HPCC Cluster
# echo "Deleting HPCC Cluster"
# kubectl delete -f . -n $1

# # Delate namespace
# echo "Deleting namespace $1"
# kubectl delete namespace $1

# # Delete Nodepool

# echo "Deleteing nodepool $1"
# az aks nodepool delete --cluster-name cluster --name $1 -g k8s