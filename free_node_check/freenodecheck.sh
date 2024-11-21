#!/bin/bash
# Written by Yuwu Chen at SDSC

# 0. Arguments parse and check
if [ "$#" -gt 2 ]; then
     echo "Error: too many arguments" && exit 0
elif [ "$#" -lt 2 ]; then
     echo "The number of parameter is less than 2. Enter  dialog mode:"
read -p "Please input a partition (hotel,condo,gold,platinum): " partition
read -p "Please input the number of cores needed: " ask 
else
	partition=$1
	ask=$2
fi

partition_array[1]="hotel"
partition_array[2]="condo"
partition_array[3]="gold"
partition_array[4]="platinum"

#echo ${partition_array[*]}


if [[ ! " ${partition_array[*]} " =~ [[:space:]]${partition}[[:space:]] ]]; then
   echo "Error: the partition name entered does not exist or cannot be queried by this script" ; exit 0 	
fi

for item in ${partition_array[@]}; do
   # echo ${item}
   if [ "${item}" = "${partition}" ]; then
     echo "Checking ${partition} partition"
   fi
done

#echo $partition $ask
# 1. Obtain all nodes in the queried partition(s) that are available to accept jobs and save their hostnames into a bash array (“array1”). 
# grep all nodes available to accept jobs
node=$(sinfo -p ${partition} -l -N  | grep "idle \| mixed" | awk '{print $1}')
node_comma=$(echo ${node} | sed 's/ /,/g')
#echo $node_comma
#scontrol show node ${node_comma}
# create an array saving node name
IFS=',' read -a node <<< "$node_comma"
#echo ${node[*]}

# 2. Get the MCS label of each node, and only choose nodes labeled as “N/A”, or as the same group MCS label when job was submitted to platinum or gold. 
 
# get the MCS label of the group, which has the same name as allocation
mcs_own=$(sacctmgr show assoc user=$USER format=Account | tail -n +3)
# remove the leading and/or trailing spaces
mcs_own=$(echo "$mcs_own" | xargs)
#echo ${mcs_own}
# for jobs submitted to the platinum or gold partition, look for nodes labeled as N/A or as the same group MCS label
if [[ ${partition} == "platinum" || ${partition} == "gold" ]]; then
  for i in "${!node[@]}"; do
    mcs=$(scontrol show node ${node[$i]} | grep MCS | awk '{print $6}' | cut -d '=' -f 2)	
#    echo ${mcs}
    if [[ ${mcs} == "N/A" || " $mcs_own " == *" $mcs "* ]]; then
#       echo ${node[$i]};
#    condition test:
#      echo "Condition met: mcs is '$mcs'"
#    else
#      echo ${node[$i]};
#      echo "Condition not met: mcs is '$mcs' and mcs_own is '$mcs_own'"
# save available nodes separated by comma ","  
     node_mcs_comma="${node_mcs_comma}${delim}${node[$i]}"
     delim=","     
    fi
  done
# for jobs submitted to the condo or hotel partition, only look for nodes labeled as N/A  
else
  for i in "${!node[@]}"; do
    mcs=$(scontrol show node ${node[$i]} | grep MCS | awk '{print $6}' | cut -d '=' -f 2)	 
#    echo ${mcs}     
    if [[ ${mcs} == "N/A" ]]; then
     node_mcs_comma="${node_mcs_comma}${delim}${node[$i]}"
     delim=","     
    fi	 
  done	   
fi  
#echo ${node_mcs_comma}
# 3. Save the node name in array2, and then save the total number of CPU cores on each node into array3

# create an array saving node name, array2
IFS=',' read -a node_mcs <<< "$node_mcs_comma"
# create an array saving total cpu cores on each node, array3
mapfile -t total < <(scontrol show node ${node_mcs_comma}  | grep CfgTRES | cut -d ',' -f 1 | cut -d '=' -f 3)
#echo ${total[*]}
#echo ${#total[@]}

# 4. Create an array saving allocated cpu cores on each node ("array4")
mapfile -t alloc < <(scontrol show node ${node_mcs_comma}  | grep AllocTRES | cut -d ',' -f 1 | cut -d '=' -f 3)
#echo ${alloc[*]}

# 5. Calculate available cores on each node by subtracting each element in array3 with the element in array4. 
# set empty array elements to zero for the next calculation
for i in "${!alloc[@]}"; do
    if [[ -z "${alloc[$i]}" ]]; then
        alloc[$i]=0;
    fi;
done
#echo ${alloc[*]}
#echo ${#alloc[@]}

# calculate available cpu cores on each node
for i in "${!total[@]}"; do 
    avail[i]=$(( total[i] - alloc[i] ))
done
#echo ${#avail[@]}
#echo ${avail[*]}
# 6. Compare the cores needed with the free cores available on the node.
# 7. If the number of free cores is equal or greater than the asked cores, then list the node name and the free CPUs.
declare -i count=0
echo "Below are the nodes that may fit your ${ask}-CPU job"
echo "Nodename CPU Free:" 
for i in ${!avail[@]}; do
   # echo ${avail}
   if [ "${avail[i]}" -ge "${ask}"  ]; then
     count=$((${count} + 1))	   
     echo "${node_mcs[i]} ${avail[i]}"
   fi
done

if [ "${count}" -eq 0 ]; then
     echo "There are no nodes that can fit your job"
fi



