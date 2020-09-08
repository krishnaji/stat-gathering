
## Pre requisites 
1. AKS Cluster, or you can have it created as well. Uncomment line  ```az aks create -g  $1 -n --cluster-name $3 ``` in [file](/automation/stat/run-stat-test.sh)
2. Create [AZURE_CREDENTIALS](https://github.com/Azure/login#configure-deployment-credentials) in GitHub secrets

## CPU and Storage tests on AKS

To run CPU and Storage Test update and commit [run-test-for](/automation/stat/run-test-for.txt) in below format

```<Resource-Group-Name> <AKS-Cluster-Name> <Kubernetes-Namespace-Name> <Nodepool-VM-SKU>```

eg. AKS kluster m128r Standard_M128

Once changes to this file are committed , the Github Actions would start , which will create the nodedepool/namespace and will also execute the tests.

Tests Included:

1. CPU Testing using  ```sysbench```
2. Sequential Reads on NODE's OS DISK using ```fio```
3. Sequential Writes on NODE's OS DISK using  ```fio```
4. Sequential Reads on NODE's TEMP DISK using  ```fio```
5. Sequential Reads in a debian POD AZURE FILEs Standard using ```fio```
6. Sequential Writes in debian POD AZURE FILE FILEs Standard ```fio```
7. Sequential Reads in a debian POD AZURE FILE FILEs Premium ```fio```
8. Sequential Writes in debian POD AZURE FILE Premium using ```fio```

To execute same test multiple times update below section in [Tests](/automation/stats/stat-run.sh) file
```bash
for i in {1..1}
```

To increase Azure Files Standard and Premium storage capacity update below section in [Azure-Files-PVC](/automation/stat/azure-file-pvc.yaml)
```yml
 resources:
    requests:
      storage: 128Gi
```

To increase OS Disk size on Nodes update below [node pool parameter](/automation/stat/run-stat-test.sh)
```bash
--node-osdisk-size 128 
```