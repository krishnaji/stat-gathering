#!/bin/bash

# Copy installation script to host
cp /tmp/install.sh /host

# Copy wait script to the host 
cp /wait.sh /host

echo "Wait for updates to complete"
/usr/bin/nsenter -m/proc/1/ns/mnt -- chmod u+x /tmp/install/wait.sh

echo " Give execute priv to script"
/usr/bin/nsenter -m/proc/1/ns/mnt -- chmod u+x /tmp/install/install.sh
# Based on : https://gist.githubusercontent.com/patnaikshekhar/ef76f71cc179d7b974327a33ff6bc2bd/raw/407fde1a12c12c1e09ae56e79d07df4a4c6513aa/daemonsetnodebashscript.sh

# Wait for Node updates to complete
/usr/bin/nsenter -m/proc/1/ns/mnt /tmp/install/wait.sh

# If the /tmp folder is mounted on the host then it can run the script
/usr/bin/nsenter -m/proc/1/ns/mnt /tmp/install/install.sh

echo "*********** Running tests **** "
echo "•	CPU Testing"
for i in {1..1}
do
echo "CPU Run $i"
/usr/bin/nsenter -m/proc/1/ns/mnt sysbench  --test=cpu  --cpu-max-prime=20000 run
done

echo "•	Sequential Reads on NODE OS DISK /dev/sda1"
for i in {1..1}
do
echo "Sequential Reads Run $i"
/usr/bin/nsenter -m/proc/1/ns/mnt fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=8 --size=1G --runtime=600  --group_reporting
# /usr/bin/nsenter -m/proc/1/ns/mnt fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=1 --size=$(($(grep MemTotal /proc/meminfo|awk '{print $2}') * 2))K --runtime=600  --group_reporting
done

echo "•	Sequential Writes on NODE OS DISK /dev/sda1"
for i in {1..1}
do
echo "Sequential Writes Run $i"
/usr/bin/nsenter -m/proc/1/ns/mnt fio --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=32k --numjobs=4 --size=2G --runtime=600 --group_reporting
done

echo "•	Sequential Reads on NODE TEMP DISK /dev/sdb1"
for i in {1..1}
do
echo "Sequential Reads Run $i"
/usr/bin/nsenter -m/proc/1/ns/mnt fio --directory=/mnt --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=8 --size=1G --runtime=600  --group_reporting
# /usr/bin/nsenter -m/proc/1/ns/mnt fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=1 --size=$(($(grep MemTotal /proc/meminfo|awk '{print $2}') * 2))K --runtime=600  --group_reporting
done

echo "•	Sequential Writes on NODE TEMP DISK /dev/sdb1"
for i in {1..1}
do
echo "Sequential Writes Run $i"
/usr/bin/nsenter -m/proc/1/ns/mnt fio --directory=/mnt --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=32k --numjobs=4 --size=2G --runtime=600 --group_reporting
done

echo "•	Sequential Reads POD AZUREFILE STD"
for i in {1..1}
do
echo "Sequential Reads Run $i"
fio --directory=/mnt/azurefile-std --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=8 --size=1G --runtime=600  --group_reporting
# /usr/bin/nsenter -m/proc/1/ns/mnt fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=1 --size=$(($(grep MemTotal /proc/meminfo|awk '{print $2}') * 2))K --runtime=600  --group_reporting
done

echo "•	Sequential Writes on NODE POD AZUREFILE STD"
for i in {1..1}
do
echo "Sequential Writes Run $i"
fio --directory=/mnt/azurefile-std --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=32k --numjobs=4 --size=2G --runtime=600 --group_reporting
done

echo "•	Sequential Reads POD AZUREFILE PREM"
for i in {1..1}
do
echo "Sequential Reads Run $i"
fio --directory=/mnt/azurefile-prem --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=8 --size=1G --runtime=600  --group_reporting
# /usr/bin/nsenter -m/proc/1/ns/mnt fio --name=seqread --rw=read --direct=1 --ioengine=libaio --bs=8k --numjobs=1 --size=$(($(grep MemTotal /proc/meminfo|awk '{print $2}') * 2))K --runtime=600  --group_reporting
done

echo "•	Sequential Writes on POD AZUREFILE PREM"
for i in {1..1}
do
echo "Sequential Writes Run $i"
fio --directory=/mnt/azurefile-prem --name=seqwrite --rw=write --direct=1 --ioengine=libaio --bs=32k --numjobs=4 --size=2G --runtime=600 --group_reporting
done
sleep 30
echo "Finished_Tests"

