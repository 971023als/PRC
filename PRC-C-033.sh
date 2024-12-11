#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-033"
riskLevel="2"
diagnosisItem="컨테이너의 재시작 정책 설정의 적절성"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-033"
diagnosisItem="컨테이너의 재시작 정책 설정의 적절성"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'restartPolicy'가 'Always', 'OnFailure'로 설정되어 있을 경우
[취약]: 'restartPolicy'가 'Never'로 설정되어 있을 경우
EOF

BAR

# Function to check if restart policy is correctly set for Kubernetes pods
check_k8s_restart_policy() {
    kubectl get pod -n [namespace] -o jsonpath='{range .items[*]}{.metadata.name}: {.spec.restartPolicy}{""\n""}{end}' | while read line; do
        pod_name=$(echo "$line" | cut -d: -f1)
        restart_policy=$(echo "$line" | cut -d: -f2)

        if [[ "$restart_policy" == "Always" || "$restart_policy" == "OnFailure" ]]; then
            diagnosisResult="적절한 재시작 정책 설정됨"
            status="양호"
        elif [[ "$restart_policy" == "Never" ]]; then
            diagnosisResult="재시작 정책이 설정되지 않음"
            status="취약"
        fi

        # Output result to CSV
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

        # Log the pod and its restart policy
        echo "Pod $pod_name: RestartPolicy=$restart_policy" >> $TMP1
    done
}

# Function to check Docker container restart policy
check_docker_restart_policy() {
    containers=$(docker ps --quiet --all)

    # Iterate over containers
    for container in $containers; do
        restart_policy=$(docker inspect --format '{{ .HostConfig.RestartPolicy.Name }}' "$container")
        max_retry=$(docker inspect --format '{{ .HostConfig.RestartPolicy.MaximumRetryCount }}' "$container")

        if [[ "$restart_policy" == "always" || "$restart_policy" == "on-failure" ]]; then
            if [[ "$max_retry" -gt 0 ]]; then
                diagnosisResult="적절한 재시작 정책 설정됨"
                status="양호"
            else
                diagnosisResult="재시작 횟수가 0으로 설정되어 있음"
                status="취약"
            fi
        elif [[ "$restart_policy" == "no" ]]; then
            diagnosisResult="재시작 정책이 설정되지 않음"
            status="취약"
        fi

        # Output result to CSV
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

        # Log the container and its restart policy
        echo "Container $container: RestartPolicy=$restart_policy, MaximumRetryCount=$max_retry" >> $TMP1
    done
}

# Check Kubernetes Pods
check_k8s_restart_policy

# Check Docker Containers
check_docker_restart_policy

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
