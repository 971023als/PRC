#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-047"
riskLevel="2"
diagnosisItem="컨테이너의 메모리 사용 제한"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-047"
diagnosisItem="컨테이너 메모리 제한 설정 점검"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'resources.limits.memory' 또는 'HostConfig.Memory'가 적절하게 설정된 경우
[취약]: 'resources.limits.memory' 또는 'HostConfig.Memory'가 0(무제한)으로 설정된 경우
EOF

BAR

# Function to check memory limits in Docker
check_docker_memory() {
    local container_id=$1
    local memory_limit=""

    # Retrieve memory limit for the container
    memory_limit=$(docker inspect --format '{{ .HostConfig.Memory }}' $container_id)

    if [ "$memory_limit" -eq 0 ]; then
        diagnosisResult="컨테이너 $container_id는 메모리 제한이 설정되지 않았습니다. 무제한 메모리 사용이 허용됩니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="컨테이너 $container_id는 메모리 제한($memory_limit) 이 설정되어 있습니다."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check memory limits in Kubernetes
check_k8s_memory() {
    local pod_name=$1
    local namespace=$2

    # Retrieve memory limits for the pod containers in Kubernetes
    memory_limit=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{range .spec.containers[*]}{.name}|resources.limits.memory:'{.resources.limits.memory}'{end}")

    # Check if memory limit is set to 0
    if [[ "$memory_limit" == *":0"* ]]; then
        diagnosisResult="Pod $pod_name in namespace $namespace has memory limit set to 0 (unlimited)."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Pod $pod_name in namespace $namespace has appropriate memory limits set."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking memory for Docker containers
container_ids=$(docker ps --quiet --all)

for container_id in $container_ids; do
    check_docker_memory $container_id
done

# Checking memory for Kubernetes pods
# Get all pod names and namespaces (excluding kube-system)
pods=$(kubectl get pods --all-namespaces --no-headers | grep -v "kube-system" | awk '{print $1 " " $2}')

for pod in $pods; do
    pod_name=$(echo $pod | cut -d ' ' -f 1)
    namespace=$(echo $pod | cut -d ' ' -f 2)
    check_k8s_memory $pod_name $namespace
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
