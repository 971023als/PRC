#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-028"
riskLevel="4"
diagnosisItem="불필요한 커널 접근 권한 제거"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-028"
diagnosisItem="불필요한 커널 접근 권한 제거"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: capability.drop에 SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE 등이 부여된 경우
[취약]: capability.drop에 SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE 등이 부여되지 않은 경우
EOF

BAR

# Function to check capabilities in Kubernetes Pods
check_kubernetes_capabilities() {
    kubectl get pod -n [namespace] -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].name}{' | capabilities.drop: '}{.spec.securityContext.capabilities.drop}{'\n'}{end}" > $TMP1

    while read -r line; do
        pod_name=$(echo $line | cut -d ':' -f1)
        container_info=$(echo $line | cut -d ':' -f2)
        capabilities_drop=$(echo $container_info | awk -F 'capabilities.drop: ' '{print $2}' | cut -d ' ' -f1)

        if [[ "$capabilities_drop" == *"SYS_ADMIN"* || "$capabilities_drop" == *"NET_ADMIN"* || "$capabilities_drop" == *"SYS_PTRACE"* || "$capabilities_drop" == *"SYS_CHROOT"* || "$capabilities_drop" == *"DAC_OVERRIDE"* || "$capabilities_drop" == *"SETUID"* || "$capabilities_drop" == *"SETGID"* || "$capabilities_drop" == *"SYS_MODULE"* ]]; then
            diagnosisResult="필요하지 않은 커널 접근 권한 제거됨"
            status="양호"
        else
            diagnosisResult="필요하지 않은 커널 접근 권한 제거되지 않음"
            status="취약"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$pod_name: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check capabilities in Docker containers
check_docker_capabilities() {
    docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Capabilities={{ .HostConfig.Capabilities }}' > $TMP1

    while read -r line; do
        if [[ "$line" == *"SYS_ADMIN"* || "$line" == *"NET_ADMIN"* || "$line" == *"SYS_PTRACE"* || "$line" == *"SYS_CHROOT"* || "$line" == *"DAC_OVERRIDE"* || "$line" == *"SETUID"* || "$line" == *"SETGID"* || "$line" == *"SYS_MODULE"* ]]; then
            diagnosisResult="필요하지 않은 커널 접근 권한 제거됨"
            status="양호"
        else
            diagnosisResult="필요하지 않은 커널 접근 권한 제거되지 않음"
            status="취약"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$line: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check Docker configuration for capabilities
check_docker_daemon_json() {
    sudo cat /etc/docker/daemon.json | grep -q "capabilities"
    if [ $? -eq 0 ]; then
        diagnosisResult="커널 접근 권한 설정이 완료됨"
        status="양호"
    else
        diagnosisResult="커널 접근 권한 설정되지 않음"
        status="취약"
    fi

    # Output result to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker daemon.json capabilities: $diagnosisResult" >> $TMP1
}

# Run the checks for Kubernetes and Docker
check_kubernetes_capabilities
check_docker_capabilities
check_docker_daemon_json

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
