#!/bin/bash
# To run the test execute run-sta-test.sh
# ./run-sta-test.sh <resoruce-group-name> <AKS-Cluser-Name> <Node-Pool-Name> <VM-SKU>
# eg. ./run-stat-test.sh k8s cluster m128 Standard_M128

# Create AKS Cluster
# az aks create -g  $1 -n --cluster-name $3 

#create new nodepool
az aks nodepool add -g $1 --cluster-name $2 --name $3  --node-osdisk-size 1000 --node-vm-size $4 --node-count 1 --labels allow-stat-test=True --no-wait

# Get nodepool status
nodepool_status=""
while [ "$nodepool_status" != "Succeeded" ];do
nodepool_status=$(az aks nodepool show -g $1 --cluster-name $2 --name $3   --query provisioningState -o tsv);
echo "Nodepool $3 Provisioning state: $nodepool_status...";
sleep 5;
done;

# Get Creds
az aks get-credentials -g $1 -n $2

# Create Name Space
kubectl create namespace $3
# Apply Kubernetes Manifests

kubectl apply -f . -n $3

Pod_status=""
while [ "$Pod_status" != "Running" ];do
Pod_status=$(kubectl get pods -l job-name=statjob  -n $3  -o jsonpath="{.items[*].status.phase}");
echo "Pod state: $Pod_status...";
done;

for pod in $(kubectl get pod -n $3  -l job-name=statjob| grep statjob | awk '{print $1}') ; do
kubectl logs -f $pod -n $3 | tee $pod.log;
done

cat  $pod.log| grep Finished_Tests
if [ $? -eq 0 ]
then
kubectl delete -f . -n $3 && kubectl delete namespace $3 && az aks nodepool delete -g $1 --cluster-name $2 --name $3 --no-wait
fi

# Finally Delete AKS cluster
# az aks delete  -g  $1 -n  $3 
