#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-043"
riskLevel="3"
diagnosisItem="컨테이너의 호스트 IPC 네임스페이스 공유 최소화"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-043"
diagnosisItem="컨테이너의 호스트 IPC 네임스페이스 공유 최소화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'hostIPC'가 'false'로 설정되어 있는 경우
[취약]: 'hostIPC'가 'true'로 설정되어 있을 경우
EOF

BAR

# Function to check hostIPC setting for Kubernetes Pods
check_host_ipc_k8s() {
    local pod_name=$1
    local namespace=$2

    # Retrieve hostIPC configuration from the pod container specifications
    host_ipc=$(kubectl get pod $pod_name -n $namespace -o jsonpath="{range .spec.containers[*]}{.name}|spec.hostIPC:'{.spec.hostIPC}'{end}")

    # Check if hostIPC is set to true (container shares the host's IPC namespace)
    if [[ "$host_ipc" =~ "true" ]]; then
        diagnosisResult="Pod $pod_name in namespace $namespace shares the host's IPC namespace."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Pod $pod_name in namespace $namespace does not share the host's IPC namespace."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking hostIPC setting for Kubernetes pods
pods=$(kubectl get pods --all-namespaces --no-headers | grep -v "kube-system" | awk '{print $1 " " $2}')

for pod in $pods; do
    pod_name=$(echo $pod | cut -d ' ' -f 1)
    namespace=$(echo $pod | cut -d ' ' -f 2)
    check_host_ipc_k8s $pod_name $namespace
done

# Function to check Docker container IpcMode setting
check_docker_ipc_mode() {
    container_id=$1

    # Retrieve IpcMode configuration from the container's HostConfig
    ipc_mode=$(docker inspect --format '{{ .Id }}: IpcMode={{ .HostConfig.IpcMode }}' $container_id)

    # Check if IpcMode is set to host (container shares the host's IPC namespace)
    if [[ "$ipc_mode" =~ "IpcMode=host" ]]; then
        diagnosisResult="Container $container_id shares the host's IPC namespace."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="Container $container_id does not share the host's IPC namespace."
        status="양호"
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Checking IpcMode setting for Docker containers
docker_containers=$(docker ps --quiet --all)

for container_id in $docker_containers; do
    check_docker_ipc_mode $container_id
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
