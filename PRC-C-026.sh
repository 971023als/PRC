#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-026"
riskLevel="5"
diagnosisItem="컨테이너의 privileged 플래그 실행"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-026"
diagnosisItem="컨테이너의 privileged 플래그 실행"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: privileged 플래그가 설정되지 않거나 false로 설정된 경우
[취약]: privileged 플래그가 true로 설정된 경우
EOF

BAR

# Function to check Kubernetes Pods for privileged flag
check_kubernetes_privileged() {
    kubectl get pod -n [namespace] -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].name}{' | privileged: '}{.spec.securityContext.privileged}{'\n'}{end}" > $TMP1

    while read -r line; do
        pod_name=$(echo $line | cut -d ':' -f1)
        container_info=$(echo $line | cut -d ':' -f2)
        privileged_flag=$(echo $container_info | awk -F 'privileged: ' '{print $2}' | cut -d ' ' -f1)

        if [[ "$privileged_flag" == "true" ]]; then
            diagnosisResult="privileged 플래그가 설정됨"
            status="취약"
        else
            diagnosisResult="privileged 플래그가 설정되지 않음"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$pod_name: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check Docker containers for privileged flag
check_docker_privileged() {
    docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Privileged={{ .HostConfig.Privileged }}' > $TMP1

    while read -r line; do
        if [[ "$line" == *"Privileged=true"* ]]; then
            diagnosisResult="privileged 플래그가 설정됨"
            status="취약"
        else
            diagnosisResult="privileged 플래그가 설정되지 않음"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$line: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check Docker configuration for privileged flag
check_docker_daemon_json() {
    sudo cat /etc/docker/daemon.json | grep -q "privileged"
    if [ $? -eq 0 ]; then
        diagnosisResult="privileged 플래그가 설정됨"
        status="취약"
    else
        diagnosisResult="privileged 플래그가 설정되지 않음"
        status="양호"
    fi

    # Output result to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker daemon.json privileged: $diagnosisResult" >> $TMP1
}

# Run the checks for Kubernetes and Docker
check_kubernetes_privileged
check_docker_privileged
check_docker_daemon_json

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
