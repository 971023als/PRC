#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-044"
riskLevel="3"
diagnosisItem="컨테이너의 호스트 네트워크 네임스페이스 공유 최소화"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-044"
diagnosisItem="컨테이너의 호스트 네트워크 네임스페이스 공유 최소화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'hostNetwork'가 'false'로 설정되어 있는 경우
[취약]: 'hostNetwork'가 'true'로 설정되어 있을 경우
EOF

BAR

# Function to check hostNetwork setting for Kubernetes Pods
check_host_network_k8s() {
    local pod_name=$1
    local namespace=$2

    # Retrieve hostNetwork configuration from the pod container specifications
    host_network=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{range .spec.containers[*]}{.name}|spec.hostNetwork:'{.spec.hostNetwork}'{end}")

    # Check if hostNetwork is set to true (container shares the host's network namespace)
    if [[ "$host_network" =~ "true" ]]; then
        diagnosisResult="Pod $pod_name in namespace $namespace shares the host's network namespace."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Pod $pod_name in namespace $namespace does not share the host's network namespace."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking hostNetwork setting for Kubernetes pods
pods=$(kubectl get pods --all-namespaces --no-headers | grep -v "kube-system" | awk '{print $1 " " $2}')

for pod in $pods; do
    pod_name=$(echo $pod | cut -d ' ' -f 1)
    namespace=$(echo $pod | cut -d ' ' -f 2)
    check_host_network_k8s $pod_name $namespace
done

# Function to check Docker container NetworkMode setting
check_docker_network_mode() {
    container_id=$1

    # Retrieve NetworkMode configuration from the container's HostConfig
    network_mode=$(docker inspect --format '{{ .Id }}: NetworkMode={{ .HostConfig.NetworkMode }}' $container_id)

    # Check if NetworkMode is set to host (container shares the host's network namespace)
    if [[ "$network_mode" =~ "NetworkMode=host" ]]; then
        diagnosisResult="Container $container_id shares the host's network namespace."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    elif [[ "$network_mode" =~ "NetworkMode=bridge" && "$network_mode" =~ "icc=false" ]]; then
        diagnosisResult="Container $container_id is in bridge mode but icc is false."
        status="양호"
        echo "INFO: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Container $container_id does not share the host's network namespace."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking NetworkMode setting for Docker containers
docker_containers=$(docker ps --quiet --all)

for container_id in $docker_containers; do
    check_docker_network_mode $container_id
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
