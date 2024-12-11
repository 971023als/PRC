#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-031"
riskLevel="4"
diagnosisItem="컨테이너의 관리자 권한 실행"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-031"
diagnosisItem="컨테이너의 관리자 권한 실행"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 컨테이너가 관리자 권한이 아닌 일반 유저 계정으로 실행된 경우
[취약]: 컨테이너가 관리자(root) 권한으로 실행된 경우
EOF

BAR

# Function to check if containers are running as root (uid=0)
check_run_as_user() {
    # Method 1: Check Kubernetes pod configuration
    kubectl get pod -n [namespace] -o jsonpath="{range .items[*]}{.metadata.name}{': '}{.spec.containers[*].name}{' | runAsUser: '}{.spec.securityContext.runAsUser}{' | runAsNonRoot: '}{.spec.securityContext.runAsNonRoot}{'\n'}{end}" > $TMP1

    while read -r line; do
        pod_name=$(echo $line | cut -d ':' -f1)
        container_info=$(echo $line | cut -d ':' -f2)
        run_as_user=$(echo $container_info | awk -F 'runAsUser: ' '{print $2}' | cut -d ' ' -f1)
        run_as_non_root=$(echo $container_info | awk -F 'runAsNonRoot: ' '{print $2}' | cut -d ' ' -f1)

        if [[ "$run_as_user" -eq 0 ]] || [[ "$run_as_non_root" == "false" ]] || [[ -z "$run_as_user" && -z "$run_as_non_root" ]]; then
            diagnosisResult="관리자 권한(root)으로 실행"
            status="취약"
        else
            diagnosisResult="일반 사용자 계정으로 실행"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "$pod_name: $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Function to check if containers are running as root using Docker command
check_docker_run_as_user() {
    docker ps --quiet | xargs -I{} sh -c "docker exec {} cat /proc/1/status | grep '^Uid:' | awk '{print \$3}'" > $TMP1

    while read -r line; do
        if [ "$line" -eq 0 ]; then
            diagnosisResult="관리자 권한(root)으로 실행"
            status="취약"
        else
            diagnosisResult="일반 사용자 계정으로 실행"
            status="양호"
        fi

        # Output result to CSV
        echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
        echo "Container with UID: $line - $diagnosisResult" >> $TMP1
    done < $TMP1
}

# Run the checks for Kubernetes and Docker
check_run_as_user
check_docker_run_as_user

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
