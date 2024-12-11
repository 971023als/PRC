#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-027"
riskLevel="4"
diagnosisItem="과도한 커널 접근 권한 부여"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-027"
diagnosisItem="과도한 커널 접근 권한 부여"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: capability.add에 SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE 등이 부여되지 않거나, 업무상 필요한 capability만 제한적으로 부여된 경우
[취약]: capability.add에 SYS_ADMIN, NET_ADMIN, SYS_PTRACE, SYS_CHROOT, DAC_OVERRIDE, SETUID, SETGID, SYS_MODULE 등의 과도한 권한이 부여된 경우
EOF

BAR

# Function to check Kubernetes Pods for excessive capabilities
check_kubernetes_capabilities() {
    kubectl get pod -n [namespace] -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].name}{' | capabilities.add: '}{.spec.securityContext.capabilities.add}{'\n'}{end}" > $TMP1

    while read -r line; do
        pod_name=$(echo $line | cut -d ':' -f1)
        container_info=$(echo $line | cut -d ':' -f2)
        capabilities_add=$(echo $container_info | awk -F 'capabilities.add: ' '{print $2}' | cut -d ' ' -f1)

        if [[ "$capabilities_add" == *"SYS_ADMIN"* || "$capabilities_add" == *"NET_ADMIN"* || "$capabilities_add" == *"SYS_PTRACE"* || "$capabilities_add" == *"SYS_CHROOT"* || "$capabilities_add" == *"DAC_OVERRIDE"* || "$capabilities_add" == *"SETUID"* || "$capabilities_add" == *"SETGID"* || "$capabilities_add" == *"SYS_MODULE"* ]]; then
            diagnosisResult="과도한 커널 접근 권한 부여됨"
            status="취약"
        else
            diagnosisResult="과도한 커널 접근 권한 부여되지 않음"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$pod_name: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check Docker containers for excessive capabilities
check_docker_capabilities() {
    docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Capabilities={{ .HostConfig.Capabilities }}' > $TMP1

    while read -r line; do
        if [[ "$line" == *"SYS_ADMIN"* || "$line" == *"NET_ADMIN"* || "$line" == *"SYS_PTRACE"* || "$line" == *"SYS_CHROOT"* || "$line" == *"DAC_OVERRIDE"* || "$line" == *"SETUID"* || "$line" == *"SETGID"* || "$line" == *"SYS_MODULE"* ]]; then
            diagnosisResult="과도한 커널 접근 권한 부여됨"
            status="취약"
        else
            diagnosisResult="과도한 커널 접근 권한 부여되지 않음"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$line: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check Docker configuration for excessive capabilities
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
